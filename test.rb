# require 'rest-client'
require 'stretcher'

class Org
  attr_accessor :id, :name, :address1, :address2, :city, :state, :postal_code, :country, :gov_id1, :gov_id2, :gov_id3,
      :url, :telephone, :fax, :email, :date_updated, :group_id

  def initialize(array)
    @id, @name, @address1, @address2, @city, @state, @postal_code, @country, @gov_id1, @gov_id2, @gov_id3, @url,
        @telephone, @fax, @email, @date_updated, @group_id = array
  end

  def to_hash
    hash = {}
    self.instance_variables.each do |var|
      hash[var.to_s[1..-1]] = [ self.instance_variable_get(var) ]
    end
    hash
  end

  def to_s
    "Org{ ID: #{@id}, name: #{@name} }"
  end
end

class TestData
  def self.read_organizations

    def self.prepare_test_data
      file = File.new('FoundationCenter.txt', 'r')
      # skip headers:
      file.gets
      file
    end

    organizations = []

    file = prepare_test_data
    while (line = file.gets)
      org = Org.new(line.split(/\t+/))
      puts "Entry parsed: #{org}"

      organizations.push org
    end

    organizations
  end
end

class Deduplicator

  def initialize
    @idx = 'temp' # elasticsearch index & type name
    @server = Stretcher::Server.new('http://localhost:9200')
    # Prepare an empty index
    @server.index(@idx).delete rescue nil
    @server.index(@idx).create()
    sleep 1
  end

  def dedupe(org)
    # TODO prepare query template & fill with data
    query = { match_all: {} }
    res = @server.index(@idx).search(size: 10, query: query)

    if duplicate = is_duplicate(res)

      # TODO
      # GET the group & append new org values to existing arrays
      # update the group
      puts "Found duplicate: #{duplicate}"
    else
      # save as a new organization:
      org_as_json = org.to_hash.to_json
      puts "Creating new organization: #{org_as_json}"
      @server.index(@idx).type(@idx).put(org.id, org_as_json)
    end
  end

  def is_duplicate(res)
    results = res.results.sort_by(&:_score)
    duplicates = results.select { |item| item._score > 1.5 }
    if duplicates.empty?
      nil
    else
      duplicate.first
    end
  end
end


organizations = TestData.read_organizations

deduplicator = Deduplicator.new()

organizations.each do |org|
  deduplicator.dedupe org
end

puts 'Done.'
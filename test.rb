# require 'rest-client'
require 'stretcher'

class OrgHelper
  @@keys = %w( id name address1 address2 city state postal_code country gov_id1 gov_id2 gov_id3 url telephone fax mail
                date_updated group_id )

  def self.from_array(array)
   @@keys.zip(array).inject({}) do |k, v|
      k.merge!({ v[0] => [ v[1] ] })
    end
  end

  def self.merge(hash1, hash2)
    hash1.merge(hash2) do |key, a, b|
      if a.kind_of?(Array) then
        # merging duplicate keys is about putting all their values to a common array
        a.push(*b)
      else
        a != nil ? a : b
      end
    end
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
      org = OrgHelper.from_array(line.split(/\t+/))
      puts "Entry parsed: #{org}"

      organizations.push org
    end

    organizations
  end
end

class ElasticsearchIdGenerator
  @@id = 0

  def self.get_next
    @@id += 1
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

    if (duplicate = is_duplicate(res))
      puts "Found duplicate: #{duplicate}"

      # merge duplicate with existing organization
      merged = OrgHelper.merge(org, duplicate)
      @server.index(@idx).type(@idx).put(merged['es_id'], merged)
      puts "Merged duplicates into an existing organization: #{merged}"
    else
      # save as a new organization:
      id = org['es_id'] = ElasticsearchIdGenerator.get_next
      @server.index(@idx).type(@idx).put(id, org)
      puts "Created new organization: #{org}"
    end
  end

  def is_duplicate(res)
    results = res.results.sort_by(&:_score)
    duplicates = results.select { |item| item._score > 1.5 }
    if duplicates.empty?
      nil
    else
      # take the one with the highest score, process it, return it
      duplicates.first.to_hash.select { |key, value| key.match(/^[^_]/) }
    end
  end
end


organizations = TestData.read_organizations

deduplicator = Deduplicator.new()

organizations.each do |org|
  deduplicator.dedupe org
end

puts 'Done.'
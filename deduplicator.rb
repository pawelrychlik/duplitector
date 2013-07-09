require_relative 'org_helper'
require_relative 'elasticsearch_id_generator'
require_relative 'query_builder'

class Deduplicator

  def initialize
    @idx = 'temp' # elasticsearch index & type name
    @server = Stretcher::Server.new('http://localhost:9200')
                  # Prepare an empty index
    @server.index(@idx).delete rescue nil
    @server.index(@idx).create()
    sleep 1
  end

  def dedupe(org_flat)
    puts "Processing: #{org_flat}"
    query = QueryBuilder.detect_duplicates_of org_flat

    search_response = @server.index(@idx).search(size: 10, query: query)

    org = OrgHelper.with_attributes_as_arrays org_flat

    if (duplicate = is_duplicate(search_response))
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

    puts
  end

  def is_duplicate(search_response)
    results = search_response.results.sort_by(&:_score)
    duplicates = results.select { |item| item._score > 0.5 }
    if duplicates.empty?
      puts "No potential duplicates found."
      nil
    else
      duplicate = duplicates.first
      puts "Found potential duplicates. Highest score: #{duplicate._score}"

      # take the one with the highest score, process it, return it
      duplicate.to_hash.select { |key, value| key.match(/^[^_]/) }
    end
  end
end
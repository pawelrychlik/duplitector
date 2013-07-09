require_relative 'org_helper'
require_relative 'elasticsearch_id_generator'
require_relative 'query_builder'

class Deduplicator

  def initialize(log)
    @log = log

    @idx = 'temp' # elasticsearch index & type name
    @server = Stretcher::Server.new('http://localhost:9200', logger: log)

    # Prepare an empty index
    @server.index(@idx).delete rescue nil
    @server.index(@idx).create()
    sleep 1
  end

  def dedupe(org_flat)
    @log.info "Processing: #{org_flat}"

    query = QueryBuilder.detect_duplicates_of org_flat
    @log.debug "Query: #{query.to_json}"

    search_response = @server.index(@idx).type(@idx).search({}, query)
    @log.debug "Search response: #{search_response}"

    org = OrgHelper.with_attributes_as_arrays org_flat

    if (duplicate = is_duplicate(search_response))
      # merge duplicate with existing organization
      merged = OrgHelper.merge(org, duplicate)
      @server.index(@idx).type(@idx).put(merged['es_id'], merged)
      @log.info "Merged duplicates into an existing organization: #{merged}"
    else
      # save as a new organization:
      id = org['es_id'] = ElasticsearchIdGenerator.get_next
      @server.index(@idx).type(@idx).put(id, org)
      @log.info "Created new organization: #{org}"
    end

    @server.index(@idx).refresh
    puts
  end

  def is_duplicate(response)
    results = response.results.sort_by(&:_score)
    duplicates = results.select { |item| item._score > 0.0 }
    if duplicates.empty?
      @log.info "No potential duplicates found. Highest score: #{results.first._score unless results.empty?}"
      nil
    else
      duplicate = duplicates.first
      @log.info "Found potential duplicates. Highest score: #{duplicate._score}"

      # take the one with the highest score, process it, return it
      duplicate.to_hash.select { |key, value| key.match(/^[^_]/) }
    end
  end
end
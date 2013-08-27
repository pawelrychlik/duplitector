require_relative 'org_helper'
require_relative 'elasticsearch_id_generator'
require_relative 'query_builder'
require_relative 'stats'
require_relative 'mapping_provider'
require_relative 'client_wrapper'

class Deduplicator

  def initialize(stats, log, client, score_cut_off)
    @stats = stats
    @log = log
    @client = client
    @score_cut_off = score_cut_off

    @client.create_mapping MappingProvider.new.mapping
  end

  def dedupe(org_flat)
    @log.info "Processing: #{org_flat}"

    query = QueryBuilder.detect_duplicates_of org_flat
    @log.debug "Query: #{query.to_json}"

    search_response = @client.search query
    @log.debug "Search response: #{search_response}"

    org = OrgHelper.with_attributes_as_arrays org_flat

    if (duplicate = is_duplicate(search_response))
      # merge duplicate with existing organization
      merged = OrgHelper.merge(org, duplicate)
      @client.put(merged['es_id'], merged)
      @log.info "Merged duplicates into an existing organization: #{merged}"
      @stats.duplicate
    else
      # save as a new organization:
      id = org['es_id'] = ElasticsearchIdGenerator.get_next
      @client.put(id, org)
      @log.info "Created new organization: #{org}"
      @stats.not_duplicate
    end

    @client.refresh
  end

  def is_duplicate(response)
    results = response.results.sort_by(&:_score)
    duplicates = results.select { |item| item._score > @score_cut_off }
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
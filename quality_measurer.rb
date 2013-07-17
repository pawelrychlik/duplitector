class QualityMeasurer

  def initialize(client, log)
    @client = client
    @log = log
  end

  def measure
    ok = 0
    fail = 0
    error = 0

    query = {
        query: { match_all: {} },
        size: 1000000,
        facets: {
            group_id: {
                terms: {
                    field: 'group_id',
                    size: 1000000
                }
            }
        }
    }

    results = @client.search(query)

    results.facets.group_id.terms.each { |facet|
      status = facet['count'] == 1
      if status then ok += 1 else fail += 1 end

      @log.info "#{status ? 'OK' : 'FAIL'}: \"group_id\"=>\"#{facet['term']}\" assigned to  #{facet['count']} orgs."
    }

    results.results.each { |org|
      status = org['group_id'].uniq.length == 1
      error += 1 unless status
      @log.info "ERROR: Org[\"es_id\"=>#{org['es_id']}] has more than one \"group_id\"=>#{org['group_id']}." unless status
    }

    @log.info "Duplicate resolution: OK=#{ok}, FAIL=#{fail}, ERROR=#{error}."
  end
end
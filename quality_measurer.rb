class QualityMeasurer

  def initialize(client, log)
    @client = client
    @log = log
  end

  def measure
    ok = 0
    fail = 0

    @client.all.results.each { |org|
      status = org['group_id'].uniq.length == 1
      if status then ok += 1 else fail += 1 end

      @log.info "#{status ? 'OK' : 'FAIL'}: Org[es_id=#{org['es_id']}; group_id=#{org['group_id']}]"
    }

    @log.info "Duplicate resolution: OK=#{ok}, FAIL=#{fail}"
  end
end
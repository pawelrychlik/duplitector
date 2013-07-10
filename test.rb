require 'stretcher'

require_relative 'test_data'
require_relative 'deduplicator'
require_relative 'stats'
require_relative 'normalizer'
require_relative 'client_wrapper'
require_relative 'quality_measurer'

log = Logger.new(STDOUT)
log.level = Logger::INFO
log.datetime_format = "%H:%M:%S"

organizations = TestData.new(log).read_organizations 20
log.info ''

normalizer = Normalizer.new


url = 'http://localhost:9200'
index = 'pawelrychlik'
client = ClientWrapper.new(url, index, log)

stats = Stats.new
score_cut_off = 1.0
deduplicator = Deduplicator.new(stats, log, client, score_cut_off)

organizations.each do |org|
  normalizer.normalize org
  deduplicator.dedupe org
  log.info ''
end

quality = QualityMeasurer.new(client, log)
quality.measure

log.info ''
log.info "Done. Stats: #{stats}"
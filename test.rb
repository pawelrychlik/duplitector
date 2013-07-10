require 'stretcher'

require_relative 'test_data'
require_relative 'deduplicator'
require_relative 'stats'
require_relative 'normalizer'

log = Logger.new(STDOUT)
log.level = Logger::INFO
log.datetime_format = "%H:%M:%S"

organizations = TestData.new(log).read_organizations 20

normalizer = Normalizer.new

stats = Stats.new
deduplicator = Deduplicator.new(stats, log)

organizations.each do |org|
  normalizer.normalize org
  deduplicator.dedupe org
end

log.info "Done. Stats: #{stats}"
require 'stretcher'

require_relative 'test_data'
require_relative 'deduplicator'
require_relative 'stats'

log = Logger.new(STDOUT)
log.level = Logger::INFO
log.datetime_format = "%H:%M:%S"

organizations = TestData.new(log).read_organizations 20
stats = Stats.new
deduplicator = Deduplicator.new(stats, log)

organizations.each do |org|
  deduplicator.dedupe org
end

log.info "Done. Stats: #{stats}"
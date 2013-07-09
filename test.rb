require 'stretcher'

require_relative 'test_data'
require_relative 'deduplicator'

log = Logger.new(STDOUT)
log.level = Logger::DEBUG
log.datetime_format = "%H:%M:%S"

organizations = TestData.new(log).read_organizations
deduplicator = Deduplicator.new(log)

organizations.each do |org|
  deduplicator.dedupe org
end

puts 'Done.'
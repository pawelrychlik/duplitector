require 'stretcher'

require_relative 'test_data'
require_relative 'deduplicator'

organizations = TestData.read_organizations
deduplicator = Deduplicator.new

organizations.each do |org|
  deduplicator.dedupe org
end

puts 'Done.'
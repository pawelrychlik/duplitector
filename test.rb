require 'stretcher'

require_relative 'test_data'
require_relative 'deduplicator'

limit = 10
organizations = TestData.read_organizations limit
deduplicator = Deduplicator.new

organizations.each do |org|
  deduplicator.dedupe org
end

puts 'Done.'
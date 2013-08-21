require 'stretcher'

require_relative 'test_data'
require_relative 'deduplicator'
require_relative 'stats'
require_relative 'normalizer'
require_relative 'client_wrapper'
require_relative 'quality_measurer'

log = Logger.new(STDOUT)
# use DEBUG for more detailed log information
log.level = Logger::INFO
log.datetime_format = "%H:%M:%S"

# The file to read the test data from.
# File contains tab-separated values describing organizations to be processed, the first row being an ignored header.
# Note that OrgHelper.keys defines the columns meaning, and these keys are reused in QueryBuilder and MappingProvider.
# The last column 'group_id' has a special meaning - every two entries that have the same group_id form a pair of
# a unique organization and its duplicate. Based on that, it is possible to measure the quality of elasticsearch
# queries used for finding duplicates, and gather overall statistics.
filename = 'FoundationCenter.txt'
# Number of organizations to process; nil means all.
org_count = nil
organizations = TestData.new(log).read_organizations filename, org_count
log.info ''

normalizer = Normalizer.new

# URL to elasticsearch server
url = 'http://localhost:9200'
# index name to be used in elasticsearch (actually it's both index name and type name)
index = 'duplitector'
client = ClientWrapper.new(url, index, log)

stats = Stats.new
# Evaluating whether a search query result is a duplicate of a given organization is based on a static cut-off
# threshold. It's an essential modifier to the deduplication algorithm.
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
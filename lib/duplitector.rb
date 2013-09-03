require 'stretcher'
require 'trollop'

require_relative 'duplitector/test_data'
require_relative 'duplitector/deduplicator'
require_relative 'duplitector/stats'
require_relative 'duplitector/normalizer'
require_relative 'duplitector/client_wrapper'
require_relative 'duplitector/quality_measurer'

opts = Trollop::options do
  # The file to read the test data from.
  # File contains tab-separated values describing organizations to be processed, the first row being an ignored header.
  # Note that OrgHelper.keys defines the columns meaning, and these keys are reused in QueryBuilder and MappingProvider.
  # The last column 'group_id' has a special meaning - every two entries that have the same group_id form a pair of
  # a unique organization and its duplicate. Based on that, it is possible to measure the quality of elasticsearch
  # queries used for finding duplicates, and gather overall statistics.
  opt :filename, 'Path to test-data filename', default: 'data/testdata.txt'
  # nil means all
  opt :count, 'Number of test entries to process', type: Integer, default: nil
  opt :url, 'URL to elasticsearch server', default: 'http://localhost:9200'
  # Evaluating whether a search query result is a duplicate of a given organization is based on a static cut-off
  # threshold. It's an essential modifier to the deduplication algorithm.
  opt :threshold, 'elasticsearch scoring threshold for differentiating between a duplicate and a unique item',
      default: 1.0
  opt :index, 'Name of elasticsearch index to use', default: 'duplitector'
  opt :verbose, 'Prints more information'
end

log = Logger.new(STDOUT)
# use DEBUG for more detailed log information
log.level = if opts[:verbose] then Logger::DEBUG else Logger::INFO end
log.datetime_format = "%H:%M:%S"

organizations = TestData.new(log).read_organizations opts[:filename], opts[:count]
log.info ''

client = ClientWrapper.new(opts[:url], opts[:index], log)
stats = Stats.new
deduplicator = Deduplicator.new(stats, log, client, opts[:threshold])
normalizer = Normalizer.new

organizations.each do |org|
  normalizer.normalize org
  deduplicator.dedupe org
  log.info ''
end

QualityMeasurer.new(client, log).measure

log.info ''
log.info "Done. Stats: #{stats}"
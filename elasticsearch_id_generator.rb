class ElasticsearchIdGenerator
  @@id = 0

  def self.get_next
    @@id += 1
  end
end
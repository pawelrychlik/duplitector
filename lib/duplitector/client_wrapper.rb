class ClientWrapper

  def initialize(url, index, log)
    @log = log
    @idx = index
    @server = Stretcher::Server.new(url, logger: log)

    # Prepare an empty index
    @server.index(@idx).delete rescue nil
    @server.index(@idx).create()
    sleep 1
  end

  def create_mapping(mapping)
    @server.index(@idx).type(@idx).put_mapping(mapping)
  end

  def put(id, document)
    @server.index(@idx).type(@idx).put(id, document)
  end

  def search(query)
    @server.index(@idx).type(@idx).search({}, query)
  end

  def all
    @server.index(@idx).type(@idx).search({ size: 1000000 }, nil)
  end

  def refresh
    @server.index(@idx).refresh
  end
end
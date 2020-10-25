class WalletServer
  attr_accessor :port, :gateway

  def initialize(port, gateway)
    @port = port
    @gateway = gateway
  end

  def index(req)
    case req.request_method
    when "GET"

    else
      p "ERROR: Invalid HTTP Method!!!!"
    end
  end
end
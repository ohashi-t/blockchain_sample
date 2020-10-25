require 'pry'

class BlockchainServer
  require_relative '../wallet/wallet'
  require_relative '../block/blockchain'

  attr_accessor :port

  def initialize(port)
    @port = port
  end

  def get_blockchain
    unless $cache[:blockchain]
      miners_wallet = Wallet.new
      bc = Blockchain.new_blockchain(miners_wallet.blockchain_address, self.port)
      $cache[:blockchain] = bc
      p "private_key: #{miners_wallet.private_str}"
      p "public_key: #{miners_wallet.public_str}"
      p "blockchain_address: #{miners_wallet.blockchain_address}"
      bc
    end
    $cache[:blockchain]
  end

  def get_chain(req)
    case req.request_method
    when "GET"
      bc = self.get_blockchain
      bc.get_chain_json
    else
      p "ERROR: Invalid HTTP Method!!!!"
    end
  end
end
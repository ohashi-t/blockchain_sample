require 'webrick'
require 'pry'
require_relative '../block/blockchain'
require_relative 'blockchain_server'
require_relative '../block/transaction_request'

$cache = {}

srv = WEBrick::HTTPServer.new(
  DocumentRoot: './',
  BindAddress: "127.0.0.1",
  Port: ARGV[0],
)
# binding.pry
BlockchainServer.new(srv.config[:Port]).get_blockchain.start_sync_neighbors

srv.mount_proc("/") do |req, res|
  BlockchainServer.new(srv.config[:Port]).get_chain(req).each do |block_json|
    res.body << block_json
  end
  res.content_type = "application/json"
end

srv.mount_proc("/transactions") do |req, res|
  case req.request_method
  when "GET"
    bc = BlockchainServer.new(ARGV[0]).get_blockchain
    res.body = bc.transaction_json
    res.content_type = "application/json"
  when "POST"
    t = B::TransactionRequest.new(JSON.parse(req.body))

    if !t.validate?
      res.status = 404
      res.body = "params is invalid!"
      return
    end

    bc = BlockchainServer.new(ARGV[0]).get_blockchain
    is_created = bc.create_transaction(t.sender_blockchain_address, t.recipient_blockchain_address, t.value, t.sender_public_key, t.signature)

    if is_created
      res.status = 201
      res.body = "success!!!!"
    else
      res.status = 404
      res.body = "failed..."
    end
  else
    res.status = 404
    res.body = "Can't attached this connection."
  end
end

srv.mount_proc("/mine") do |req, res|
  case req.request_method
  when "GET"
    bc = BlockchainServer.new(ARGV[0]).get_blockchain
    is_mined = bc.mining
    if is_mined
      res.status = 200
      res.body = "success!!!!"
    else
      res.status = 404
      res.body = "failed...."
    end
  end
end

srv.mount_proc("/start") do |req, res|
  case req.request_method
  when "GET"
    bc = BlockchainServer.new(ARGV[0]).get_blockchain
    bc.start_mining
      res.status = 200
      res.body = "success!!!!"
  end
end

srv.mount_proc("/amount") do |req, res|
  case req.request_method
  when "GET"
    bc = req.query["blockchain_address"]
    amount = BlockchainServer.new(ARGV[0]).get_blockchain.total_amount_json(bc)
    res.body = amount
    res.content_type = "application/json"
  else
    p "ERROR: Invalid HTTP Method!"
  end
end

srv.start
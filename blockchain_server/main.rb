require 'webrick'
require 'pry'
require_relative '../block/blockchain'
require_relative 'blockchain_server'
require_relative '../block/transaction_request'

$cache = {}

module WEBrick
  module HTTPServlet
    class ProcHandler < AbstractServlet
      alias do_PUT    do_GET
      alias do_DELETE do_GET
    end
  end
end

srv = WEBrick::HTTPServer.new(
  DocumentRoot: './',
  BindAddress: "127.0.0.1",
  Port: ARGV[0],
)
# binding.pry

srv.mount_proc("/") do |req, res|
  chain = BlockchainServer.new(srv.config[:Port]).get_blockchain.chain
  res.body << Base64.encode64(Marshal.dump(chain))
  res.content_type = "text/html"
end

srv.mount_proc("/chain") do |req, res|
  res.body << BlockchainServer.new(srv.config[:Port]).get_chain(req)
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
  when "PUT"
    t = B::TransactionRequest.new(JSON.parse(req.body))

    if !t.validate?
      res.status = 404
      res.body = "params is invalid!"
      return
    end

    bc = BlockchainServer.new(ARGV[0]).get_blockchain
    is_updated = bc.add_transaction(t.sender_blockchain_address, t.recipient_blockchain_address, t.value, t.sender_public_key, t.signature)

    if is_updated
      res.status = 200
      res.body = "success!!!!"
    else
      res.status = 404
      res.body = "failed..."
    end
  when "DELETE"
    bc = BlockchainServer.new(ARGV[0]).get_blockchain
    bc.transaction_pool.clear
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

srv.mount_proc("/consensus") do |req, res|
  case req.request_method
  when "PUT"
    bc = BlockchainServer.new(srv.config[:Port]).get_blockchain
    replaced = bc.resolve_conflicts
    res.body = replaced ? "success!!" : "failed..."
    res.content_type = "application/json"
  else
    p "ERROR: Invalid HTTP Method"
    res.status = 404
  end
end

Thread.new { BlockchainServer.new(srv.config[:Port]).get_blockchain.start_sync_neighbors }
Thread.new do
  sleep 20
  BlockchainServer.new(srv.config[:Port]).get_blockchain.resolve_conflicts
end

srv.start



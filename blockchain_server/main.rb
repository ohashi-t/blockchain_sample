require 'webrick'
require 'pry'
require_relative '../block/blockchain'
require_relative 'blockchain_server'

$cache = {}

srv = WEBrick::HTTPServer.new(
  DocumentRoot: './',
  BindAddress: "127.0.0.1",
  Port: ARGV[0],
)
# binding.pry
srv.mount_proc("/") do |req, res|
  BlockchainServer.new(srv.config[:Port]).get_chain(req).each do |block_json|
    res.body << block_json
  end
  res.content_type = "application/json"
end

srv.start
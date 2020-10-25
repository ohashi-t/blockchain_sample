require 'pry'
require 'webrick'
require 'slim'
require_relative 'wallet_server'
require_relative '../wallet/wallet'

srv = WEBrick::HTTPServer.new(
  DocumentRoot: './',
  BindAddress: "127.0.0.1",
  Port: ARGV[0],
)

w = WalletServer.new(ARGV[0], ARGV[1])
# binding.pry

# srv.mount_proc("/") do |_req, res|
#   res.body = Slim::Template.new("./templates/index.html.slim").render
#   res.content_type = "text/html"
# end

srv.mount("/", WEBrick::HTTPServlet::FileHandler, "./templates/index.html")

srv.mount_proc("/wallet") do |req, res|
  case req.request_method
  when "POST"
    my_wallet = Wallet.new
    json_data = my_wallet.attr_json
    res.body = json_data
    res.content_type = "application/json"
  else
    p "ERROR: Invalid HTTP Method!!!!"
    res.body = { status: 404 }.to_json
  end
end

srv.start
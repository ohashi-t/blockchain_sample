require 'pry'
require 'webrick'
require 'faraday'
require 'slim'
require_relative 'wallet_server'
require_relative '../wallet/wallet'
require_relative 'transaction_request'

srv = WEBrick::HTTPServer.new(
  DocumentRoot: './',
  BindAddress: "127.0.0.1",
  Port: ARGV[0],
)

w = WalletServer.new(ARGV[0], ARGV[1])

# "http://#{srv[:BindAddress]}:#{srv[:Port]}"

# srv.mount_proc("/") do |_req, res|
#   res.body = Slim::Template.new("./templates/index.html.slim").render
#   res.content_type = "text/html"
# end

srv.mount("/", WEBrick::HTTPServlet::FileHandler, "./templates/index.html")

srv.mount_proc("/wallet") do |req, res|
  case req.request_method
  when "POST"
    res.body = Wallet.new.attr_json
    res.content_type = "application/json"
  else
    p "ERROR: Invalid HTTP Method!!!!"
    res.status = 404
  end
end

srv.mount_proc("/transaction") do |req, res|
  if req.request_method == "POST"
    tr = TransactionRequest.new(JSON.parse(req.body))
    check = true
    if !tr.validate?
      p "ERROR: missing fields"
      res.status = 404
      check = false
    end

    if !tr.floatable?
      p "ERROR: Invalid value_strings!"
      res.status = 404
      check = false
    end

    if check
      # p tr.sender_private_key
      # p tr.sender_public_key
      # p tr.sender_blockchain_address
      # p tr.recipient_blockchain_address
      # p tr.value
      # res.status = 200

      t = W::Transaction.new(tr.sender_private_key, tr.sender_public_key, tr.sender_blockchain_address, tr.recipient_blockchain_address, tr.value)
      response = Faraday.post("http://127.0.0.1:5000/transactions", t.send_json)
      if response.status == 201
        res.body = "success!!!!"
        res.status = 200
      else
        res.body = "failed..."
        res.status = 404
      end
    end
  else
    p "ERROR: Invalid HTTP Method!!!!"
    res.status = 404
  end
end

srv.mount_proc("/wallet_amount") do |req, res|
  case req.request_method
  when "GET"
    bc_address = req.query["blockchain_address"].chomp.gsub(/\n/, ' ')
    response = Faraday.get("http://127.0.0.1:5000/amount", "blockchain_address" => bc_address)
    if response.success?
      res.status = 200
      res.body = response.body
    else
      res.status = 404
      res.body = "failed..."
    end
  end
end

srv.start
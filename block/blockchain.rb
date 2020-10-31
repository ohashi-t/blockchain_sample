require 'pry'
require 'base64'
require 'openssl'
include OpenSSL::PKey
require_relative '../utils/neighbor'

class Blockchain
  require_relative 'block'
  require_relative 'transaction'
  require_relative 'transaction_request'
  require 'faraday'

  MINING_SENDER = "THE BLOCKCHAIN"
  MINING_REWARD = 1.0
  MINING_DIFFICULTY = 3
  MINING_TIMER_SEC = 20

  BLOCKCHAIN_PORT_RANGE_START = 5000
  BLOCKCHAIN_PORT_RANGE_END = 5003
  NEIGHBOR_IP_RANGE_START = 0
  NEIGHBOR_IP_RANGE_END = 1
  BLOCKCHAIN_NEIGHBOR_SYNC_TIME_SEC = 20

  attr_accessor :chain, :transaction_pool, :blockchain_address, :port, :mux, :neighbors, :mux_neighbors

  def initialize(blockchain_address, port)
    @chain = []
    @transaction_pool = []
    # 誰がマイニングしたか
    @blockchain_address = blockchain_address
    @port = port
    @mux = Thread::Mutex.new
    @neighbors = []
    @mux_neighbors = Thread::Mutex.new
  end

  def self.new_blockchain(blockchain_address, port)
    b = Block.new(0, "Init hash", [])
    bc = self.new(blockchain_address, port)
    bc.create_block(0, b.hashed)
    bc
  end

  def set_neighbors
    self.neighbors = Neighbor.new.find_neighbors(Neighbor.new.get_host, self.port, NEIGHBOR_IP_RANGE_START, NEIGHBOR_IP_RANGE_END, BLOCKCHAIN_PORT_RANGE_START, BLOCKCHAIN_PORT_RANGE_END)
    p self.neighbors
  end

  def sync_neighbors
    self.mux_neighbors.synchronize do
      self.set_neighbors
    end
  end

  def start_sync_neighbors
    Thread.new { self.sync_neighbors }
    sleep BLOCKCHAIN_NEIGHBOR_SYNC_TIME_SEC
    start_sync_neighbors
  end

  def create_block(nonce, previous_hash)
    b = Block.new(nonce, previous_hash, self.transaction_pool)
    self.chain << b
    self.transaction_pool.clear
    self.neighbors.each do |n|
      res = Faraday.delete("http://#{n}/transactions")
      p res.body
    end
    b
  end

  def transaction_json
    {
      transactions: self.transaction_pool.map(&:make_hash),
      length: self.transaction_pool.size
    }.
    to_json
  end

  def create_transaction(sender, recipient, value, sender_public_key, signature)
    is_transacted = add_transaction(sender, recipient, value, sender_public_key, signature)
    if is_transacted
      self.neighbors.each do |n|
        bt = B::TransactionRequest.new({
                                 sender_blockchain_address: sender,
                                 recipient_blockchain_address: recipient,
                                 sender_public_key: sender_public_key,
                                 signature: signature,
                                 value: value
                               }.transform_keys(&:to_s))
        res = Faraday.put("http://#{n}/transactions", bt.attr_json)
        p res.body
      end
    end
    is_transacted
  end

  def add_transaction(sender, recipient, value, sender_public_key = nil, signature = nil)
    t = B::Transaction.new(sender, recipient, value)

    if sender == MINING_SENDER
      self.transaction_pool << t
      return true
    end
    if self.verify_transaction_signature(sender_public_key, signature, t.make_json)
      # デモなのでコメントアウト
      # if self.calculate_total_amount(sender) < value
      #   p "ERROR: Not enough balance in a wallet!!!!"
      #   return false
      # end
      self.transaction_pool << t
      return true
    else
      p "ERROR: Verify Transaction!!!!"
    end
    return false
  end

  def verify_transaction_signature(sender_public_key, signature, transaction)
    RSA.new(sender_public_key).verify("sha256", Base64.decode64(signature), transaction)
  end

  def valid_proof(nonce, previous_hash, transactions, difficulty)
    zeros = "0" * difficulty
    guess_block = Block.new(nonce, previous_hash, transactions, 0)
    guess_hash_str = guess_block.hashed
    guess_hash_str[0, MINING_DIFFICULTY] == zeros
  end

  def proof_of_work
    transactions = self.transaction_pool
    previous_hash = self.chain.last.hashed
    nonce = 0
    until self.valid_proof(nonce, previous_hash, transactions, MINING_DIFFICULTY)
      nonce += 1
    end
    nonce
  end

  def mining
    self.mux.synchronize do
      return false if self.transaction_pool.empty?

      self.add_transaction(MINING_SENDER, self.blockchain_address, MINING_REWARD)
      nonce = self.proof_of_work
      previous_hash = self.chain.last.hashed
      self.create_block(nonce, previous_hash)
      p "action=mining, status=success"
      true
    end
  end

  def start_mining
    Thread.new { self.mining }
    sleep 20
    start_mining
  end

  def calculate_total_amount(bc_address)
    total_amount = 0.0
    self.chain.each do |block|
      block.transactions.each do |t|
        value = t.value.to_f
        total_amount += value if bc_address == t.recipient_blockchain_address
        total_amount -= value if bc_address == t.sender_blockchain_address
      end
    end
    total_amount
  end

  def total_amount_json(bc_address)
    {
      amount: calculate_total_amount(bc_address)
    }.
    to_json
  end

  def copy_transaction_pool
    self.transaction_pool.dup.map(&:dup)
  end

  def print_on
    self.chain.each_with_index do |c, i|
      p "#{'='*25} Chain#{i} #{'='*25}"
      c.print_on
    end
    p "*" * 25
  end

  def get_chain_json
    chain_json = []
    self.chain.each do |block|
      chain_json << {
                      nonce: block.nonce,
                      previous_hash: block.previous_hash,
                      transactions: block.transactions,
                      timestamp: block.timestamp
                    }.
                    to_json
    end
    chain_json
  end

end

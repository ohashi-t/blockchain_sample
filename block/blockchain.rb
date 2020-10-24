class Blockchain
  require_relative 'block'
  require_relative 'transaction'

  attr_accessor :chain, :transaction_pool, :blockchain_address

  def initialize(blockchain_address)
    @chain = []
    @transaction_pool = []
    # 誰がマイニングしたか
    @blockchain_address = blockchain_address
  end

  def self.new_blockchain(blockchain_address)
    b = Block.new(0, "Init hash", [])
    bc = self.new(blockchain_address)
    bc.create_block(0, b.hashed)
    bc
  end

  def create_block(nonce, previous_hash)
    b = Block.new(nonce, previous_hash, self.transaction_pool)
    self.chain << b
    self.transaction_pool.clear
  end

  def add_transaction(sender, recipient, value)
    t = Transaction.new(sender, recipient, value)
    self.transaction_pool << t
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
    self.add_transaction(MINING_SENDER, self.blockchain_address, MINING_REWARD)
    nonce = self.proof_of_work
    previous_hash = self.chain.last.hashed
    self.create_block(nonce, previous_hash)
    p "action=mining, status=success"
    true
  end

  def calculate_total_amount(bc_address)
    total_amount = 0.0
    self.chain.each do |block|
      block.transactions.each do |t|
        value = t.value
        total_amount += value if bc_address == t.recipient_blockchain_address
        total_amount -= value if bc_address == t.sender_blockchain_address
      end
    end
    total_amount
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

end

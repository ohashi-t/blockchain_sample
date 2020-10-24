require './block'
require './transaction'
require 'pry'

class Blockchain
  MINING_DIFFICULTY = 3
  attr_accessor :chain, :transaction_pool

  def initialize
    @chain = []
    @transaction_pool = []
  end

  def self.new_blockchain
    b = Block.new(0, "Init hash", [])
    bc = self.new
    bc.create_block(0, b.hashed)
    bc
  end

  def create_block(nonce, previous_hash)
    b = ::Block.new(nonce, previous_hash, self.transaction_pool)
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
    until valid_proof(nonce, previous_hash, transactions, MINING_DIFFICULTY)
      nonce += 1
    end
    nonce
  end

  def copy_transaction_pool
    @transaction_pool.dup.map(&:dup)
  end

  def print_on
    self.chain.each_with_index do |c, i|
      p "#{'='*25} Chain#{i} #{'='*25}"
      c.print_on
    end
    p "*" * 25
  end

end
bc = Blockchain.new_blockchain
bc.print_on

bc.add_transaction("A", "B",1.0)

bc.create_block(bc.proof_of_work, bc.chain.last.hashed)
# binding.pry
bc.print_on

bc.add_transaction("C", "D", 2.0)
bc.add_transaction("X", "Y", 3.0)
bc.create_block(bc.proof_of_work, bc.chain.last.hashed)
bc.print_on
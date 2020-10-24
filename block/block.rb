require 'digest'

class Block
  attr_accessor :nonce, :timestamp, :previous_hash, :transactions
  def initialize(nonce, previous_hash, transactions, timestamp = Time.now.to_i)
    @nonce = nonce
    @previous_hash = previous_hash
    @transactions = transactions.dup.map(&:dup)
    @timestamp = timestamp
  end

  def hashed
    m = Marshal.dump(self)
    ::Digest::SHA256.hexdigest(m)
  end

  def print_on
    p "time-> #{self.timestamp}"
    p "nonce-> #{self.nonce}"
    p "previous_hash->#{self.previous_hash}"
    self.transactions.each do |t|
      t.print_on
    end
  end
end

# block = Block.new(0, "init hash")
# p block.hashed
# block.print_on
require 'pry'

# OpenSSL::Random.seed(File.read("/dev/random", 16))
# rsa = OpenSSL::PKey::RSA.generate(2048)
# public_key = rsa.public_key
# binding.pry
# # 秘密鍵で署名
# data = "foobar"
# sign = rsa.sign("sha256", data)
# # 公開鍵で検証
# p public_key.verify("sha256", sign, data)
# # 不正なデータを検証
# p public_key.verify("sha256", sign, "foobarbaz")

class Wallet
  require 'openssl'
  require 'json'
  require_relative 'transaction'

  attr_accessor :private_key, :public_key, :blockchain_address

  def initialize
    @private_key = self.class.generate_private_key
    @public_key = @private_key.public_key
    @blockchain_address = public_str
  end

  def new_transaction(recipient, value)
    W::Transaction.new(self.private_key, self.public_key, self.blockchain_address, recipient, value)
  end

  def public_str
    public_key.to_s
  end

  class << self
    def generate_private_key
      OpenSSL::Random.seed(File.read("/dev/random", 16))
      OpenSSL::PKey::RSA.generate(2048)
    end
  end

  private
    def private_str
      private_key.to_s
    end
end

w = Wallet.new
t = w.new_transaction("B", 1.0)
p "signature: #{t.generate_signature}"
# w = Wallet.new
# binding.pry
# p w
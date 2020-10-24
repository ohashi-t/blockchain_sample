module W
  class Transaction
    attr_accessor :sender_private_key, :sender_blockchain_address, :recipient_blockchain_address, :value

    def initialize(private_key,  public_key, sender, recipient, value)
      @sender_private_key = private_key
      @sender_public_key = public_key
      @sender_blockchain_address = sender
      @recipient_blockchain_address = recipient
      @value = value
    end

    def generate_signature
      m = {
        sender_blockchain_address: self.sender_blockchain_address,
        recipient_blockchain_address: self.recipient_blockchain_address,
        value: self.value,
      }.to_json
      signed = self.sender_private_key.sign("sha256", m)
    end
  end
end
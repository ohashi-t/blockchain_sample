module B
  class Transaction
    attr_accessor :sender_blockchain_address, :recipient_blockchain_address, :value
    def initialize(sender, recipient, value)
      @sender_blockchain_address = sender
      @recipient_blockchain_address = recipient
      @value = value
    end

    def make_json
      {
        sender_blockchain_address: self.sender_blockchain_address,
        recipient_blockchain_address: self.recipient_blockchain_address,
        value: self.value,
      }.to_json
    end

    def print_on
      p "-" * 40
      p self.sender_blockchain_address
      p self.recipient_blockchain_address
      p self.value
    end
  end
end
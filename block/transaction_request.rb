module B
  class TransactionRequest
    attr_accessor :sender_blockchain_address, :recipient_blockchain_address, :sender_public_key, :value, :signature
    def initialize(req)
      @sender_blockchain_address = req["sender_blockchain_address"]
      @recipient_blockchain_address = req["recipient_blockchain_address"]
      @sender_public_key = req["sender_public_key"]
      @value = req["value"]
      @signature = req["signature"]
    end

    def attr_json
      {
        sender_blockchain_address: sender_blockchain_address,
        recipient_blockchain_address: recipient_blockchain_address,
        sender_public_key: sender_public_key,
        value: value,
        signature: signature
      }.to_json
    end

    def validate?
      if signature.nil? ||
        signature.empty? ||
        sender_public_key.nil? ||
        sender_public_key.empty? ||
        sender_blockchain_address.nil? ||
        sender_blockchain_address.empty? ||
        recipient_blockchain_address.nil? ||
        recipient_blockchain_address.empty? ||
        value.nil? ||
        value.empty?
        return false
      end
      true
    end
  end
end
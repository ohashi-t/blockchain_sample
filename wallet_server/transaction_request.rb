require 'pry'
class TransactionRequest
  attr_reader :sender_private_key, :sender_public_key, :sender_blockchain_address, :recipient_blockchain_address, :value
  def initialize(req)
    @sender_private_key = req["sender_private_key"]
    @sender_public_key = req["sender_public_key"]
    @sender_blockchain_address = req["sender_blockchain_address"]
    @recipient_blockchain_address = req["recipient_blockchain_address"]
    @value = req["value"]
  end

  def validate?
    if sender_private_key.nil? ||
       sender_private_key.empty? ||
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

  def attr_json
    {
      sender_private_key: sender_private_key,
      sender_public_key: sender_public_key,
      sender_blockchain_address: sender_blockchain_address,
      recipient_blockchain_address: recipient_blockchain_address,
      value: value
    }.
    to_json
  end

  def floatable?
    !!Float(value)
  rescue
    false
  end
end
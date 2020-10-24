require './block/blockchain'
require './wallet/wallet'
MINING_DIFFICULTY = 3
MINING_SENDER = "THE BLOCKCHAIN"
MINING_REWARD = 1.0

# my_blockchain_address = "my_blockchain_address"
#
# bc = Blockchain.new_blockchain(my_blockchain_address)
# bc.print_on
#
# bc.add_transaction("A", "B",1.0)
# bc.mining
# bc.print_on
#
# bc.add_transaction("C", "D", 2.0)
# bc.add_transaction("X", "Y", 3.0)
# bc.mining
# bc.print_on
#
# p "my: #{bc.calculate_total_amount("my_blockchain_address")}"
# p "C: #{bc.calculate_total_amount("C")}"
# p "D: #{bc.calculate_total_amount("D")}"

walletM = Wallet.new
walletA = Wallet.new
walletB = Wallet.new

t = walletA.new_transaction(walletB.blockchain_address, 1.0)

bc = Blockchain.new_blockchain(walletM.blockchain_address)
is_added = bc.add_transaction(walletA.blockchain_address, walletB.blockchain_address, 1.0, walletA.public_key, t.generate_signature)
p "Added? #{is_added}"

bc.mining
bc.print_on

p "A: #{bc.calculate_total_amount(walletA.blockchain_address)}"
p "B: #{bc.calculate_total_amount(walletB.blockchain_address)}"
p "M: #{bc.calculate_total_amount(walletM.blockchain_address)}"
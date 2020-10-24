require './block/blockchain.rb'

MINING_DIFFICULTY = 3
MINING_SENDER = "THE BLOCKCHAIN"
MINING_REWARD = 1.0

my_blockchain_address = "my_blockchain_address"

bc = Blockchain.new_blockchain(my_blockchain_address)
bc.print_on

bc.add_transaction("A", "B",1.0)
bc.mining
bc.print_on

bc.add_transaction("C", "D", 2.0)
bc.add_transaction("X", "Y", 3.0)
bc.mining
bc.print_on

p "my: #{bc.calculate_total_amount("my_blockchain_address")}"
p "C: #{bc.calculate_total_amount("C")}"
p "D: #{bc.calculate_total_amount("D")}"
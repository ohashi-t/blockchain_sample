# 起動方法
block_chain_sample配下でforeman start  
  
wallet_server(port:8080)  
blockchain_server(port:5000)  
blockchain_server(port:5001)  
blockchain_server(port:5002)  
  
が起動する

# 操作方法　
:8080/叩くと送金の際に必要となる情報(public_key, private_key, address)が発行される  
  
この時点ではいずれのblockchain_server(以下説明にport:5000を使用)ブロックチェーンには初期値しか格納されていない(:5000/chain)

SendMoneyのaddress欄に相手側のaddress
amount欄に送金する金額
を指定してsendボタンクリックすると送金の処理が実行される

(:5000/transactions)  
でtransaction_poolに溜まっているtransactionが確認できる  
  
:5000/mine(手動でマイニング)  
:5000/start(設定値毎に自動でマイニング)  
  
マイニング後はtransaction_poolが空になる
全blockchain_serverでtransaction_poolの情報が共有され、空であることが確認できる。
(:5000/transactions)  
  
:5000/chainを叩くと送金した情報(自分・相手のaddress, 送金金額)が追加されているのが確認できる。
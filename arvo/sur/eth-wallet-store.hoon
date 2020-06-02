/-  ethers
|%
+$  poke
  $%  [$send-eth txn=[to=@ux amount=@ud]]
      [$send-erc20 txn=[=contract-id to=@ux amount=@ud]]
      [$add-erc20 =contract-id name=@t =address:ethereum]
      [$set-key key-path=path]
  ==
+$  gift
  $%  [$initial =address:ethereum eth-balance=@ud =contracts-map =eth-pending-txs =eth-txn-log]
      [$tx-fail =contract-id txh=@ux]
      [$txh =contract-id txh=@ux from=@ux to=@ux amount=@ud]
      [$eth-balance bal=@ud]
      [$eth-send-rez rez=send-eth-rez:ethers]
      [$eth-tx-fail txh=@ux]
  ==
+$  pending  [txh=(unit @ux) from=@ux to=@ux amount=@ud]
+$  txn  [block=@ud txh=@ux log-index=@ud from=@ux to=@ux amount=@ud]
+$  txn-log  (list txn)
+$  contract-id  @t
+$  contract-data
  $:  name=@t
      =address:ethereum
      balance=@ud
      =txn-log
      pending-txs=(map tid=@ta pending)
  ==
+$  contracts-map  (map contract-id contract-data)
+$  eth-txn  [block=@ud txh=@ux to=@ux amount=@ud]
+$  eth-pending  [txh=(unit @ux) to=@ux amount=@ud]
+$  eth-pending-txs  (map tid=@ta eth-pending)
+$  eth-txn-log  (list eth-txn)
--

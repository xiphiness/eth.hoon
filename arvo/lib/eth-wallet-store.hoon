/-  *eth-wallet-store
/+  ethers
::  throughout: hashes & addresses should have minimum length
::  i.e. not use z-co, probably also length.
::  should maybe eth capitalization validity check for pokes from client
::  or on client side
|%
++  jsonify-poke
  |=  jon=json
  =,  dejs:format
  ^-  poke
  |^
    =/  [type=@t payload=json]  (parse-poke jon)
    ?+  type  ~|  "unexpected type"  !!
        %send-eth
      [%send-eth (parse-send-eth payload)]
        %add-erc20
      [%add-erc20 (parse-add-erc20 payload)]
        %send-erc20
      [%send-erc20 (parse-send-erc20 payload)]
    ==
  ++  parse-poke
    %-  ot
    :~  type+so
        payload+same
    ==
  ++  parse-send-eth
    %-  ot
    :~  to+json-to-ux
        value+ni
    ==
  ++  parse-add-erc20
    %-  ot
    :~  symbol+so
        name+so
        address+json-to-ux
    ==
  ++  parse-send-erc20
    %-  ot
    :~  symbol+so
        to+json-to-ux
        value+ni
    ==
  ++  json-to-ux
    |=  =json
    ^-  @ux
    (scan (trip (so json)) ;~(pfix (jest '0x') hex))
  --
::
++  update-to-json
  |=  =gift
  =,  enjs:format
  ^-  json
  ?-  -.gift
      %initial
    |^
      %+  frond  %initial
      %-  pairs
      :~  [%owner s+(crip (z-co:co address.gift))]
          ['ethBalance' s+(crip ((d-co:co 1) eth-balance.gift))]
          [%contracts enc-contracts]
          ['ethPending' enc-eth-pending]
          ['ethTxnLog' enc-eth-txn-log]
      ==
    ++  enc-eth-pending
      ^-  json
      :-  %a
      %+  turn  (skim ~(tap by eth-pending-txs.gift) |=([@ pending=eth-pending] ?=([~ *] txh.pending)))
      |=  [tid=@ta pending=eth-pending]
      %-  pairs
      :~  ['txHash' ?~(txh.pending ~ s+(crip (z-co:co u.txh.pending)))]
          to+s+(crip (z-co:co to.pending))
          value+s+(crip ((d-co:co 1) amount.pending))
      ==
    ++  enc-eth-txn-log
      ^-  json
      :-  %a
      %+  turn  eth-txn-log.gift
      |=  [block=@ud txh=@ux to=@ux amount=@ud]
      %-  pairs
      :~  block+s+(crip ((d-co:co 1) block))
          ['txHash' `json`s+(crip (z-co:co txh))]
          to+`json`s+(crip (z-co:co to))
          value+`json`s+(crip ((d-co:co 1) amount))
      ==
    ++  enc-contracts
      ^-  json
      :-  %a
      %+  turn  ~(tap by contracts-map.gift)
      |=  $:  =contract-id
              name=@t
              =address:ethereum
              balance=@ud
              =txn-log
              pending-txs=(map tid=@ta pending)
        ==
      %-  pairs
      :~  [%address [%s (crip (z-co:co address))]]
          [%symbol [%s contract-id]]
          [%name [%s name]]
          [%balance [%n (crip ((d-co:co 1) balance))]]
          pending+(enc-pending pending-txs)
          ['txnLog' (enc-txn-log txn-log)]
      ==
    ++  enc-pending
      |=  pending-txs=(map @ta pending)
      ^-  json
      :-  %a
      %+  turn  (skim ~(tap by pending-txs) |=([@ =pending] ?=([~ *] txh.pending)))
      |=  [tid=@ta =pending]
      %-  pairs
      :~  ['txHash' ?~(txh.pending ~ s+(crip (z-co:co u.txh.pending)))]
          from+s+(crip (z-co:co from.pending))  :: should actually use x-co at addr length
          to+s+(crip (z-co:co to.pending))
          value+s+(crip ((d-co:co 1) amount.pending))
      ==

    ++  enc-txn-log
      |=  =txn-log
      ^-  json
      :-  %a
      %+  turn  txn-log
      |=  [block=@ud txh=@ux log-index=@ud from=@ux to=@ux amount=@ud]
      %-  pairs
      :~  block+s+(crip ((d-co:co 1) block))
          ['txHash' s+(crip (z-co:co txh))]
          log-index+s+(crip ((d-co:co 1) log-index))
          from+s+(crip (z-co:co from))  :: should actually use x-co at addr length
          to+s+(crip (z-co:co to))
          value+s+(crip ((d-co:co 1) amount))
      ==
    --
  ::
      %eth-balance
    %+  frond  %eth-balance
    s+(crip ((d-co:co 1) bal.gift))
  ::
      %eth-send-rez
    %+  frond  %eth-send-rez
    (eth-rez-to-json:ethers rez.gift)
  ::
      %eth-tx-fail
    %+  frond  %eth-tx-fail
    s+(crip (z-co:co txh.gift))
  ::
      %txh
    %+  frond  %txh
    %-  pairs
    :~  contract-id+s+contract-id.gift
        ['txHash' s+(crip (z-co:co txh.gift))]
        from+s+(crip (z-co:co from.gift))  :: should actually use x-co at addr length
        to+s+(crip (z-co:co to.gift))
        value+s+(crip ((d-co:co 1) amount.gift))
    ==
  ::
      %tx-fail
    %+  frond  %tx-fail
    %-  pairs
    :~  [%contract-id s+contract-id.gift]
        [%txh s+(crip (z-co:co txh.gift))]
    ==
  ==
--

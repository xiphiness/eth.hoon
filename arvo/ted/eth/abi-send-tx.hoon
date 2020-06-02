/-  spider
/+  ethio, strandio, eth-abi
::
/=  erc20-abi
  /;  parse-contract:eth-abi
  /:  /===/app/eth-wallet/erc20  /json/
::
=,  strand=strand:spider
=*  eth  ethereum-types
=*  eth-rpc  rpc:ethereum
=*  eth-key  key:ethereum
::
|%
++  tape-to-ux
  |=  =tape
  ^-  @ux
  %+  scan  tape
  ;~(pfix (jest '0x') hex)
++  need-call-data
  |=  =mark
  =/  m  (strand:strandio ,~)
  ^-  form:m
  |=  tin=strand-input:strand
  ?.  =(mark %eth-call-data)
    `[%fail [%unexpected-mark >mark< ~]]
  `[%done ~]
++  need-atom
  |=  wut=*
  =/  m  (strand:strandio ,@)
  ^-  form:m
  |=  tin=strand-input:strand
  ?.  ?=(@tas wut)
    `[%fail [%head-of-noun-not-an-atom >mark< ~]]
  `[%done wut]
++  need-ux-from-json
  |=  wut=json
  =/  m  (strand:strandio ,@ux)
  ^-  form:m
  |=  tin=strand-input:strand
  ?.  ?=([%s *] wut)
    `[%fail [%expected-json-string-got >wut< ~]]
  `[%done (tape-to-ux (trip p.wut))]
++  json-to-ux
  |=  =json
  %-  tape-to-ux
  %-  sa:dejs:format
  json
++  json-hex-to-bool  ::  unsafe on unexpected values
  |=  =json
  ^-  ?
  =(1 (json-to-ux json))
++  parse-receipt
  =,  dejs:format
  %-  ot
  :~  status+json-hex-to-bool
      ['blockNumber' json-to-ux]
      :: ['transactionHash' json-to-ux]
  ==
++  give-txh
  |=  txh=@ux
  =/  m  (strand ,~)
  ^-  form:m
  :: =/  =(list card:agent:gall)
  %-  send-raw-cards:strandio
  :~  [%give %fact ~[/txh] %txh !>(txh)]
      [%give %kick ~[/txh] ~]
  ==
--
|=  args=vase
=+  !<  $:  url=@t
            id=@t
            contract=address:eth
            private-key=@
            gas=@ud
            gas-price=@ud
            eth-cage=cage
            :: $~
        ==
    args
=/  m  (strand:strandio ,vase)
^-  form:m
=/  abi-name=@tas  p.eth-cage
;<  func-name=@tas  bind:m  (need-atom +<.q.eth-cage)
=.  p.eth-cage  :((cury cat 3) 'eth-contracts-' abi-name '-send')
;<  =bowl:spider  bind:m  get-bowl:strandio
;<  ~  bind:m  (build-cast:strandio [our.bowl %home] %eth-call-data eth-cage)
;<  =cage  bind:m  take-cast:strandio
;<  ~  bind:m  (need-call-data p.cage)
=+  !<(dat=call-data:eth-rpc q.cage)
:: (pure:m q.cage)
:: ;<  nonce=@ud  bind:m
=/  from=address:eth  (address-from-prv:eth-key private-key)
:: =/  public-key=@  (pub-from-prv:eth-key private-key)
:: ::
;<  nonce=@ud  bind:m  (get-next-nonce:ethio url from)
=/  data=@ux  (tape-to-ux (encode-call:eth-rpc dat))
=/  txn=transaction:eth-rpc
  :*  nonce
      gas-price
      gas
      to=contract
      value=0
      data
      chain-id=0x1337
  ==
::  warning: being very lazy here. should loop something like eth-send-txs
::  will not work on mainnet probably because will receive pendings
::  not hard to fix tho
::  probably add some behning and output %wait at block mining rate
::  maybe turn into it a thread 'app' with main loop where all tx's go
=/  signed=@ux        (sign-transaction:eth-key txn private-key)
=/  =request:eth-rpc  [%eth-send-raw-transaction signed]
;<  watch-path=path  bind:m  take-watch:strandio
;<  res=json  bind:m  (request-rpc:ethio url `id request)
::  is it better to catch all errors like this need
::  to get back a %fail or will we be ok if we just
::  add a !: stack trace in the beginning of the thread?
;<  txh=@ux  bind:m   (need-ux-from-json res)
;<  ~  bind:m  (give-txh txh)
=|  tries=@ud
|-
=*  confirm-loop  $
=/  =request:eth-rpc  [%eth-get-transaction-receipt txh]
;<  res=json  bind:m  (request-rpc:ethio url [~ (cat 3 id '-rec')] request)
?~  res
  ;<  ~  bind:m
     ?.  (lth tries 60)
       (strand-fail:strandio %tx-too-long-to-mine leaf+"hash" >txh< ~)
    (sleep:strandio ~s30)
  confirm-loop(tries +(tries))
=/  txr=[status=? block=@ux]  (parse-receipt res)
::  TODO:  ok this is just dumb, no need for +decode-rez,
:: just use the mold to grab from noun
;<  ~  bind:m  %^  build-cast:strandio  [our.bowl %home]
                 :((cury cat 3) 'eth-contracts-' abi-name '-rez')
                 [%noun !>(`noun`[func-name contract txh status.txr block.txr])]
;<  =^cage  bind:m  take-cast:strandio
(pure:m q.cage)


::  [$func-name txh=@ux status=? block=@ud tx-id=@ud]
::  transactionHash
::  blockNumber

:: gas-price=30.000.000.000
:: gas=40.000
:: -eth-abi-send-tx 'http://localhost:8545' 'newcall' pgaddr privkey gas gas-price [%erc20 !>(trs)]
::  =trs [%transfer receiver=0x9e9a.e259.7424.dbec.aef9.8a4f.d326.c76f.c841.4019 amount=123]

::-eth-abi-call 'http://localhost:8545' 'somecall' 0x91b5.17a3.e903.96ea.5ab1.4343.4dda.12b6.a678.f0cc [%erc20 !>([%balance-of 0x3739.383f.b054.3ee5.bf84.ae3b.dd1b.e0b8.b1b5.39fc])]

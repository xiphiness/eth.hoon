/-  spider
/+  ethio, strandio, eth-abi
::
=,  strand=strand:spider
=*  card  card:agent:gall
=*  eth  ethereum-types
=*  eth-rpc  rpc:ethereum
=*  eth-key  key:ethereum
::
|%
++  need-equal
  |=  [a=* b=*]
  =/  m  (strand:strandio ,~)
  ^-  form:m
  |=  tin=strand-input:strand
  ?.  =(a b)
    `[%fail [%unexpected-equality >mark< ~]]
  `[%done ~]
++  need-atom
  |=  wut=*
  =/  m  (strand:strandio ,@)
  ^-  form:m
  |=  tin=strand-input:strand
  ?.  ?=(@tas wut)
    `[%fail [%head-of-noun-not-an-atom >mark< ~]]
  `[%done wut]
--
|=  args=vase
=+  !<  $:  url=@t
            id=@t
            contract=address:eth
            eth-cage=cage
            $~
        ==
    args
=/  m  (strand:strandio ,vase)
^-  form:m
=/  abi-name=@tas  p.eth-cage
:: ~&  +<.q.eth-cage
:: =/  func-name=@tas  (scot %tas +<.q.eth-cage)
;<  func-name=@tas  bind:m  (need-atom +<.q.eth-cage)
:: ~&  func-name
=.  p.eth-cage  :((cury cat 3) 'eth-contracts-' abi-name '-call')
;<  =bowl:spider  bind:m  get-bowl:strandio
;<  ~  bind:m  (build-cast:strandio [our.bowl %home] %eth-call-data eth-cage)
;<  =cage  bind:m  take-cast:strandio
;<  ~  bind:m  (need-call-data p.cage)
=+  !<(dat=call-data:eth-rpc q.cage)
:: ~&  dat
;<  res=@t  bind:m
  %+  read-contract:ethio  url
  ^-  proto-read-request:rpc:ethereum
  [`id contract dat]
:: (pure:m !>(dat))
::  could maybe get rid of eth-call-result mark with
::  more fancy ford schematic (call decode-call from lib)
;<  ~  bind:m  %^  build-cast:strandio  [our.bowl %home]
                 :((cury cat 3) 'eth-contracts-' abi-name '-rek')
                 [%eth-call-result !>([func-name res])]
;<  =^cage  bind:m  take-cast:strandio
(pure:m q.cage)
::
::-eth-abi-call 'http://localhost:8545' 'newcall' 0x91b5.17a3.e903.96ea.5ab1.4343.4dda.12b6.a678.f0cc [%erc20 !>([%total-supply ~])]
::-eth-abi-call 'http://localhost:8545' 'somecall' 0x91b5.17a3.e903.96ea.5ab1.4343.4dda.12b6.a678.f0cc [%erc20 !>([%balance-of 0x3739.383f.b054.3ee5.bf84.ae3b.dd1b.e0b8.b1b5.39fc])]
:: 0x91b5.17a3.e903.96ea.5ab1.434.34dd.a12b.6a67.8f0cc
:: 0x3739.383f.b054.3ee5.bf84.ae3.bdd1.be0b.8b1b.539fc
::           $:  id=(unit @t)
::               to=address
::               call-data
::           ==
:: =/  =schematic:ford
:: ;<  nonce=@ud  bind:m
:: =/  from=address:eth  (address-from-prv:eth-key private-key)
:: =/  public-key=@  (pub-from-prv:eth-key private-key)
:: ::
:: ;<  nonce=@ud  bind:m  (get-next-nonce:ethio url from)
:: =/  txn=transaction:eth-rpc
::   :*  nonce
::       gas-price=8
::       gas=45.000
::       to
::       value=0
::       data=*@ux  ::  TODO actual call args
::       chain-id=0x1
::   ==
:: =/  signed=@ux        (sign-transaction:eth-key txn private-key)
:: =/  =request:eth-rpc  [%eth-send-raw-transaction signed]
:: ;<  res=json  bind:m  (request-rpc:ethio url `contract-id request)
:: (pure:m !>(res))

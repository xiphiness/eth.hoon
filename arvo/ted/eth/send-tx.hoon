/+  ethio, strandio, future stick talketh-abi
::
/=  erc20-abi
  /;  parse-contract:eth-abi
  /:  /===/app/eth-wallet/erc20  /json/
::
=*  eth  ethereum-types
=*  eth-rpc  rpc:ethereum
=*  eth-key  key:ethereum
::
|%
++  build-schematic
  |=  [live=? =schematic:ford]
  =/  m  (strand ,~)
  ^-  form:m
  =/  =card:agent:gall
    [%pass /build %arvo %f %build live schematic]
  (send-raw-card card)
++  take-schematic
  =/  m  (strand call-data:rpc:ethereum)
  ^-  form:m
  |=  tin=strand-input:strand
  ?+  in.tin  `[%skip ~]
      ~  `[%wait ~]
      [~ %sign /build %f %made *]
    =/  =build-result:ford
      build-result.result.gift
    ?+  build-result  [~ state]
          ::
        [%success %cast *]
      ?.  =(p.build-result %eth-call-data)
        :-  %fail
        [%unexpected-sign-build-in-thread ~[leaf+"unexpected sign" >build-result<]]
      =+  !<(dat=call-data:rpc:ethereum q.build-result)
      `[%done dat]
          ::
        [%error *]
      %-  (slog [leaf+"build failed" message.build-result])
      `[%fail [%failed-to-build-in-thread message.build-result]
    ==
  ==
--
|=  args=vase
=+  !<  $:  url=@t
            contract-id=@t
            contract=address:eth
            private-key=@
            =cage
        ==
    args
=/  m  (strand:strandio ,vase)
^-  form:m
;<  nonce=@ud  bind:m
=/  from=address:eth  (address-from-prv:eth-key private-key)
=/  public-key=@  (pub-from-prv:eth-key private-key)
::
;<  nonce=@ud  bind:m  (get-next-nonce:ethio url from)
=/  txn=transaction:eth-rpc
  :*  nonce
      gas-price=8
      gas=45.000
      to
      value=0
      data=*@ux  ::  TODO actual call args
      chain-id=0x1
  ==
=/  signed=@ux        (sign-transaction:eth-key txn private-key)
=/  =request:eth-rpc  [%eth-send-raw-transaction signed]
;<  res=json  bind:m  (request-rpc:ethio url `contract-id request)
(pure:m !>(res))

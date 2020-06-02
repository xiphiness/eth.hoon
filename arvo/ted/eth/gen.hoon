/-  spider
/+  eth-abi, strandio
=,  strand=strand:spider
=*  card  card:agent:gall
|%
++  write-eth-files
  |=  [bol=bowl:spider act=[name=@tas =json]]
  ^-  (list card)
  |^
    =/  =contract:eth-abi  (parse-contract:eth-abi json.act)
    =/  sur-card=card
      %+  write-file  /sur/eth-contracts/[name.act]/hoon
      [%hoon !>((code-gen-types:eth-abi name.act contract))]
    =/  lib-card=card
      %+  write-file  /lib/eth-contracts/[name.act]/hoon
      [%hoon !>((code-gen-lib:eth-abi contract name.act))]
    =/  diff-mark-card=card
      %+  write-file  /mar/[(crip (zing ~["eth-contracts-" (trip name.act) "-diff"]))]/hoon
      [%hoon !>((code-gen-diff-mark:eth-abi (trip name.act)))]
    =/  ezub-mark-card=card
      %+  write-file  /mar/[(crip (zing ~["eth-contracts-" (trip name.act) "-ezub"]))]/hoon
      [%hoon !>((code-gen-ezub-mark:eth-abi (trip name.act)))]
    =/  send-mark-card=card
      %+  write-file  /mar/[(crip (zing ~["eth-contracts-" (trip name.act) "-send"]))]/hoon
      [%hoon !>((code-gen-send-mark:eth-abi (trip name.act)))]
    =/  call-mark-card=card
      %+  write-file  /mar/[(crip (zing ~["eth-contracts-" (trip name.act) "-call"]))]/hoon
      [%hoon !>((code-gen-call-mark:eth-abi (trip name.act)))]
    =/  rez-mark-card=card
      %+  write-file  /mar/[(crip (zing ~["eth-contracts-" (trip name.act) "-rez"]))]/hoon
      [%hoon !>((code-gen-rez-mark:eth-abi (trip name.act)))]
    =/  rek-mark-card=card
      %+  write-file  /mar/[(crip (zing ~["eth-contracts-" (trip name.act) "-rek"]))]/hoon
      [%hoon !>((code-gen-rek-mark:eth-abi (trip name.act)))]
    :~  sur-card
        lib-card
        diff-mark-card
        ezub-mark-card
        send-mark-card
        call-mark-card
        rek-mark-card
        rez-mark-card
    ==
  ++  our-beak  /(scot %p our.bol)/[q.byk.bol]/(scot %da now.bol)
  ++  write-file
    |=  [pax=path cay=cage]
    ^-  card
    =.  pax  (weld our-beak pax)
    [%pass (weld /write pax) %arvo %c %info (foal:space:userlib pax cay)]
  --
:: ++  write-thread
::   |=  [name=@tas =json]
::   =/  m  (strand ,~)
::   ^-  form:m
::   |=  tin=strand-input:strand
::   (send-raw-cards:strandio (write-eth-files bowl.tin [name json]))
--
^-  thread:spider
|=  args=vase
=/  m  (strand ,vase)
^-  form:m
=+  !<([name=@tas =json $~] args)
;<  =bowl:spider  bind:m  get-bowl:strandio
;<  ~  bind:m  (send-raw-cards:strandio (write-eth-files bowl [name json]))
(pure:m !>(~))

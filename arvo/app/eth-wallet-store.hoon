/-  *eth-wallet-store, erc20=eth-contracts-erc20, eth-watcher
/+  default-agent, dbug, verb, *eth-wallet-store
=*  eth  ethereum
=*  eth-key  key:ethereum
|%
+$  card  card:agent:gall
+$  note
  $%
    [%arvo =note-arvo]
    [%agent [=ship name=term] =task:agent:gall]
  ==

+$  state-0
  $:  %0
      key-path=path
      =address:ethereum
      node-url=_'http://localhost:8545'
      eth-balance=@ud
      =contracts-map
      =eth-pending-txs
      =eth-txn-log
      history-parts=(map =contract-id loglist:erc20)
  ==
--
!:
%-  agent:dbug
=|  state-0
=*  state  -
%+  verb  &
^-  agent:gall
=<
  |_  bol=bowl:gall
  +*  this  .
      test-eth-core  +>
      tc          ~(. test-eth-core bol)
      def   ~(. (default-agent this %|) bol)

  ::
  :: Set local counter to 1 by default
  ++  on-init
    ^-  (quip card _this)
    :_  this
    [await-eth-balance:tc ~]
  :: Expose state for saving
  ++  on-save
    !>(state)
  ::
  ++  on-load
    |=  old=vase
    ^-  (quip card _this)
    `this
    :: =/  loaded=state-0
    ::   !<(state-0 old)
    :: `this(state loaded)
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?+  mark  (on-poke:def mark vase)
        %noun
      =+  !<($start-eth-balance vase)
      :_  this
      get-eth-balance:tc
        %eth-wallet-store-poke
      =/  =poke  !<(poke vase)
      =^  cards  state  (handle-poke:tc poke)
      [cards this]
        %json
      =/  =json  !<(json vase)
      =^  cards  state  (handle-poke:tc (jsonify-poke json))
      [cards this]
 ::
    ==
::

  ++  on-leave
    |=  =path
    ^-  (quip card _this)
    ~&  "Unsubscribed by: {<src.bol>} on: {<path>}"
    `this
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    ?>  (team:title our.bol src.bol)
    ?.  =(/primary path)  (on-watch:def path)
    :_  this
    [[%give %fact ~ %eth-wallet-store-gift !>(`gift`[%initial address eth-balance contracts-map eth-pending-txs eth-txn-log])] ~]
::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?+  path  ~
      [%x %address ~]
    ``atom+!>(address)
      [%x %balance ^]
    ?.  (~(has by contracts-map) i.t.t.path)  ~
    ``noun+!>((~(got by contracts-map) i.t.t.path))
    ==
::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?+  wire  (on-agent:def wire sign)
        [%eth-balance *]
      ?.  ?=(%fact -.sign)
        `this
      ?+  p.cage.sign  ~|(['unexpected sign' sign] !!)
          %thread-fail
        =+  !<([=term =tang] q.cage.sign)
        %-  =-  (slog (welp - tang))
            :~  leaf+"eth-wallet: read eth balance failed"
                :: leaf+<txn>
                leaf+<term>
            ==
          `this
          %thread-done
        =+  !<(bal=@ud q.cage.sign)
        :_  this(eth-balance bal)
        [[%give %fact ~[/primary] %eth-wallet-store-gift !>(`gift`[%eth-balance bal])] ~]
      ==
    ::
        [%xfer *]
      ?-  -.sign
          %poke-ack
        ?~  p.sign
          [~ this]
        %-  (slog leaf+"{(trip dap.bol)} couldn't start thread" u.p.sign)
        :: =.  txns.pending  (~(del by txns.pending) wire)
        :_  this
        [(leave-spider:tc wire)]~
      ::
      ::  TODO: this should probably retry the listen poke
      ::
          %watch-ack
        ?~  p.sign
          [~ this]
        ?:  ?=([%xfer %result =contract-id tid=@ta ~] wire)
          =/  =tank  leaf+"{(trip dap.bol)} couldn't start listen to thread result"
          %-  (slog tank u.p.sign)
          [~ this]
        ?:  ?=([%xfer %txh =contract-id tid=@ta ~] wire)
          =/  =tank  leaf+"{(trip dap.bol)} couldn't start listen to thread txh"
          %-  (slog tank u.p.sign)
          [~ this]
        =/  =tank  leaf+"{(trip dap.bol)} unexpected watch ack"
        %-  (slog tank u.p.sign)
        [~ this]
      ::
          %kick
        [~ this]
          %fact
        ?+  p.cage.sign   (on-agent:def wire sign)
            %txh
          =+  !<(txh=@ux q.cage.sign)
          ?:  ?=([%xfer %txh %eth-send tid=@ta ~] wire)
            =/  tid=@ta  i.t.t.t.wire
            =/  pending=eth-pending  (~(got by eth-pending-txs) tid)
            =.  eth-pending-txs
              %+  ~(put by eth-pending-txs)  tid
              pending(txh `txh)
            =/  =gift
              [%txh 'ETH' txh address to.pending amount.pending]
            :_  this
            [[%give %fact ~[/primary] %eth-wallet-store-gift !>(gift)] ~]
          ?:  ?=([%xfer %txh contract-id tid=@ta ~] wire)
            =/  [=contract-id tid=@ta ~]  t.t.wire
            =/  =contract-data  (~(got by contracts-map) contract-id)
            =/  =pending  (~(got by pending-txs.contract-data) tid)
            =.  pending-txs.contract-data
              %+  ~(put by pending-txs.contract-data)  tid
              pending(txh `txh)
            =.  contracts-map
              %+  ~(put by contracts-map)  contract-id
              contract-data
            =/  =gift
              [%txh contract-id txh from.pending to.pending amount.pending]
            :_  this
            [[%give %fact ~[/primary] %eth-wallet-store-gift !>(gift)] ~]
          ~&  ['unexpected txh' txh 'along' wire]
          `this
        ::
            %thread-fail
          :: =/  =txn  (~(got by txns.pending) wire)
          :: =.  txns.pending  (~(del by txns.pending) wire
          ?:  ?=([%xfer %result %eth-send tid=@ta ~] wire)
            =+  !<([=term =tang] q.cage.sign)
            %-  =-  (slog (welp - tang))
                :~  leaf+"eth-wallet: transaction thread failed"
                    :: leaf+<txn>
                    leaf+<term>
                ==
            =/  tid=@ta  i.t.t.t.wire
            =/  pending=eth-pending  (~(got by eth-pending-txs) tid)
            =.  eth-pending-txs
              (~(del by eth-pending-txs) tid)
            ?~  txh.pending
              [~ this]
            =/  tx-fail=gift
              [%eth-tx-fail u.txh.pending]
            :_  this
            [[%give %fact ~[/primary] %eth-wallet-store-gift !>(tx-fail)] ~]
          ?:  ?=([%xfer %result =contract-id tid=@ta ~] wire)
            =+  !<([=term =tang] q.cage.sign)
            %-  =-  (slog (welp - tang))
                :~  leaf+"eth-wallet: transaction thread failed"
                    :: leaf+<txn>
                    leaf+<term>
                ==
            =/  [=contract-id tid=@ta ~]  t.t.wire
            =/  =contract-data  (~(got by contracts-map) contract-id)
            =/  =pending  (~(got by pending-txs.contract-data) tid)
            =.  pending-txs.contract-data
              (~(del by pending-txs.contract-data) tid)
            =.  contracts-map
              %+  ~(put by contracts-map)  contract-id
              contract-data
            ?~  txh.pending
              [~ this]
            =/  tx-fail=gift
              [%tx-fail contract-id u.txh.pending]
            :_  this
            [[%give %fact ~[/primary] %eth-wallet-store-gift !>(tx-fail)] ~]
          ~&  ['unexpected thread failed on' wire]
          `this
        ::
            %thread-done
          ?:  ?=([%xfer %result %eth-send tid=@ta ~] wire)
            =/  tid=@ta  i.t.t.t.wire
            =+  !<(rez=send-eth-rez:ethers q.cage.sign)
            =/  pending=eth-pending  (~(got by eth-pending-txs) tid)
            =.  eth-pending-txs
              (~(del by eth-pending-txs) tid)
            =.  eth-balance  balance.rez
            ?:  status.rez
              =.  eth-txn-log
                :_  eth-txn-log
                [block.rez txh.rez to.pending amount.pending]
              :_  this
              [[%give %fact ~[/primary] %eth-wallet-store-gift !>(`gift`[%eth-send-rez rez])] ~]
            ~&  ["{(trip dap.bol)} transaction reverted" txh.rez]
            [~ this]
          ?:  ?=([%xfer %result =contract-id tid=@ta ~] wire)
            =/  [=contract-id tid=@ta ~]  t.t.wire
            =+  !<([=rez:erc20] q.cage.sign)
            ?:  status.rez
              [~ this]
            ~&  ["{(trip dap.bol)} transaction reverted" txh.rez]
            =/  =contract-data  (~(got by contracts-map) contract-id)
            =.  pending-txs.contract-data
              (~(del by pending-txs.contract-data) tid)
            =.  contracts-map
              %+  ~(put by contracts-map)  contract-id
              contract-data
            [~ this]
          ~&  ['unexpected thread result on' wire]
          `this
        ==
      ==
    ::
        [%eth-watcher flow=?(%from %to) =contract-id ~]
      =/  [%eth-watcher flow=?(%from %to) =contract-id ~]  wire
      ?.  ?=(%fact -.sign)
        `this
      ?+  p.cage.sign  (on-agent:def wire sign)
          %eth-contracts-erc20-diff
        =+  !<(diff=diff:erc20 q.cage.sign)
        ?-  diff
            [%history *]
          %-  (slog ~[leaf+"loglist" >loglist.diff<])
          =/  hist=(unit loglist:erc20)  (~(get by history-parts) contract-id)
          ?~  hist
            =.  history-parts
              (~(put by history-parts) contract-id loglist.diff)
            `this
          =/  =loglist:erc20
            %+  sort  (weld loglist.diff u.hist)
            order-events:tc
          =.  history-parts  (~(del by history-parts) contract-id)
          =.  state  (apply-events:tc loglist)
          :_  this
          [[%give %fact ~[/primary] %eth-contracts-erc20-diff !>(diff)] ~]
          ::=^  cards  state  (apply-events:tc loglist.diff)
          ::[cards this]
            [%log *]
          =.  state  (apply-event:tc event-log.diff)
          :_  this
          [[%give %fact ~[/primary] %eth-contracts-erc20-diff !>(diff)] ~]
          ::=^  card  state  (apply-event:tc event-log.diff)
          ::?~  card  `this
          ::[[card ~] this]
            [%disavow *]
          `this
        ==
      ==
    ::
    ==
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    ?+  +<.sign-arvo  ~|([dap.bol %strange-arvo-sign +<.sign-arvo] !!)
        %wake
      :: ?:  =(/export wire)
      ::   [[wait-export:do export:do] this]
      ?+  wire  ~|([dap.bol %strange-behn-wire wire] !!)
          [%eth-balance ~]
        :_  this
        [await-eth-balance:tc get-eth-balance:tc]
        ::
          [%awatch *]
        :_  this
        [(watch-eth-watcher:tc t.wire) ~]
      ::
          [%awatch-txh *]
        ?>  ?=([%awatch-txh contract-id tid=@ta ~] wire)
        =/  [=contract-id tid=@ta ~]  t.wire
        :_  this
        [(watch-spider:tc [%xfer %txh t.wire] /thread/[tid]/txh) ~]
      ==
    ==
  ++  on-fail  on-fail:def
  --
|_  bol=bowl:gall
++  handle-poke
  |=  =poke
  ^-  (quip card _state)
  ?-  poke
    [%send-eth *]
  =^  cards  state  (start-eth-send txn.poke)
  [cards state]
    [%send-erc20 *]
  :: =/  =txn  +.poke
  :: =/  [contract=address:eth balance=@ud]
  ::   (~(got by balances) contract-id.poke)
  :: ::  TODO: also assert balance after subtracting pending
  :: ::
  :: ?>  (gte balance amount.poke)
  :: ::
  :: =/  =wire  /xfer/[contract-id.poke]/(scot %ud next.pending)
  :: =.  next.pending  +(next.pending)
  :: =.  txns.pending  (~(put by txns.pending) wire txn)
  :: ::
  :: :_  this
  :: (start-txn-send:tc wire contract txn)
  =^  cards  state  (start-txn-send txn.poke)
  [cards state]
    [%add-erc20 *]
  ?:  =(address 0x0)  %-  (slog leaf+"expected ethereum key" ~)  `state
  ::?~  address  [~ this]
  =.  contracts-map
  %+  ~(put by contracts-map)
    contract-id.poke
  [name.poke address.poke 0 ~ ~]
  =/  from-path=path  /from/[contract-id.poke]
  =/  from-me-sub=^vase
  !>  ^-  ezub:erc20
  :+  %watch  from-path
  :*  url='http://localhost:8545'
      eager=%&
      refresh-rate=~s15
      timeout-rate=~s30
      from=0
      contracts=[address.poke ~]
      topics=~[%transfer address ~]
  ==
  =/  to-path=path  /to/[contract-id.poke]
  =/  to-me-sub=^vase
  !>  ^-  ezub:erc20
  :+  %watch  to-path
  :*  url='http://localhost:8545'
      eager=%&
      refresh-rate=~s15
      timeout-rate=~m1
      from=0
      contracts=[address.poke ~]
      topics=~[%transfer ~ address]
  ==
  :: :+  %watch  /foo
  :: :*  url='http://localhost:8545'
  ::    abi=%erc20
  ::    eager=%&
  ::    refresh-rate=~s15
  ::    timeout-rate=~m1
  ::    from=0
  ::    contracts=[0x91b5.17a3.e903.96ea.5ab1.4343.4dda.12b6.a678.f0cc ~]
  ::    topics=[%transfer ~ 0x91b5.17a3.e903.96ea.5ab1.4343.4dda.12b6.a678.f0cc ~]
  :: ==
  :_  state
  :~  :*  %pass
          /eth-config
          %agent
          [our.bol %eth-watch]
          %poke-as
          %eth-watcher-poke
          %eth-contracts-erc20-ezub
          to-me-sub
      ==
      :*  %pass
          /eth-config
          %agent
          [our.bol %eth-watch]
          %poke-as
          %eth-watcher-poke
          %eth-contracts-erc20-ezub
          from-me-sub
      ==
      (await-eth-watcher to-path)
      (await-eth-watcher from-path)
       :: [%pass /eth-config %agent [our.bol %ethers] %poke %ethers-action from-me-sub]
  ==
::
    [%set-key *]
  =/  =path  (get-path key-path.poke)
  ?>  ?=(^ =<(fil .^(arch %cy path)))
  =.  key-path  key-path.poke
  =/  new-address=@ux  (address-from-prv:eth-key fetch-key)
  `state(address new-address)
::
  ==

++  addr-to-contract
  ^-  %+  map  address:ethereum
      $:  name=@t
          =contract-id
          balance=@ud
          =txn-log
          pending-txs=(map tid=@ta pending)
      ==
  %-  molt
  %+  turn  ~(tap by contracts-map)
  |=  $:  =contract-id
          name=@t
          =address:ethereum
          balance=@ud
          =txn-log
          pending-txs=(map tid=@ta pending)
      ==
  [address [name contract-id balance txn-log pending-txs]]
++  apply-events
  |=  =loglist:erc20
  ^-  _state
  |-
  ?~  loglist  state
  $(state (apply-event i.loglist), loglist t.loglist)
++  apply-event
  |=  =event-log:erc20
  ^-  _state
  ?-  event-data.event-log
    [%approval *]
  state
    [%transfer *]
  =+  ^-
      $:  name=@t
          =contract-id
          balance=@ud
          =txn-log
          pending-txs=(map tid=@ta pending)
      ==
    (~(got by addr-to-contract) address.event-log)
  =/  new-balance=@ud
    ?:  &(=(to.event-data.event-log from.event-data.event-log) =(to.event-data.event-log address))
      balance
    ?:  =(address to.event-data.event-log)
      (add balance value.event-data.event-log)
    ?:  =(address from.event-data.event-log)
    (sub balance value.event-data.event-log)
    ~|  "unexpected event"  !!
  ?~  mined.event-log  ~|  "received unexpected unmined event"  !!
  =/  txh=@ux  transaction-hash.u.mined.event-log
  =/  pendings=(list [tid=@ta =pending])  ~(tap by pending-txs)
  =/  index=(unit @ud)
    %+  find  [[~ txh] ~]
    %+  turn  pendings
    |=  [@ta =pending]
    txh.pending
  =.  pending-txs
    ?~  index  pending-txs
    =/  tid=@ta  tid:(snag u.index pendings)
    %-  ~(del by pending-txs)  tid
  =.  txn-log
    :_  txn-log
    :*  block-number.u.mined.event-log
        txh
        log-index.u.mined.event-log
        from.event-data.event-log
        to.event-data.event-log
        value.event-data.event-log
    ==
  =.  contracts-map
  %+  ~(put by contracts-map)
    contract-id
  [name address.event-log new-balance txn-log pending-txs]
  state
::
  ==
++  fetch-key
   ^-  @ux
   %+  scan
     %+  skim  (trip (of-wain:format .^(wain %cx (get-path key-path))))
     |=(c=@t !=(c 10)) :: remove possible newlines
   ;~(pfix (jest '0x') hex)
++  get-path
  |=  =path
  ^-  ^path
  ~|  path
  :*
    (scot %p our.bol)
    %home
    (scot %da now.bol)
    path
  ==
++  start-txn-send
  |=  [=contract-id to=@ux amount=@ud]
  ^-  (quip card _state)
  =/  contract=address:eth  address:(~(got by contracts-map) contract-id)
  =/  tid=@ta
    :((cury cat 3) dap.bol '--' (scot %uv eny.bol))
  =/  =wire  [contract-id tid ~]
  =/  private-key=@ux  fetch-key
  =/  args
    :^  ~  `tid  %eth-abi-send-tx
    =+  [gas=100.000 gas-price=30.000.000.000]
    =/  =send:methods:erc20
    [%transfer to amount]
    !>([node-url contract-id contract private-key gas gas-price %erc20 !>(send)])
  =/  =contract-data  (~(got by contracts-map) contract-id)
  =.  pending-txs.contract-data
    %+  ~(put by pending-txs.contract-data)  tid
    [~ address to amount]
  =.  contracts-map
    %+  ~(put by contracts-map)  contract-id
    contract-data
  :_  state
  :~  (watch-spider [%xfer %result wire] /thread-result/[tid])
      (await-txh wire)
      (poke-spider [%xfer wire] %spider-start !>(args))
  ==
++  start-eth-send
  |=  [to=@ux amount=@ud]
  ^-  (quip card _state)
  =/  tid=@ta
    :((cury cat 3) dap.bol '--' (scot %uv eny.bol))
  =/  =wire  [%eth-send tid ~]
  =/  private-key=@ux  fetch-key
  =/  args
    :^  ~  `tid  %eth-send-eth
    =+  [gas=100.000 gas-price=30.000.000.000]
    !>([node-url 'eth-send' to private-key gas gas-price amount 0x0])
  =.  eth-pending-txs
    %+  ~(put by eth-pending-txs)  tid
    [~ to amount]
  :_  state
  :~  (watch-spider [%xfer %result wire] /thread-result/[tid])
      (await-txh wire)
      (poke-spider [%xfer wire] %spider-start !>(args))
  ==
::  should be generated
++  order-events
  |=  [a=event-log:erc20 b=event-log:erc20]
  ?>  ?=([~ *] mined.a)
  ?>  ?=([~ *] mined.b)
  =+  [ablock=block-number.u.mined.a bblock=block-number.u.mined.b]
  ?.  =(ablock bblock)  (lth ablock bblock)
  (lth log-index.u.mined.a log-index.u.mined.b)


++  poke-spider
  |=  [=path =cage]
  ^-  card
  [%pass path %agent [our.bol %spider] %poke cage]
::
++  watch-spider
  |=  [=path =sub=path]
  ^-  card
  [%pass path %agent [our.bol %spider] %watch sub-path]
::
++  leave-spider
  |=  =path
  ^-  card
  [%pass path %agent [our.bol %spider] %leave ~]
::
++  wait
  |=  [=wire =@dr]
  ^-  card
  [%pass wire %arvo %b %wait (add now.bol dr)]
::
++  to-eth-watcher
  |=  [=wire =task:agent:gall]
  ^-  card
  [%pass wire %agent [our.bol %eth-watch] task]
::
++  await-eth-watcher
  |=  =wire
  (wait [%awatch wire] ~m3)
++  await-txh
  |=  =wire
  (wait [%awatch-txh wire] ~s3)
++  await-eth-balance
  (wait [%eth-balance ~] ~m5)
++  get-eth-balance
  =/  tid=@ta
    :((cury cat 3) dap.bol '--' (scot %uv eny.bol))
  =/  args
      :^  ~  `tid  %eth-get-balance
      !>([node-url address])
  =/  =wire  [%eth-balance tid ~]
  :~  (poke-spider wire %spider-start !>(args))
      (watch-spider wire /thread-result/[tid])
  ==
::
++  watch-eth-watcher
  |=  =path
  %+  to-eth-watcher  [%eth-watcher `wire`path]
  :*  %watch-as
      %eth-contracts-erc20-diff
      [%logs path]
  ==
::
++  leave-eth-watcher
  |=  =wire
  %+  to-eth-watcher  [%eth-watcher wire]
  [%leave ~]
::
++  clear-eth-watcher
  |=  =path
  %+  to-eth-watcher  [%eth-watcher `wire`path]
  :+  %poke  %eth-watcher-poke
  !>  ^-  poke:eth-watcher
  [%clear [%logs path]]
--

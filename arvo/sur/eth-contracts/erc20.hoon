/-  ethers
=,  able:jael
=,  builders=builders:ethers
|%
+$  diff  ::  gift
    $%  [$history =loglist]
        [$log =event-log]
        [$disavow =id:block]
    ==
+$  ezub  ::  poke
    $%  [$watch =path config=watch-config]
        [$clear =path]
    ==
+$  event-log  (event-log-config:builders event-update)
+$  watch-config
    %-  watch-config:builders
    watch
+$  loglist  (list event-log)
::+$  kall
::    (call:builders erc20  call:methods)
::+$  zend
::    (send-tx:builders erc20 send:methods)
+$  rek
    $%
        [$allowance out=@ud]
        [$balance-of out=@ud]
        [$total-supply out=@ud]
    ==
+$  rez
  $:  name=?(%transfer-from %approve %decrease-allowance %increase-allowance %transfer)
      =address:ethereum  txh=@ux
      status=?  block=@ud
  ==
+$  event-update
    $%
        [$approval owner=@ux spender=@ux value=@ud]
        [$transfer from=@ux to=@ux value=@ud]
    ==
+$  watch
    $%
        [$approval owner=?(@ux (list @ux)) spender=?(@ux (list @ux)) ~]
        [$transfer from=?(@ux (list @ux)) to=?(@ux (list @ux)) ~]
    ==
++  methods
  |%
  ++  send
    $%
        [$transfer-from sender=@ux recipient=@ux amount=@ud]
        [$approve spender=@ux amount=@ud]
        [$decrease-allowance spender=@ux subtracted-value=@ud]
        [$increase-allowance spender=@ux added-value=@ud]
        [$transfer recipient=@ux amount=@ud]
    ==
  ++  call
    $%
        [$allowance owner=@ux spender=@ux]
        [$balance-of account=@ux]
        [$total-supply ~]
    ==
  --
--
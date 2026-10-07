{...}: {
  # For Kanata enable uinput
  boot.kernelModules = ["uinput"];
  hardware.uinput.enable = true;

  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        # devices = ["/dev/input/by-id/usb-Wooting_Wooting_60HE__ARM__A02B2341W052H02336-if01-event-kbd"];
        # the silakka54 runs the same layout in its own firmware (vial) - don't remap it twice
        extraDefCfg = ''
          process-unmapped-keys yes
          linux-dev-names-exclude (
            "Squalius-cephalus silakka54"
            "Squalius-cephalus silakka54 Keyboard"
            "Squalius-cephalus silakka54 Consumer Control"
            "Squalius-cephalus silakka54 System Control"
          )
        '';
        config = ''
              ;; ---base configuration---

              ;;specify device to intercept
              ;; linux-dev /dev/input/by-id/usb-wooting_wooting_60he__arm__a02b2341w052h02336-if01-event-kbd

              ;; ---source layout---
              (defsrc
              esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12        prnt slck pause
              grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc  ins  home pgup  nlck kp/  kp*  kp-
              tab  q    w    e    r    t    y    u    i    o    p    [    ]    \     del  end  pgdn  kp7  kp8  kp9  kp+
              caps a    s    d    f    g    h    j    k    l    ;    '    ret                        kp4  kp5  kp6
              lsft z    x    c    v    b    n    m    ,    .    /    rsft                 up         kp1  kp2  kp3  kprt
              lctl lmet lalt           spc            ralt rmet cmp  rctl            left down rght  kp0  kp.
              )

              ;; ---define variables---
              ;; timings moved a bit towards the silakka54 (vial: tapping term 180, combo term 50, tap dance 190)
              (defvar
              tap-time 250 ;; was 300
              hold-time 190 ;; was 200

              ;; set tap/hold time for layer tap-hold
              ;;layer-tap-time 200
              ;;layer-hold-time 160

              ;; set tap/hold time for space tap-hold
              spc-tap-time 220 ;; was 250
              spc-hold-time 220 ;; was 250

              ;; set tap/hold time for game tap-hold (after a double tap)
              game-tap-time 800
              game-hold-time 800

              ;; set tap/hold time for homerow mods
              ctl-tap 200
              alt-tap 200
              ;;sft-tap 200
              ;;met-tap 200

              ctl-hold 150
              alt-hold 170
              ;;sft-hold 125
              ;;met-hold 200

              ;; number row: hold for f-keys, longer than homerow mods so fast number typing stays numbers
              num-tap 250
              num-hold 300

              ;; tap dances (umlauts, game layer)
              td-time 190
              )

              ;; ---base layer for kanata---
              (deflayer base
              @esc   f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12        prnt slck pause
              grv    @n1  @n2  @n3  @n4  @n5  @n6  @n7  @n8  @n9  @n0  @nmi @neq  bspc  ins  home pgup  nlck kp/  kp*  kp-
              @ltab  q    w    e    r    t    y    u    i    o    p   @tdu  ]    \     del  end  pgdn  kp7  kp8  kp9  kp+
              @lesc @am  @sa  @ds  @fc  g    h    @jc  @ks  @la  @tdo @tda ret                        kp4  kp5  kp6
              lsft   z    x    c    v    b    n    m    ,    .    /    rsft                 up         kp1  kp2  kp3  kprt
              @chom  lmet @aend          @lspc            ralt rmet cmp  @rmou           left down rght  kp0  kp.
              )
              ;;might need to replace the hardcoded one with _ to emulate the original layer underneath it - only if qwertz layout switch doesnt work anymore afterwards

              ;; ---layer one for navigation (+ f-keys and media like the silakka54)---
              (deflayer nav1
              f12  _    _    _    _    _    _    _    _    _    _    _    _          _    _    _
              _    f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  RA-s f11  _     _    _    _     _    _    _    _
              _ A-left up A-rght  _    _    _    _    _    _   RA-s RA-y  _    _     _    _    _     _    _    _    _
              _  left down rght   _    _    left down up  rght RA-p RA-q  _                          _    _    _
              _    _    prev pp   next _    pp   mute vold volu prev _                    _          _    _    _    _
              _    _    _              _              _    _    _    _               _    _    _     _    _
              )

              ;; ---layer two (test) for navigation, hold esc for symbols---
              (deflayer nav2
              @sym _    _    _    _    _    _    _    _    _    _    _    _          _    _    _
              _    _    _    _    _    _    _    _    _    _    _   RA-s  _    _     _    _    _     _    _    _    _
              _    7    8    9    0    _    _    _    _    _    _   RA-y  _    _     _    _    _     _    _    _    _
              _    4    5    6    0    _    left down up  rght RA-p RA-q  _                          _    _    _
              _    1    2    3    0    _    _    _    _    _    _    _                    _          _    _    _    _
              _    _    _              _              _    _    _    _               _    _    _     _    _
              )

              ;; ---symbol layer (nav2 + hold esc, like the silakka54)---
              (deflayer sym
              _    _    _    _    _    _    _    _    _    _    _    _    _          _    _    _
              _    _    _    _    _    _    _    _    _    _    _    _    _    _     _    _    _     _    _    _    _
              _    S-1  S-2  S-3  S-4  S-5  S-6  S-7  S-8  S-9  S-0  _    _    _     _    _    _     _    _    _    _
              _    1    2    3    4    5    6    7    8    9    0    _    _                          _    _    _
              _    _    _    _    _    _    _    _    [    ]    \    _                    _          _    _    _    _
              _    _    _              _              _    _    _    _               _    _    _     _    _
              )

              ;; ---mouse layer (hold right ctrl, like the silakka54)---
              (deflayer mouse
              _    _    _    _    _    _    _    _    _    _    _    _    _          _    _    _
              _    _    _    _    _    _    _    _    _    _    _    _    _    _     _    _    _     _    _    _    _
              _    _    _    _    _    _    _    _    _   mlft @mu  mrgt  _    _     _    _    _     _    _    _    _
              _    _    _    _    _    _    _    _    _   @ml  @md  @mr   _                          _    _    _
              _    _    _    _    _    _    _    _    _    _    _    _                    _          _    _    _    _
              _    _    _              _              _    _    _    _               _    _    _     _    _
              )

              ;; ---gaming layer without homerow mods---
              (deflayer game
              _    _    _    _    _    _    _    _    _    _    _    _    _          _    _    _
              _    _    _    _    _    _    _    _    _    _    _    _    _    _     _    _    _     _    _    _    _
            @lbtab _    _    _    _    _    _    _    _    _    _    _    _    _     _    _    _     _    _    _    _
              _    _    _    _    _    _    _    _    _    _    _    _    _                          _    _    _
              _    _    _    _    _    _    _    _    _    _    _    _                    _          _    _    _    _
              _    _    _              _              _    _    _    _               _    _    _     _    _
              )

              (defalias

              ;;define layer-alias
              nav1 (layer-toggle nav1)
              nav2 (layer-toggle nav2)
              sym (layer-toggle sym)
              mou (layer-toggle mouse)
              game (layer-switch game)
              base (layer-switch base)

              ;;define key-alias and functions
              lesc (tap-hold-press $tap-time $hold-time esc @nav1)
              ;;lesc (tap-hold $tap-time $hold-time esc @nav1) mhm?
              ;; tab: tap/hold = tab, double tap and hold = switch to game layer (and back)
              ltab (tap-dance-eager $td-time (tab (tap-hold-press $game-tap-time $game-hold-time tab @game)))
              lbtab (tap-dance-eager $td-time (tab (tap-hold-press $game-tap-time $game-hold-time tab @base)))
              lspc (tap-hold $spc-tap-time $spc-hold-time spc @nav2)
              rmou (tap-hold-press $tap-time $hold-time rctl @mou)

              ;; esc: hold for ` (+ shift for ~)
              esc (tap-hold $num-tap $num-hold esc grv)

              ;; number row: hold for f-keys, 0 double tap = ß
              n1 (tap-hold $num-tap $num-hold 1 f1)
              n2 (tap-hold $num-tap $num-hold 2 f2)
              n3 (tap-hold $num-tap $num-hold 3 f3)
              n4 (tap-hold $num-tap $num-hold 4 f4)
              n5 (tap-hold $num-tap $num-hold 5 f5)
              n6 (tap-hold $num-tap $num-hold 6 f6)
              n7 (tap-hold $num-tap $num-hold 7 f7)
              n8 (tap-hold $num-tap $num-hold 8 f8)
              n9 (tap-hold $num-tap $num-hold 9 f9)
              n0 (tap-dance $td-time ((tap-hold $num-tap $num-hold 0 f10) RA-s))
              nmi (tap-hold $num-tap $num-hold - f11)
              neq (tap-hold $num-tap $num-hold = f12)

              ;; umlauts on double tap (like the silakka54)
              tda (tap-dance $td-time (' RA-q))
              tdu (tap-dance $td-time ([ RA-y))

              ;; mouse movement
              mu (movemouse-accel-up 4 1000 1 5)
              md (movemouse-accel-down 4 1000 1 5)
              ml (movemouse-accel-left 4 1000 1 5)
              mr (movemouse-accel-right 4 1000 1 5)

              chj (chord jkl-chords j)
              chk (chord jkl-chords k)
              chl (chord jkl-chords l)

              chs (chord sdf-chords s)
              chd (chord sdf-chords d)
              chf (chord sdf-chords f)

              chom (tap-hold $ctl-tap $ctl-hold home lctrl)
              aend (tap-hold $alt-tap $alt-hold end lalt)

              ;;homerow mods
              am (tap-hold $tap-time $hold-time a lmet)
              sa (tap-hold $tap-time $hold-time @chs lalt)
              ds (tap-hold $tap-time $hold-time @chd lsft)
              fc (tap-hold $tap-time $hold-time @chf lctl)

              jc (tap-hold $tap-time $hold-time @chj rctl)
              ks (tap-hold $tap-time $hold-time @chk rsft)
              la (tap-hold $tap-time $hold-time @chl lalt)
              ;m (tap-hold $tap-time $hold-time ; rmet)

              ;; needs the homerow mod above, aliases are order dependent
              tdo (tap-dance $td-time (@;m RA-p))

              ;;alt keys (figure out syntax to use alias for multiple key presses)
              ;;  @bck (a-left)
              ;;  @fwd (a-right)
              )

              ;; chord timeout: was 100 (silakka54 combo term is 50)
              (defchords jkl-chords 80
              (j    ) j
              (   k ) k
              (     l) l
              (j  k ) esc
              (   k l) bspc
              (j  k  l) C-bspc
              )

              (defchords sdf-chords 80
              (s    ) s
              (   d ) d
              (      f) f
              (s  d ) del
              (   d  f) tab
              (s  d  f) C-del
              )

              #| (defchords jklcbspc 100
              (j      ) j
              (   k   ) k
              (      l) l
              (j  k  l) ctrl return
              )
              |#

          #| ---empty layer template---
              (deflayer template
              _    _    _    _    _    _    _    _    _    _    _    _    _          _    _    _
              _    _    _    _    _    _    _    _    _    _    _    _    _    _     _    _    _     _    _    _    _
              _    _    _    _    _    _    _    _    _    _    _    _    _    _     _    _    _     _    _    _    _
              _    _    _    _    _    _    _    _    _    _    _    _    _                          _    _    _
              _    _    _    _    _    _    _    _    _    _    _    _                    _          _    _    _    _
              _    _    _              _              _    _    _    _               _    _    _     _    _
              )
              |#
        '';
      };
    };
  };
}

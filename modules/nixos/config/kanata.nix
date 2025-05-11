{ config, pkgs, inputs, lib, ... }:

{
  # For Kanata enable uinput
  boot.kernelModules = ["uinput"];
  hardware.uinput.enable = true;

services.kanata = {
  enable = true;
  keyboards = {
  internalKeyboard = {
    # devices = ["/dev/input/by-id/usb-Wooting_Wooting_60HE__ARM__A02B2341W052H02336-if01-event-kbd"];
    extraDefCfg = "process-unmapped-keys yes";
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
    (defvar
    tap-time 300
    hold-time 200

    ;; set tap/hold time for layer tap-hold
    ;;layer-tap-time 200
    ;;layer-hold-time 160

    ;; set tap/hold time for space tap-hold
    spc-tap-time 400
    spc-hold-time 400

    ;; set tap/hold time for homerow mods
    ctl-tap 200
    alt-tap 200
    ;;sft-tap 200
    ;;met-tap 200

    ctl-hold 150
    alt-hold 170
    ;;sft-hold 125
    ;;met-hold 200
    )

    ;; ---base layer for kanata---
    (deflayer base
    esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12        prnt slck pause
    grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc  ins  home pgup  nlck kp/  kp*  kp-
    tab  q    w    e    r    t    y    u    i    o    p    [    ]    \     del  end  pgdn  kp7  kp8  kp9  kp+
    @lesc @am  @sa  @ds  @fc  g    h    @jc  @ks  @la  @;m  '    ret                        kp4  kp5  kp6
    lsft z    x    c    v    b    n    m    ,    .    /    rsft                 up         kp1  kp2  kp3  kprt
    @chom lmet @aend          spc            ralt rmet cmp  rctl            left down rght  kp0  kp.
    ) 
    ;;might need to replace the hardcoded one with _ to emulate the original layer underneath it - only if qwertz layout switch doesnt work anymore afterwards

    ;; ---layer one for navigation---
    (deflayer nav1 
    _    _    _    _    _    _    _    _    _    _    _    _    _          _    _    _
    _    _    _    _    _    _    _    _    _    _    _   RA-s  _    _     _    _    _     _    _    _    _
    _ A-left up A-rght  _    _    _    C-v  C-c  C-x  _   RA-y  _    _     _    _    _     _    _    _    _
    _  left down rght   _    _    left down up  rght RA-p RA-q  _                          _    _    _
    _    _    _    _    _    _    _    _    _    _    _    _                    _          _    _    _    _
    _    _    _              _              _    _    _    _               _    _    _     _    _
    )

    (defalias

    ;;define layer-alias
    nav1 (layer-toggle nav1)

    ;;define key-alias and functions
    lesc (tap-hold-press $tap-time $hold-time esc @nav1) 
    lspc (tap-hold-press $spc-tap-time $spc-hold-time spc @nav1)

    chj (chord jkesc j)
    chk (chord jkesc k)

    chom (tap-hold $ctl-tap $ctl-hold home lctrl)
    aend (tap-hold $alt-tap $alt-hold end lalt)

    ;;homerow mods
    am (tap-hold $tap-time $hold-time a lmet)
    sa (tap-hold $tap-time $hold-time s lalt)
    ds (tap-hold $tap-time $hold-time d lsft)
    fc (tap-hold $tap-time $hold-time f lctl)

    jc (tap-hold $tap-time $hold-time @chj rctl)
    ks (tap-hold $tap-time $hold-time @chk rsft)
    la (tap-hold $tap-time $hold-time l lalt)
    ;m (tap-hold $tap-time $hold-time ; rmet)

    ;;alt keys (figure out syntax to use alias for multiple key presses)
    ;;  @bck (a-left)
    ;;  @fwd (a-right)
    )

    (defchords jkesc 100
    (j    ) j
    (   k ) k
    (j  k ) esc
    )

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

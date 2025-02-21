# {config, pkgs, ... }:
#
# {
# services.kanata = {
# enable = true;
# keyboard = {internalKeyboard = devices [linux-dev /dev/input/by-id/usb-Wooting_Wooting_60HE__ARM__A02B2341W052H02336-if01-event-kbd];
# extraDefCfg = "process-unmapped-keys yes"};
# config = ''
# ;; ---Base Configuration---
#
# (defcfg
#
# ;; Allow to use keys that were not defined in kanata
# ;;  process-unmapped-keys yes
#
# ;;Specify device to intercept
#   ;; linux-dev /dev/input/by-id/usb-Wooting_Wooting_60HE__ARM__A02B2341W052H02336-if01-event-kbd
# )
#
# ;; ---Source Layout---
# (defsrc
#   esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12        prnt slck pause
#   grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc  ins  home pgup  nlck kp/  kp*  kp-
#   tab  q    w    e    r    t    y    u    i    o    p    [    ]    \     del  end  pgdn  kp7  kp8  kp9  kp+
#   caps a    s    d    f    g    h    j    k    l    ;    '    ret                        kp4  kp5  kp6
#   lsft z    x    c    v    b    n    m    ,    .    /    rsft                 up         kp1  kp2  kp3  kprt
#   lctl lmet lalt           spc            ralt rmet cmp  rctl            left down rght  kp0  kp.
# )
#
# ;; ---Define Variables---
# (defvar
#   tap-time 300
#   hold-time 200
#
#   ;; Set tap/hold time for layer tap-hold
#   ;;layer-tap-time 200
#   ;;layer-hold-time 160
#
#   ;; Set tap/hold time for space tap-hold
#   spc-tap-time 400
#   spc-hold-time 400
#
#   ;; Set tap/hold time for homerow mods
#   ctl-tap 200
#   alt-tap 200
#   ;;sft-tap 200
#   ;;met-tap 200
#
#   ctl-hold 150
#   alt-hold 170
#   ;;sft-hold 125
#   ;;met-hold 200
# )
#
# ;; ---Base Layer for Kanata---
# (deflayer base
#   esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12        prnt slck pause
#   grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc  ins  home pgup  nlck kp/  kp*  kp-
#   tab  q    w    e    r    t    y    u    i    o    p    [    ]    \     del  end  pgdn  kp7  kp8  kp9  kp+
#  @lesc @am  @sa  @ds  @fc  g    h    @jc  @ks  @la  @;m  '    ret                        kp4  kp5  kp6
#   lsft z    x    c    v    b    n    m    ,    .    /    rsft                 up         kp1  kp2  kp3  kprt
#  @chom lmet @aend          spc            ralt rmet cmp  rctl            left down rght  kp0  kp.
# ) 
# ;;might need to replace the hardcoded one with _ to emulate the original layer underneath it - only if qwertz layout switch doesnt work anymore afterwards
#
# ;; ---Layer One for Navigation---
# (deflayer nav1 
#   _    _    _    _    _    _    _    _    _    _    _    _    _          _    _    _
#   _    _    _    _    _    _    _    _    _    _    _   RA-s  _    _     _    _    _     _    _    _    _
#   _ A-left up A-rght  _    _    _    C-v  C-c  C-x  _   RA-y  _    _     _    _    _     _    _    _    _
#   _  left down rght   _    _    left down up  rght RA-p RA-q  _                          _    _    _
#   _    _    _    _    _    _    _    _    _    _    _    _                    _          _    _    _    _
#   _    _    _              _              _    _    _    _               _    _    _     _    _
# )
#
# (defalias
#
# ;;Define Layer-Alias
#   nav1 (layer-toggle nav1)
#
# ;;Define Key-Alias and functions
#   lesc (tap-hold-press $tap-time $hold-time esc @nav1) 
#   lspc (tap-hold-press $spc-tap-time $spc-hold-time spc @nav1)
#
#   chj (chord jkesc j)
#   chk (chord jkesc k)
#
#   chom (tap-hold $ctl-tap $ctl-hold home lctrl)
#   aend (tap-hold $alt-tap $alt-hold end lalt)
#
# ;;Homerow Mods
#   am (tap-hold $tap-time $hold-time a lmet)
#   sa (tap-hold $tap-time $hold-time s lalt)
#   ds (tap-hold $tap-time $hold-time d lsft)
#   fc (tap-hold $tap-time $hold-time f lctl)
#
#   jc (tap-hold $tap-time $hold-time @chj rctl)
#   ks (tap-hold $tap-time $hold-time @chk rsft)
#   la (tap-hold $tap-time $hold-time l ralt)
#   ;m (tap-hold $tap-time $hold-time ; rmet)
#
# ;;Alt Keys (figure out syntax to use alias for multiple key presses)
# ;;  @bck (A-left)
# ;;  @fwd (A-right)
# )
#
# (defchords jkesc 100
#   (j    ) j
#   (   k ) k
#   (j  k ) esc
# )
#
# #| ---Empty Layer Template---
# (deflayer template
#   _    _    _    _    _    _    _    _    _    _    _    _    _          _    _    _
#   _    _    _    _    _    _    _    _    _    _    _    _    _    _     _    _    _     _    _    _    _
#   _    _    _    _    _    _    _    _    _    _    _    _    _    _     _    _    _     _    _    _    _
#   _    _    _    _    _    _    _    _    _    _    _    _    _                          _    _    _
#   _    _    _    _    _    _    _    _    _    _    _    _                    _          _    _    _    _
#   _    _    _              _              _    _    _    _               _    _    _     _    _
# )
# |#
#
#
#
# ;;------------------------------------------------
#
# #| Old Configuration
# (defcfg
#   process-unmapped-keys yes
# )
#
# (defsrc
#   caps a s d f h j k l ;
# )
#
# (defvar
#   tap-time 200
#   hold-time 250
# )
#
# (defalias
#   escctrl (tap-hold 200 200 esc lctl)
#
#   a (tap-hold $tap-time $hold-time a lmet)
#   s (tap-hold $tap-time $hold-time s lalt)
#   d (tap-hold $tap-time $hold-time d lsft)
#   f (tap-hold $tap-time $hold-time f lctl)
#   h (tap-hold $tap-time $hold-time h h)
#   j (tap-hold $tap-time $hold-time j rctl)
#   k (tap-hold $tap-time $hold-time k rsft)
#   l (tap-hold $tap-time $hold-time l ralt)
#   ; (tap-hold $tap-time $hold-time ; rmet)
#
#
# ;;  nav (layer-while-held arrow-hjkl)
# ;;  nav (layer-toggle arrow-hjkl)
# ;;  nav (tap-hold $tap-time $hold-time esc arrow-hjkl)
#
# ;;  capsword (caps-word 2000)
#   nav (tap-hold-press $tap-time $hold-time esc (layer-toggle arrow-hjkl))
#   h2 (tap-hold $tap-time $hold-time left left)
#   j2 (tap-hold $tap-time $hold-time down down)
#   k2 (tap-hold $tap-time $hold-time up up)
#   l2 (tap-hold $tap-time $hold-time right right)
#
# ;; (defalias nav (layer-while-held navigation))
#
# ;;      capsword (caps-word 2000)
# ;;      cap (tap-hold-press $tap-time $hold-time @capsword (layer-toggle cap-mod))
# )
#
# (deflayer base
#   @nav @a @s @d @f @h @j @k @l @;
# )
#
# (deflayer arrow-hjkl 
#   _ @a @s @d @f @h2 @j2 @k2 @l2 @;
# )
# |#
# ;; ---Base Configuration---
#
# (defcfg
#
# ;; Allow to use keys that were not defined in kanata
#   process-unmapped-keys yes
#
# ;;Specify device to intercept
#   ;; linux-dev /dev/input/by-id/usb-Wooting_Wooting_60HE__ARM__A02B2341W052H02336-if01-event-kbd
# )
#
# ;; ---Source Layout---
# (defsrc
#   esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12        prnt slck pause
#   grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc  ins  home pgup  nlck kp/  kp*  kp-
#   tab  q    w    e    r    t    y    u    i    o    p    [    ]    \     del  end  pgdn  kp7  kp8  kp9  kp+
#   caps a    s    d    f    g    h    j    k    l    ;    '    ret                        kp4  kp5  kp6
#   lsft z    x    c    v    b    n    m    ,    .    /    rsft                 up         kp1  kp2  kp3  kprt
#   lctl lmet lalt           spc            ralt rmet cmp  rctl            left down rght  kp0  kp.
# )
#
# ;; ---Define Variables---
# (defvar
#   tap-time 300
#   hold-time 200
#
#   ;; Set tap/hold time for layer tap-hold
#   ;;layer-tap-time 200
#   ;;layer-hold-time 160
#
#   ;; Set tap/hold time for space tap-hold
#   spc-tap-time 400
#   spc-hold-time 400
#
#   ;; Set tap/hold time for homerow mods
#   ctl-tap 200
#   alt-tap 200
#   ;;sft-tap 200
#   ;;met-tap 200
#
#   ctl-hold 150
#   alt-hold 170
#   ;;sft-hold 125
#   ;;met-hold 200
# )
#
# ;; ---Base Layer for Kanata---
# (deflayer base
#   esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12        prnt slck pause
#   grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc  ins  home pgup  nlck kp/  kp*  kp-
#   tab  q    w    e    r    t    y    u    i    o    p    [    ]    \     del  end  pgdn  kp7  kp8  kp9  kp+
#  @lesc @am  @sa  @ds  @fc  g    h    @jc  @ks  @la  @;m  '    ret                        kp4  kp5  kp6
#   lsft z    x    c    v    b    n    m    ,    .    /    rsft                 up         kp1  kp2  kp3  kprt
#  @chom lmet @aend          spc            ralt rmet cmp  rctl            left down rght  kp0  kp.
# ) 
# ;;might need to replace the hardcoded one with _ to emulate the original layer underneath it - only if qwertz layout switch doesnt work anymore afterwards
#
# ;; ---Layer One for Navigation---
# (deflayer nav1 
#   _    _    _    _    _    _    _    _    _    _    _    _    _          _    _    _
#   _    _    _    _    _    _    _    _    _    _    _   RA-s  _    _     _    _    _     _    _    _    _
#   _ A-left up A-rght  _    _    _    C-v  C-c  C-x  _   RA-y  _    _     _    _    _     _    _    _    _
#   _  left down rght   _    _    left down up  rght RA-p RA-q  _                          _    _    _
#   _    _    _    _    _    _    _    _    _    _    _    _                    _          _    _    _    _
#   _    _    _              _              _    _    _    _               _    _    _     _    _
# )
#
# (defalias
#
# ;;Define Layer-Alias
#   nav1 (layer-toggle nav1)
#
# ;;Define Key-Alias and functions
#   lesc (tap-hold-press $tap-time $hold-time esc @nav1) 
#   lspc (tap-hold-press $spc-tap-time $spc-hold-time spc @nav1)
#
#   chj (chord jkesc j)
#   chk (chord jkesc k)
#
#   chom (tap-hold $ctl-tap $ctl-hold home lctrl)
#   aend (tap-hold $alt-tap $alt-hold end lalt)
#
# ;;Homerow Mods
#   am (tap-hold $tap-time $hold-time a lmet)
#   sa (tap-hold $tap-time $hold-time s lalt)
#   ds (tap-hold $tap-time $hold-time d lsft)
#   fc (tap-hold $tap-time $hold-time f lctl)
#
#   jc (tap-hold $tap-time $hold-time @chj rctl)
#   ks (tap-hold $tap-time $hold-time @chk rsft)
#   la (tap-hold $tap-time $hold-time l ralt)
#   ;m (tap-hold $tap-time $hold-time ; rmet)
#
# ;;Alt Keys (figure out syntax to use alias for multiple key presses)
# ;;  @bck (A-left)
# ;;  @fwd (A-right)
# )
#
# (defchords jkesc 100
#   (j    ) j
#   (   k ) k
#   (j  k ) esc
# )
#
# #| ---Empty Layer Template---
# (deflayer template
#   _    _    _    _    _    _    _    _    _    _    _    _    _          _    _    _
#   _    _    _    _    _    _    _    _    _    _    _    _    _    _     _    _    _     _    _    _    _
#   _    _    _    _    _    _    _    _    _    _    _    _    _    _     _    _    _     _    _    _    _
#   _    _    _    _    _    _    _    _    _    _    _    _    _                          _    _    _
#   _    _    _    _    _    _    _    _    _    _    _    _                    _          _    _    _    _
#   _    _    _              _              _    _    _    _               _    _    _     _    _
# )
# |#
#
#
#
# ;;------------------------------------------------
#
# #| Old Configuration
# (defcfg
#   process-unmapped-keys yes
# )
#
# (defsrc
#   caps a s d f h j k l ;
# )
#
# (defvar
#   tap-time 200
#   hold-time 250
# )
#
# (defalias
#   escctrl (tap-hold 200 200 esc lctl)
#
#   a (tap-hold $tap-time $hold-time a lmet)
#   s (tap-hold $tap-time $hold-time s lalt)
#   d (tap-hold $tap-time $hold-time d lsft)
#   f (tap-hold $tap-time $hold-time f lctl)
#   h (tap-hold $tap-time $hold-time h h)
#   j (tap-hold $tap-time $hold-time j rctl)
#   k (tap-hold $tap-time $hold-time k rsft)
#   l (tap-hold $tap-time $hold-time l ralt)
#   ; (tap-hold $tap-time $hold-time ; rmet)
#
#
# ;;  nav (layer-while-held arrow-hjkl)
# ;;  nav (layer-toggle arrow-hjkl)
# ;;  nav (tap-hold $tap-time $hold-time esc arrow-hjkl)
#
# ;;  capsword (caps-word 2000)
#   nav (tap-hold-press $tap-time $hold-time esc (layer-toggle arrow-hjkl))
#   h2 (tap-hold $tap-time $hold-time left left)
#   j2 (tap-hold $tap-time $hold-time down down)
#   k2 (tap-hold $tap-time $hold-time up up)
#   l2 (tap-hold $tap-time $hold-time right right)
#
# ;; (defalias nav (layer-while-held navigation))
#
# ;;      capsword (caps-word 2000)
# ;;      cap (tap-hold-press $tap-time $hold-time @capsword (layer-toggle cap-mod))
# )
#
# (deflayer base
#   @nav @a @s @d @f @h @j @k @l @;
# )
#
# (deflayer arrow-hjkl 
#   _ @a @s @d @f @h2 @j2 @k2 @l2 @;
# )
# |#
#
# '';
# };
# }

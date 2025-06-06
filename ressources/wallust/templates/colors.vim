" Wallust-generated colors for Neovim (LazyVim)
hi clear
if exists('syntax_on')
  syntax reset
endif
set background=dark
let g:colors_name = "wallust"

hi Normal       guifg={{ colors.foreground }} guibg={{ colors.background }}
hi Comment      guifg={{ colors.color8 }}     gui=italic
hi Constant     guifg={{ colors.color4 }}
hi Identifier   guifg={{ colors.color2 }}
hi Statement    guifg={{ colors.color1 }}
hi PreProc      guifg={{ colors.color5 }}
hi Type         guifg={{ colors.color6 }}
hi Special      guifg={{ colors.color3 }}
hi Underlined   guifg={{ colors.color12 }}
hi Todo         guifg={{ colors.color11 }}    guibg={{ colors.background }}
" ...add more as needed


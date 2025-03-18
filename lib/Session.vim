let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/school/work/zeldoune/lib
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +5 shader.dart
badd +7 ~/school/work/zeldoune/lib/game.dart
badd +21 ~/school/work/zeldoune/lib/hero.dart
badd +15 ~/school/work/zeldoune/lib/main.dart
badd +128 ~/school/work/zeldoune/lib/world.dart
argglobal
%argdel
set stal=2
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabrewind
edit ~/school/work/zeldoune/lib/game.dart
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 119 + 80) / 160)
exe 'vert 2resize ' . ((&columns * 40 + 80) / 160)
argglobal
balt shader.dart
setlocal fdm=expr
setlocal fde=nvim_treesitter#foldexpr()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=9
setlocal fen
3
normal! zo
14
normal! zo
16
normal! zo
let s:l = 8 - ((7 * winheight(0) + 25) / 50)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 8
normal! 0
wincmd w
argglobal
enew
file neo-tree\ filesystem\ \[1]
balt shader.dart
setlocal fdm=expr
setlocal fde=nvim_treesitter#foldexpr()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=99
setlocal fml=1
setlocal fdn=9
setlocal fen
wincmd w
exe 'vert 1resize ' . ((&columns * 119 + 80) / 160)
exe 'vert 2resize ' . ((&columns * 40 + 80) / 160)
tabnext
edit ~/school/work/zeldoune/lib/world.dart
argglobal
balt ~/school/work/zeldoune/lib/main.dart
setlocal fdm=expr
setlocal fde=nvim_treesitter#foldexpr()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=9
setlocal fen
let s:l = 128 - ((127 * winheight(0) + 25) / 50)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 128
normal! 0
tabnext
edit ~/school/work/zeldoune/lib/hero.dart
argglobal
balt ~/school/work/zeldoune/lib/game.dart
setlocal fdm=expr
setlocal fde=nvim_treesitter#foldexpr()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=9
setlocal fen
8
normal! zo
17
normal! zo
23
normal! zo
28
normal! zo
29
normal! zo
39
normal! zo
40
normal! zo
41
normal! zo
42
normal! zo
49
normal! zo
59
normal! zo
60
normal! zo
61
normal! zo
70
normal! zo
71
normal! zo
74
normal! zo
76
normal! zo
78
normal! zo
95
normal! zo
96
normal! zo
107
normal! zo
112
normal! zo
116
normal! zo
121
normal! zo
122
normal! zo
130
normal! zo
131
normal! zo
132
normal! zo
134
normal! zo
147
normal! zo
let s:l = 21 - ((20 * winheight(0) + 25) / 50)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 21
normal! 0
tabnext 2
set stal=1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
nohlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :

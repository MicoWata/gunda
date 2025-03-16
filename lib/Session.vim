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
badd +22 shader.dart
badd +78 hero.dart
badd +23 __FLUTTER_DEV_LOG__
badd +465 term://~/school/work/zeldoune/lib//495801:/usr/bin/zsh
badd +174 world.dart
badd +14 main.dart
badd +12 ~/school/work/zeldoune/assets/images/shader.frag
badd +66 ~/school/work/zeldoune/pubspec.yaml
badd +1 neo-tree\ filesystem\ \[1]
badd +1 ~/school/work/zeldoune/__FLUTTER_DEV_LOG__
badd +1 ~/school/work/zeldoune/shaders/shader.frag
badd +2 term://~/school/work/zeldoune/lib//521819:/usr/bin/zsh
argglobal
%argdel
set stal=2
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabrewind
edit hero.dart
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
balt main.dart
setlocal fdm=expr
setlocal fde=nvim_treesitter#foldexpr()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=99
setlocal fml=1
setlocal fdn=9
setlocal fen
17
normal! zo
70
normal! zo
let s:l = 37 - ((36 * winheight(0) + 25) / 51)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 37
normal! 0
wincmd w
argglobal
if bufexists(fnamemodify("neo-tree\ filesystem\ \[1]", ":p")) | buffer neo-tree\ filesystem\ \[1] | else | edit neo-tree\ filesystem\ \[1] | endif
if &buftype ==# 'terminal'
  silent file neo-tree\ filesystem\ \[1]
endif
balt hero.dart
setlocal fdm=expr
setlocal fde=nvim_treesitter#foldexpr()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=99
setlocal fml=1
setlocal fdn=9
setlocal fen
let s:l = 1 - ((0 * winheight(0) + 25) / 51)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1
normal! 0
wincmd w
exe 'vert 1resize ' . ((&columns * 119 + 80) / 160)
exe 'vert 2resize ' . ((&columns * 40 + 80) / 160)
tabnext
edit world.dart
tcd ~/school/work/zeldoune
argglobal
balt ~/school/work/zeldoune/__FLUTTER_DEV_LOG__
setlocal fdm=expr
setlocal fde=nvim_treesitter#foldexpr()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=9
setlocal fen
42
normal! zo
49
normal! zo
54
normal! zo
59
normal! zo
60
normal! zo
63
normal! zo
67
normal! zo
69
normal! zo
76
normal! zo
77
normal! zo
78
normal! zo
84
normal! zo
87
normal! zo
88
normal! zo
99
normal! zo
113
normal! zo
116
normal! zo
120
normal! zo
122
normal! zo
130
normal! zo
131
normal! zo
134
normal! zo
135
normal! zo
137
normal! zo
138
normal! zo
139
normal! zo
140
normal! zo
144
normal! zo
158
normal! zo
167
normal! zo
168
normal! zo
175
normal! zo
176
normal! zo
184
normal! zo
191
normal! zo
195
normal! zo
196
normal! zo
198
normal! zo
201
normal! zo
214
normal! zo
let s:l = 80 - ((28 * winheight(0) + 25) / 51)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 80
normal! 018|
tabnext
edit ~/school/work/zeldoune/lib/hero.dart
tcd ~/school/work/zeldoune
argglobal
balt ~/school/work/zeldoune/pubspec.yaml
setlocal fdm=expr
setlocal fde=nvim_treesitter#foldexpr()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=99
setlocal fml=1
setlocal fdn=9
setlocal fen
let s:l = 78 - ((10 * winheight(0) + 25) / 51)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 78
normal! 02|
tabnext
edit ~/school/work/zeldoune/lib/shader.dart
tcd ~/school/work/zeldoune/lib
argglobal
balt ~/school/work/zeldoune/lib/__FLUTTER_DEV_LOG__
setlocal fdm=expr
setlocal fde=nvim_treesitter#foldexpr()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=9
setlocal fen
let s:l = 22 - ((21 * winheight(0) + 25) / 51)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 22
normal! 03|
tabnext
edit ~/school/work/zeldoune/shaders/shader.frag
tcd ~/school/work/zeldoune
argglobal
balt ~/school/work/zeldoune/lib/shader.dart
setlocal fdm=expr
setlocal fde=nvim_treesitter#foldexpr()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=99
setlocal fml=1
setlocal fdn=9
setlocal fen
let s:l = 7 - ((6 * winheight(0) + 25) / 51)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 7
normal! 0
tabnext 4
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

let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/school/work/game5/lib
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +4 main.dart
badd +26 ~/school/work/game5/lib/src/game/game_screen.dart
argglobal
%argdel
edit ~/school/work/game5/lib/src/game/game_screen.dart
argglobal
balt main.dart
setlocal fdm=expr
setlocal fde=nvim_treesitter#foldexpr()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=9
setlocal fen
18
normal! zo
22
normal! zo
26
normal! zo
57
normal! zo
70
normal! zo
79
normal! zo
85
normal! zo
86
normal! zo
92
normal! zo
95
normal! zo
98
normal! zo
112
normal! zo
115
normal! zo
122
normal! zo
125
normal! zo
130
normal! zo
131
normal! zo
145
normal! zo
151
normal! zo
158
normal! zo
161
normal! zo
163
normal! zo
170
normal! zo
184
normal! zo
194
normal! zo
201
normal! zo
217
normal! zo
222
normal! zo
227
normal! zo
237
normal! zo
238
normal! zo
239
normal! zo
248
normal! zo
254
normal! zo
272
normal! zo
280
normal! zo
290
normal! zo
296
normal! zo
297
normal! zo
301
normal! zo
309
normal! zo
314
normal! zo
316
normal! zo
323
normal! zo
326
normal! zo
335
normal! zo
346
normal! zo
348
normal! zo
360
normal! zo
367
normal! zo
369
normal! zo
374
normal! zo
376
normal! zo
383
normal! zo
385
normal! zo
388
normal! zo
391
normal! zo
394
normal! zo
403
normal! zo
408
normal! zo
422
normal! zo
427
normal! zo
433
normal! zo
434
normal! zo
442
normal! zo
448
normal! zo
449
normal! zo
458
normal! zo
464
normal! zo
465
normal! zo
473
normal! zo
479
normal! zo
480
normal! zo
493
normal! zo
502
normal! zo
507
normal! zo
513
normal! zo
518
normal! zo
526
normal! zo
529
normal! zo
540
normal! zo
546
normal! zo
547
normal! zo
553
normal! zo
554
normal! zo
564
normal! zo
565
normal! zo
586
normal! zo
596
normal! zo
598
normal! zo
609
normal! zo
616
normal! zo
620
normal! zo
626
normal! zo
633
normal! zo
645
normal! zo
676
normal! zo
693
normal! zo
698
normal! zo
705
normal! zo
708
normal! zo
709
normal! zo
719
normal! zo
721
normal! zo
724
normal! zo
729
normal! zo
732
normal! zo
739
normal! zo
741
normal! zo
755
normal! zo
757
normal! zo
762
normal! zo
774
normal! zo
782
normal! zo
794
normal! zo
796
normal! zo
801
normal! zo
809
normal! zo
811
normal! zo
816
normal! zo
823
normal! zo
830
normal! zo
834
normal! zo
837
normal! zo
843
normal! zo
844
normal! zo
851
normal! zo
863
normal! zo
869
normal! zo
870
normal! zo
877
normal! zo
886
normal! zo
897
normal! zo
912
normal! zo
913
normal! zo
926
normal! zo
927
normal! zo
937
normal! zo
943
normal! zo
948
normal! zo
955
normal! zo
956
normal! zo
958
normal! zo
965
normal! zo
967
normal! zo
972
normal! zo
984
normal! zo
986
normal! zo
990
normal! zo
998
normal! zo
1001
normal! zo
1003
normal! zo
1006
normal! zo
1012
normal! zo
1014
normal! zo
1029
normal! zo
1035
normal! zo
1053
normal! zo
1061
normal! zo
1072
normal! zo
1073
normal! zo
1083
normal! zo
1089
normal! zo
1107
normal! zo
1115
normal! zo
1121
normal! zo
1125
normal! zo
1133
normal! zo
1134
normal! zo
1141
normal! zo
1142
normal! zo
1144
normal! zo
1153
normal! zo
1154
normal! zo
1156
normal! zo
1165
normal! zo
1169
normal! zo
1171
normal! zo
1183
normal! zo
1184
normal! zo
1186
normal! zo
1187
normal! zo
1189
normal! zo
1190
normal! zo
1192
normal! zo
1199
normal! zo
1204
normal! zo
1205
normal! zo
1206
normal! zo
1211
normal! zo
1212
normal! zo
1226
normal! zo
1238
normal! zo
1240
normal! zo
1242
normal! zo
1244
normal! zo
1250
normal! zo
1251
normal! zo
1266
normal! zo
1310
normal! zo
1343
normal! zo
1385
normal! zo
1432
normal! zo
1457
normal! zo
1529
normal! zo
1641
normal! zo
26
normal! zc
1659
normal! zo
1687
normal! zo
1698
normal! zo
1710
normal! zo
1711
normal! zo
1726
normal! zo
1738
normal! zo
1747
normal! zo
1751
normal! zo
1760
normal! zo
let s:l = 26 - ((15 * winheight(0) + 25) / 51)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 26
normal! 0
tabnext 1
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

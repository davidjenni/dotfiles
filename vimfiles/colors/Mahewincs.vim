" mahewincs.vim: a colorscheme
" Maintainer: Natal Ngétal <hobbestigrou@erakis.im>
" Date Last Change: March 10, 2012
" Version: 0.2
"TODO: Definition constant and so on, review few color in a gui, and few color
"for term.

set background=dark
if version > 580
     hi clear
     if exists("syntax_on")
         syntax reset
    endif
endif

set t_Co=256
let g:colors_name = "mahewincs"

hi User1 guibg=darkblue guifg=yellow
hi User2 guibg=darkblue guifg=lightblue
hi User3 guibg=darkblue guifg=red
hi User4 guibg=darkblue guifg=cyan
hi User5 guibg=darkblue guifg=lightgreen

"definitions for color in a terminal
hi Normal                      ctermfg=3    ctermbg=NONE cterm=NONE
hi NonText                     ctermfg=104  ctermbg=NONE cterm=bold
hi Comment                     ctermfg=2    ctermbg=NONE cterm=NONE
hi SpecialComment              ctermfg=176  ctermbg=NONE cterm=NONE
hi SpecialChar                 ctermfg=176  ctermbg=238  cterm=NONE
hi Special                     ctermfg=176  ctermbg=NONE cterm=NONE
hi Directory                   ctermfg=48   ctermbg=NONE cterm=NONE
hi LineNr                      ctermfg=10   ctermbg=NONE cterm=NONE
hi ModeMsg                     ctermfg=180  ctermbg=NONE cterm=NONE
hi MoreMsg                     ctermfg=167  ctermbg=NONE cterm=NONE
hi Title                       ctermfg=137  ctermbg=NONE cterm=NONE
hi Number                      ctermfg=50   ctermbg=NONE cterm=NONE
hi Float                       ctermfg=215  ctermbg=NONE cterm=NONE
hi Boolean                     ctermfg=105  ctermbg=NONE cterm=NONE
hi String                      ctermfg=83   ctermbg=238  cterm=NONE
hi Character                   ctermfg=222  ctermbg=NONE cterm=NONE
hi Identifier                  ctermfg=70   ctermbg=NONE cterm=NONE
hi Statement                   ctermfg=26   ctermbg=NONE cterm=NONE
hi Conditional                 ctermfg=210  ctermbg=NONE cterm=NONE
hi Exception                   ctermfg=213  ctermbg=NONE cterm=NONE
hi Keyword                     ctermfg=184  ctermbg=NONE cterm=NONE
hi Type                        ctermfg=15   ctermbg=NONE cterm=NONE
hi Delimiter                   ctermfg=5    ctermbg=NONE cterm=NONE
hi Define                      ctermfg=66   ctermbg=NONE cterm=NONE
hi Typedef                     ctermfg=213  ctermbg=NONE cterm=NONE
hi PreCondit                   ctermfg=66   ctermbg=NONE cterm=NONE
hi PreProc                     ctermfg=66   ctermbg=NONE cterm=NONE
hi Include                     ctermfg=66   ctermbg=NONE cterm=NONE
hi Macro                       ctermfg=66   ctermbg=NONE cterm=NONE
hi Debug                       ctermfg=176  ctermbg=NONE cterm=NONE
hi type                        ctermfg=15   ctermbg=NONE cterm=NONE
hi Question                    ctermfg=220  ctermbg=NONE cterm=NONE
hi VertSplit                   ctermfg=11   ctermbg=20   cterm=NONE
hi Todo                        ctermfg=196  ctermbg=179  cterm=NONE
hi StatusLine                  ctermbg=4    ctermfg=2    cterm=NONE
hi StatusLineNC                ctermfg=4    ctermbg=2    cterm=NONE
hi IncSearch                   ctermfg=22   ctermbg=137  cterm=NONE
hi Search                      ctermfg=10   ctermbg=21   cterm=NONE
hi Visual                      ctermfg=11   ctermbg=20   cterm=NONE
hi WildMenu                    ctermfg=11   ctermbg=20   cterm=NONE
hi PMenuSbar                   ctermfg=255  ctermbg=61   cterm=NONE
hi PMenuSel                    ctermfg=11   ctermbg=237  cterm=NONE
hi PMenu                       ctermfg=255  ctermbg=4    cterm=NONE
hi PMenuThumb                  ctermfg=255  ctermbg=61   cterm=NONE
hi WarningMsg                  ctermfg=11   ctermbg=20   cterm=NONE
hi ErrorMsg                    ctermfg=184  ctermbg=88   cterm=bold
hi Error                       ctermfg=15   ctermbg=95   cterm=NONE
hi Cursor                      ctermfg=155  ctermbg=58   cterm=NONE
hi Operator                    ctermfg=210  ctermbg=NONE cterm=NONE
hi Function                    ctermfg=212  ctermbg=NONE cterm=NONE
hi Tag                         ctermfg=176  ctermbg=NONE cterm=NONE
hi Folded                      ctermfg=252  ctermbg=54   cterm=NONE
hi FoldColumn                  ctermfg=104  ctermbg=236  cterm=NONE
hi DiffText                    ctermfg=230  ctermbg=239  cterm=NONE
hi DiffAdd                     ctermfg=230  ctermbg=65   cterm=NONE
hi DiffDelete                  ctermfg=230  ctermbg=95   cterm=NONE
hi DiffChange                  ctermfg=230  ctermbg=24   cterm=NONE
hi StorageClass                ctermfg=213  ctermbg=NONE cterm=NONE
hi Structure                   ctermfg=213  ctermbg=NONE cterm=NONE
hi Underlined                  ctermfg=172  ctermbg=NONE cterm=NONE
hi Label                       ctermfg=213  ctermbg=NONE cterm=NONE
hi mbenormal                   ctermfg=187  ctermbg=237  cterm=NONE
hi perlspecialstring           ctermfg=176  ctermbg=238  cterm=NONE
hi doxygenspecial              ctermfg=222  ctermbg=NONE cterm=NONE
hi mbechanged                  ctermfg=255  ctermbg=237  cterm=NONE
hi mbevisiblechanged           ctermfg=255  ctermbg=60   cterm=NONE
hi doxygenparam                ctermfg=222  ctermbg=NONE cterm=NONE
hi doxygensmallspecial         ctermfg=222  ctermbg=NONE cterm=NONE
hi doxygenprev                 ctermfg=222  ctermbg=NONE cterm=NONE
hi perlspecialmatch            ctermfg=176  ctermbg=238  cterm=NONE
hi cformat                     ctermfg=176  ctermbg=238  cterm=NONE
hi lcursor                     ctermfg=238  ctermbg=120  cterm=NONE
hi cursorim                    ctermfg=238  ctermbg=105  cterm=NONE
hi doxygenspecialmultilinedesc ctermfg=130  ctermbg=NONE cterm=NONE
hi taglisttagname              ctermfg=105  ctermbg=NONE cterm=NONE
hi doxygenbrief                ctermfg=215  ctermbg=NONE cterm=NONE
hi mbevisiblenormal            ctermfg=252  ctermbg=60   cterm=NONE
hi doxygenspecialonelinedesc   ctermfg=130  ctermbg=NONE cterm=NONE
hi doxygencomment              ctermfg=130  ctermbg=NONE cterm=NONE
hi cspecialcharacter           ctermfg=176  ctermbg=238  cterm=NONE
hi SpecialKey                  ctermfg=135  ctermbg=NONE cterm=NONE
hi MatchParen                  ctermfg=238  ctermbg=120  cterm=NONE
hi Repeat                      ctermfg=213  ctermbg=NONE cterm=NONE

"Color definition for gui gvim
hi Normal                      guifg=#753f05 guibg=#1e1e27 guisp=#1e1e27 gui=NONE
hi NonText                     guifg=#8b8bcd guibg=NONE    guisp=NONE    gui=NONE
hi Comment                     guifg=#0b4712 guibg=NONE    guisp=NONE    gui=NONE
hi SpecialComment              guifg=#c080d0 guibg=NONE    guisp=NONE    gui=NONE
hi SpecialChar                 guifg=#c080d0 guibg=#404040 guisp=#404040 gui=NONE
hi Special                     guifg=#c080d0 guibg=NONE    guisp=NONE    gui=NONE
hi Directory                   guifg=#00ff8b guibg=NONE    guisp=NONE    gui=NONE
hi LineNr                      guifg=#1ef537 guibg=#2e2e2e guisp=#2e2e2e gui=NONE
hi ModeMsg                     guifg=#7e7eae guibg=NONE    guisp=NONE    gui=NONE
hi MoreMsg                     guifg=#c93c53 guibg=NONE    guisp=NONE    gui=NONE
hi Title                       guifg=#ad814b guibg=NONE    guisp=NONE    gui=NONE
hi Number                      guifg=#00ffdd guibg=NONE    guisp=NONE    gui=NONE
hi Float                       guifg=#f0ad6d guibg=NONE    guisp=NONE    gui=NONE
hi Boolean                     guifg=#808bed guibg=NONE    guisp=NONE    gui=NONE
hi String                      guifg=#5bff52 guibg=#404040 guisp=#404040 gui=NONE
hi Character                   guifg=#ffcd8b guibg=NONE    guisp=NONE    gui=NONE
hi Identifier                  guifg=#bd8d46 guibg=NONE    guisp=NONE    gui=NONE
hi Statement                   guifg=#0d73e0 guibg=NONE    guisp=NONE    gui=NONE
hi Conditional                 guifg=#ff8bff guibg=NONE    guisp=NONE    gui=NONE
hi Exception                   guifg=#ff8bff guibg=NONE    guisp=NONE    gui=NONE
hi Keyword                     guifg=#e0ce0d guibg=NONE    guisp=NONE    gui=NONE
hi Type                        guifg=#ffffff guibg=NONE    guisp=NONE    gui=NONE
hi Delimiter                   guifg=#991fb8 guibg=NONE    guisp=NONE    gui=NONE
hi Define                      guifg=#409090 guibg=NONE    guisp=NONE    gui=NONE
hi Typedef                     guifg=#ff8bff guibg=NONE    guisp=NONE    gui=NONE
hi PreCondit                   guifg=#409090 guibg=NONE    guisp=NONE    gui=NONE
hi PreProc                     guifg=#409090 guibg=NONE    guisp=NONE    gui=NONE
hi Include                     guifg=#409090 guibg=NONE    guisp=NONE    gui=NONE
hi Macro                       guifg=#409090 guibg=NONE    guisp=NONE    gui=NONE
hi Debug                       guifg=#c080d0 guibg=NONE    guisp=NONE    gui=NONE
hi type                        guifg=#ffffff guibg=NONE    guisp=NONE    gui=NONE
hi Question                    guifg=#ffcd00 guibg=NONE    guisp=NONE    gui=NONE
hi VertSplit                   guifg=#e1f009 guibg=#0d0de0 guisp=#0d0de0 gui=NONE
hi Todo                        guifg=#f50c20 guibg=#d0a060 guisp=#d0a060 gui=NONE
hi StatusLine                  guifg=#0af70a guibg=#0011ff guisp=#0011ff gui=NONE
hi StatusLineNC                guifg=#0af70a guibg=#0011ff guisp=#0011ff gui=NONE
hi IncSearch                   guifg=#133002 guibg=#b57253 guisp=#b57253 gui=NONE
hi Search                      guifg=#0af70a guibg=#0011ff guisp=#0011ff gui=NONE
hi Visual                      guifg=#e1f009 guibg=#0d0de0 guisp=#0d0de0 gui=NONE
hi WildMenu                    guifg=#81960c guibg=#7d6009 guisp=#7d6009 gui=NONE
hi PMenuSbar                   guifg=#eeeeee guibg=#6e6eaf guisp=#6e6eaf gui=NONE
hi PMenuSel                    guifg=#eeeeee guibg=#2e2e3f guisp=#2e2e3f gui=NONE
hi PMenu                       guifg=#eeeeee guibg=#4e4e8f guisp=#4e4e8f gui=NONE
hi PMenuThumb                  guifg=#eeeeee guibg=#6e6eaf guisp=#6e6eaf gui=NONE
hi WarningMsg                  guifg=#e1f009 guibg=#0d0de0 guisp=#0d0de0 gui=NONE
hi ErrorMsg                    guifg=#dbdb03 guibg=#940909 guisp=#940909 gui=NONE
hi Error                       guifg=#ffffff guibg=#6e2e2e guisp=#6e2e2e gui=NONE
hi Cursor                      guifg=#aaf539 guibg=#435400 guisp=#435400 gui=NONE
hi Operator                    guifg=#ff8bff guibg=NONE    guisp=NONE    gui=NONE
hi Function                    guifg=#ff8ce0 guibg=NONE    guisp=NONE    gui=NONE
hi Tag                         guifg=#c080d0 guibg=NONE    guisp=NONE    gui=NONE
hi Folded                      guifg=#cfcfcd guibg=#4b208f guisp=#4b208f gui=NONE
hi FoldColumn                  guifg=#8b8bcd guibg=#2e2e2e guisp=#2e2e2e gui=NONE
hi DiffText                    guifg=#ffffcd guibg=#4a2a4a guisp=#4a2a4a gui=NONE
hi DiffAdd                     guifg=#ffffcd guibg=#306d30 guisp=#306d30 gui=NONE
hi DiffDelete                  guifg=#ffffcd guibg=#6d3030 guisp=#6d3030 gui=NONE
hi DiffChange                  guifg=#ffffcd guibg=#306b8f guisp=#306b8f gui=NONE
hi StorageClass                guifg=#ff8bff guibg=NONE    guisp=NONE    gui=NONE
hi Structure                   guifg=#ff8bff guibg=NONE    guisp=NONE    gui=NONE
hi Underlined                  guifg=#df9f2d guibg=NONE    guisp=NONE    gui=NONE
hi Label                       guifg=#ff8bff guibg=NONE    guisp=NONE    gui=NONE
hi mbenormal                   guifg=#cfbfad guibg=#2e2e3f guisp=#2e2e3f gui=NONE
hi perlspecialstring           guifg=#c080d0 guibg=#404040 guisp=#404040 gui=NONE
hi doxygenspecial              guifg=#fdd090 guibg=NONE    guisp=NONE    gui=NONE
hi mbechanged                  guifg=#eeeeee guibg=#2e2e3f guisp=#2e2e3f gui=NONE
hi mbevisiblechanged           guifg=#eeeeee guibg=#4e4e8f guisp=#4e4e8f gui=NONE
hi doxygenparam                guifg=#fdd090 guibg=NONE    guisp=NONE    gui=NONE
hi doxygensmallspecial         guifg=#fdd090 guibg=NONE    guisp=NONE    gui=NONE
hi doxygenprev                 guifg=#fdd090 guibg=NONE    guisp=NONE    gui=NONE
hi perlspecialmatch            guifg=#c080d0 guibg=#404040 guisp=#404040 gui=NONE
hi cformat                     guifg=#c080d0 guibg=#404040 guisp=#404040 gui=NONE
hi lcursor                     guifg=#404040 guibg=#8fff8b guisp=#8fff8b gui=NONE
hi cursorim                    guifg=#404040 guibg=#8b8bff guisp=#8b8bff gui=NONE
hi doxygenspecialmultilinedesc guifg=#ad600b guibg=NONE    guisp=NONE    gui=NONE
hi taglisttagname              guifg=#808bed guibg=NONE    guisp=NONE    gui=NONE
hi doxygenbrief                guifg=#fdab60 guibg=NONE    guisp=NONE    gui=NONE
hi mbevisiblenormal            guifg=#cfcfcd guibg=#4e4e8f guisp=#4e4e8f gui=NONE
hi doxygenspecialonelinedesc   guifg=#ad600b guibg=NONE    guisp=NONE    gui=NONE
hi doxygencomment              guifg=#ad7b20 guibg=NONE    guisp=NONE    gui=NONE
hi cspecialcharacter           guifg=#c080d0 guibg=#404040 guisp=#404040 gui=NONE
hi SpecialKey                  guifg=#ab60ed guibg=NONE    guisp=NONE    gui=NONE
hi MatchParen                  guifg=#404040 guibg=#8fff8b guisp=#8fff8b gui=NONE
hi Repeat                      guifg=#ff8bff guibg=NONE    guisp=NONE    gui=NONE

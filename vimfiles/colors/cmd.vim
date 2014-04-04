" About: I used "blue.vim" as a starting point. Just about
" everything is different though. The scheme was made for the
" 16 color full screen console in Windows XP. It's named "cmd"
" after cmd.exe.
"
" Options that can inherit color from a parent are indented
" under their parent. They are commented to inherit.
"
" Possible_Colors: black white red darkRed yellow
" darkYellow blue darkBlue magenta darkMagenta
" green darkGreen gray darkGray cyan darkCyan

set background=light
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "cmd"
set t_Co=16

hi Normal		ctermfg=black		ctermbg=gray

hi NonText		ctermfg=blue		ctermbg=bg
hi comment		ctermfg=darkGreen	ctermbg=bg
hi constant		ctermfg=darkRed		ctermbg=bg
	"hi String	ctermfg=darkRed		ctermbg=bg
	"hi Character ctermfg=darkRed	ctermbg=bg
	"hi Number	ctermfg=darkRed		ctermbg=bg
	"hi Boolean	ctermfg=darkRed		ctermbg=bg
	"hi Float	ctermfg=cyan		ctermbg=bg
	
hi identifier	ctermfg=black	ctermbg=darkGray
	"this seems to work on vim script functions, not C functions
	"hi function	ctermfg=black		ctermbg=darkGray 
	
hi statement	ctermfg=darkBlue	ctermbg=bg	
	"hi Conditional	ctermfg=darkBlue	ctermbg=bg
	"hi Repeat	ctermfg=darkBlue	ctermbg=bg
	hi Label	ctermfg=black		ctermbg=darkGray
	hi Operator	ctermfg=darkblue	ctermbg=bg
	"hi Keyword	ctermfg=darkBlue	ctermbg=bg
	"hi Exception ctermfg=darkBlue	ctermbg=bg
	
hi preproc		ctermfg=darkMagenta	ctermbg=bg
	"hi Include	ctermfg=darkMagenta	ctermbg=bg
	"hi Define	ctermfg=darkMagenta	ctermbg=bg
	"hi Macro	ctermfg=darkMagenta	ctermbg=bg
	"hi PreCondit ctermfg=darkMagenta	ctermbg=bg
	
hi type			ctermfg=darkBlue		ctermbg=bg
	"hi StorageClass ctermfg=blue		ctermbg=bg
	"hi Structure	ctermfg=blue		ctermbg=bg
	"hi Typedef		ctermfg=blue		ctermbg=bg

hi special		ctermfg=blue		ctermbg=bg
	"hi SpecialChar	ctermfg=blue		ctermbg=bg
	"hi Tag			ctermfg=blue		ctermbg=bg
	"hi Delimiter	ctermfg=blue		ctermbg=bg
	"hi SpecialComment	ctermfg=blue		ctermbg=bg
	"hi Debug		ctermfg=blue		ctermbg=bg


hi Underlined	ctermfg=darkcyan	ctermbg=bg

"hi SpecialKey	ctermfg=red	ctermbg=white

"hi Ignore		ctermfg=white		ctermbg=black
"hi Conceal		ctermfg=black	ctermbg=yellow

hi ErrorMsg		ctermfg=red		ctermbg=black
hi WarningMsg	ctermfg=yellow	ctermbg=black
hi ModeMsg		ctermfg=black	ctermbg=darkGray
hi MoreMsg		ctermfg=cyan	ctermbg=black
hi Error		ctermfg=black	ctermbg=red
hi Question		ctermfg=cyan	ctermbg=black
hi Directory	ctermfg=darkRed	ctermbg=bg
hi WildMenu		ctermfg=black	ctermbg=yellow

hi Todo			ctermfg=black	ctermbg=darkYellow
hi Search		ctermfg=black	ctermbg=Yellow
hi IncSearch	ctermfg=bg		ctermbg=fg
hi LineNr		ctermfg=gray	ctermbg=darkGray

"title seems to only affect the split window count in a tab.
hi title		ctermfg=black	ctermbg=yellow

hi TabLineSel	ctermfg=gray	ctermbg=black
hi TabLine		ctermfg=black	ctermbg=darkGray
hi TabLineFill	ctermfg=fg		ctermbg=bg

hi StatusLineNC	ctermfg=darkGray	ctermbg=black
hi StatusLine	ctermfg=darkGreen	ctermbg=black
hi VertSplit	ctermfg=darkGray	ctermbg=black

hi visual		term=reverse	ctermfg=black	ctermbg=darkcyan
"hi VisualNOS	term=reverse	ctermfg=black	ctermbg=darkcyan

hi DiffChange	ctermfg=black	ctermbg=yellow
hi DiffText		ctermfg=black	ctermbg=red
hi DiffAdd		ctermfg=black	ctermbg=cyan
hi DiffDelete   ctermfg=black	ctermbg=white

hi Folded		ctermfg=black	ctermbg=darkGray
hi FoldColumn	ctermfg=black	ctermbg=gray
"hi cIf0			ctermfg=black	ctermbg=yellow

hi SignColumn	ctermfg=black	ctermbg=darkGray

hi SpellBad		ctermfg=black	ctermbg=red
hi SpellCap		ctermfg=black	ctermbg=darkYellow
hi SpellRare	ctermfg=black	ctermbg=darkYellow
hi SpellLocal	ctermfg=black	ctermbg=darkYellow

hi Pmenu		ctermfg=black	ctermbg=darkYellow
hi PmenuSel		ctermfg=black	ctermbg=magenta
hi PmenuSbar	ctermfg=none	ctermbg=darkYellow
hi PmenuThumb	ctermfg=none	ctermbg=black

hi Cursor		ctermfg=none	ctermbg=black
hi CursorLine	cterm=none		ctermfg=none	ctermbg=darkgray
hi CursorColumn	ctermfg=none	ctermbg=darkgray
hi CursorIM		ctermfg=none	ctermbg=black

hi MatchParen	ctermfg=black	ctermbg=cyan

hi ColorColumn	ctermfg=none	ctermbg=darkGray

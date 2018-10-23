syntax on
set showmatch

set linebreak " line break
set nocompatible " no compatible
set history=400 " history
set ruler
set number " line number
set hlsearch " highlight search
set noincsearch " no in C search
set expandtab " expand table
set t_vb= "close bell
set tabstop=4 " table step
set shiftwidth=4
set nobackup " don't backup
set smarttab " smart table
set smartindent " smart indent
" set autoindent " auto indent
set cindent "cindent
set cursorline " hightlight cursor line 高亮光标所在行

" set the back space
set backspace=indent,eol,start "这行比较重要，刚接触vim的朋友会发现有时候backspace键删不了文字

" colorscheme desert " color scheme

" the following function is used for show the status bar on the buttom
function! CurrectDir()
let curdir = substitute(getcwd(), "", "", "g")
return curdir
endfunction
set statusline=\ [File]\ %F%m%r%h\ %w\ \ [PWD]\ %r%{CurrectDir()}%h\ \ %=[Line]\ %l,%c\ %=\ %P

" make sure that syntax always on
if exists("syntax_on")
syntax reset
else
syntax on
endif
" Make external commands work through a pipe instead of a pseudo-tty
"set noguipty

" You can also specify a different font, overriding the default font
"if has('gui_gtk2')
"  set guifont=Bitstream\ Vera\ Sans\ Mono\ 12
"else
"  set guifont=-misc-fixed-medium-r-normal--14-130-75-75-c-70-iso8859-1
"endif

" If you want to run gvim with a dark background, try using a different
" colorscheme or running 'gvim -reverse'.
" http://www.cs.cmu.edu/~maverick/VimColorSchemeTest/ has examples and
" downloads for the colorschemes on vim.org

" Source a global configuration file if available
if filereadable("/etc/vim/gvimrc.local")
  source /etc/vim/gvimrc.local
endif

" highlighting syntax
syntax on
 
" sets dark color scheme
colorscheme evening 

" loads vim confgi that makes ctrl + c ; ctrl + v works
so $VIMRUNTIME/mswin.vim 

" makes the text selection works like in MS WIN
behave mswin

" displaying line numbers
set number 

" makes the tab to be 4 space equal
set expandtab shiftwidth=4 softtabstop=4 

" sets initial size of gvim window
set lines=35 columns=90

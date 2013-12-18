scriptencoding utf-8
" Colorscheme
" colorscheme evening
set t_Co=16
set background=dark
if has("gui_running")
  colorscheme peachpuff
else
  colorscheme molokai
endif

" Interface
set laststatus=2 " Always show a status line
set showcmd      " display incomplete commands
set wildmenu     " Visual tab-completion yay!
set ruler        " show the cursor position all the time

" Where can we move on the screen? 
set textwidth=72
set virtualedit=all
set backspace=indent,eol,start

" Wrapping
set nowrap
set lbr " If we do wrap, we want it at word boundaries
set display=lastline " Show all of the last line that fits

" Indenting and tabbing
set shiftwidth=2
set tabstop=4
set expandtab
set ai
set nojoinspaces

" Show tabs, trailing spaces, or that the line extends to the left or
" right
" set listchars=tab:>,nbsp:·,trail:¬,precedes:¬,extends:¬

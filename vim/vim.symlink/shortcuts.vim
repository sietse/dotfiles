" Make navigation more amenable to long wrapping lines. 
noremap k gk
noremap j gj
noremap <Up> gk
noremap <Down> gj
noremap 0 g0
noremap g0 0
noremap ^ g^
 
inoremap <Up> <C-O>gk
inoremap <Down> <C-O>gj

" Terminal passes <S-Space> as <Space>. If there's no PgUp, it's not
" worth letting <Space> be PgDn.
nnoremap <Space> <nop>

noremap ; :
nnoremap <S-Insert> :set paste<Enter>"+P:set nopaste<Enter>
inoremap <S-Insert> <C-O>:set paste<Enter><C-O>"+P<C-O>:set nopaste<Enter>
vnoremap <C-C> "+y

" Timestamps
nnoremap <F2> O<C-R>=strftime("%Y-%m-%d")<CR>
inoremap <F2> <C-R>=strftime("%Y-%m-%d")<CR>
nnoremap <F3> O<C-R>=strftime("%H:%M")<CR>
inoremap <F3> <C-R>=strftime("%H:%M")<CR>

" My Eee has a very small Escape key, and I often hit F1 along with
" it. So let's make them both Escape.
inoremap <F1> <Esc>
nnoremap <F1> <Esc>
vnoremap <F1> <Esc>

" Some convenience keymaps
noremap <C-q> <C-v>
   "Allow Windows's visual-block keycombo, too.

" vimrc edit
nnoremap <leader>ve :split $MYVIMRC<cr>
" vimrc source (a.k.a. vimrc reload, so let's offer both mnemonics)
nnoremap <leader>vs :source $MYVIMRC<cr>
nnoremap <leader>vr :source $MYVIMRC<cr>
"
" Uppercase word in INSERT mode
inoremap <C-u> <Esc>viwU`]a

" ---------------------------------------------------------------------------
"  Strip all trailing whitespace in file
" ---------------------------------------------------------------------------

function! StripWhitespace ()
    exec ':%s///g'
    exec ':%s/ \+$//gc'
endfunction
map ,s :call StripWhitespace ()<CR>

" ---------------------------------
"  Replace entire file
" ---------------------------------

" function! pastefile()
" python << endpython
" import vim
" vim.current.buffer = # FIXME get clipboard register
" endpython
" endfunction

" ---------------------------------
"  Copy entire file
" ---------------------------------

function! CopyAll()
" python << endpython
" import vim
" vim.exec("%y+")
" endpython
w
%y+
endfunction

command! CopyAll call CopyAll()
map <F8> :call CopyAll()<CR>

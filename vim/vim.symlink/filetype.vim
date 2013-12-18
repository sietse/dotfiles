if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au! BufNewFile,BufRead *.ly           setf lilypond
  au! BufNewFile,BufRead *.ly           set dictionary+=~/.vim/syntax/lilypond.vim
augroup END

augroup filetypedetect
  au! BufNewFile,BufRead *.rtex         setf rtex
  au! BufNewFile,BufRead *.Rtex         set dictionary+=~/.vim/syntax/rtex.vim
augroup END

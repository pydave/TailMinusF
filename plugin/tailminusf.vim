" File: tailminusf.vim
" Author: Jason Heddings (vim at heddway dot com)
" Version: 2.0
" Last Modified: 02 Aug 2012
"
" See ':help tailminusf' for more information.
"
if exists('g:TailMinusF_Loaded')
  finish
endif
let g:TailMinusF_Loaded = 1


" command exports
command -nargs=1 -complete=file Tail call tailminusf#TailMinusF(<q-args>)


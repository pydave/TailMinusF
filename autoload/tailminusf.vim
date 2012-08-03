" File: tailminusf.vim
" Author: Jason Heddings (vim at heddway dot com)
" Version: 1.1
" Last Modified: 05 October, 2005
"
" See ':help tailminusf' for more information.
"   
if !exists('g:TailMinusF_Loaded')
  finish
endif


" set the default options for the plugin
if !exists("g:TailMinusF_Height")
  let g:TailMinusF_Height = 10
endif
if !exists("g:TailMinusF_Center_Win")
  let g:TailMinusF_Center_Win = 0
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" sets up the preview window to watch the specified file for changes
function! tailminusf#TailMinusF(file)
  let g:TailMinusF_status = "|"
  let l:file = substitute(expand(a:file), "\\", "/", "g")

  if !filereadable(l:file)
    echohl ErrorMsg | echo "Cannot open for reading: " . l:file | echohl None
    return
  endif

  " if the buffer is already open, kill it
  pclose  " in case there is a preview window already, also removes autocmd's
  if bufexists(bufnr(l:file))
    execute ':' . bufnr(l:file) . 'bwipeout'
  endif

  " set it up to be watched closely
  augroup TailMinusF
    " monitor calls -- try to catch the update as much as possible
    autocmd CursorHold * call tailminusf#Monitor()
    autocmd FocusLost * call tailminusf#Monitor()
    autocmd FocusGained * call tailminusf#Monitor()

    " utility calls
    execute "autocmd BufWinEnter " . l:file . " call tailminusf#Setup()"
    execute "autocmd BufWinLeave " . l:file . " call tailminusf#Stop()"
    execute "autocmd FileChangedShellPost " . l:file . " :call tailminusf#Refresh()"
  augroup END

  " set up the new window with minimal functionality
  silent execute g:TailMinusF_Height . "new " . l:file
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" used by TailMinusF to check the file status
function! tailminusf#Monitor()
  " do our file change checks
  checktime   " the easy check

  " update the status indicator
  if g:TailMinusF_status == "|"
    let g:TailMinusF_status = "/"
  elseif g:TailMinusF_status == "/"
    let g:TailMinusF_status = "-"
  elseif g:TailMinusF_status == "-"
    let g:TailMinusF_status = "\\"
  elseif g:TailMinusF_status == "\\"
    let g:TailMinusF_status = "|"
  endif
  return g:TailMinusF_status
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" used by TailMinusF to set up the preview window settings
function! tailminusf#Setup()
  setlocal noswapfile
  setlocal noshowcmd
  setlocal bufhidden=delete
  setlocal nobuflisted
  setlocal nomodifiable
  setlocal nowrap
  setlocal nonumber
  setlocal previewwindow
  setlocal autoread
  "setlocal statusline=%F\ %{tailminusf#Monitor()}

  call tailminusf#SetCursor()
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" used by TailMinusF to refresh the window contents & position
" use this instead of autoread for silent reloading and better control
function! tailminusf#Refresh()
  if &previewwindow
    " if the cursor is on the last line, we'll move it with the update
    if line(".") == line("$")
      call tailminusf#SetCursor()
    endif
  else
    " jump to the preview window to reload
    wincmd P

    " do all the necessary updates
    call tailminusf#SetCursor()

    " jump back
    wincmd p
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" used by TailMinusF to set the cursor position in the preview window
" assumes that the correct window has already been selected
function! tailminusf#SetCursor()
  normal G
  if g:TailMinusF_Center_Win
    normal zz
  endif
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" used by TailMinusF to stop watching the file and clean up
function! tailminusf#Stop()
  autocmd! TailMinusF
  augroup! TailMinusF
endfunction

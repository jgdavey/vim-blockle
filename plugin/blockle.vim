" blockle.vim - Ruby Block Toggling
" Author:       Joshua Davey <josh@joshuadavey.com>
" Version:      0.1
"
" Licensed under the same terms as Vim itself.
" ============================================================================

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set
if (exists("g:loaded_blockle") && g:loaded_blockle) || &cp
    finish
endif
let g:loaded_blockle = 1

let s:cpo_save = &cpo
set cpo&vim

function! s:ConvertBracketsToDoEnd()
  let char = getline('.')[col('.')-1]
  if char=='}'
    norm %
  endif
  norm h
  " Bracket touching previous word
  if getline('.')[col('.')-1] =~ '[^ ;]'
    exe "norm! a "
  endif
  norm l
  let begin_pos = getpos('.')
  let begin_num = line('.')
  let begin_line = getline('.')
  norm %
  let end_pos = getpos('.')
  let end_num = line('.')

  call setpos('.', begin_pos)
  norm! sdo
  call setpos('.', end_pos)
  if getline('.')[col('.')-1] != 'e'
    norm! l
  endif
  norm! send
  call setpos('.', begin_pos)
  " Still need to fix indentation

  if begin_num == end_num " Was a one-liner
    " Has block parameters
    if search('\vdo *\|', 'c', begin_num)
      let end_of_line = '2f|'
    else
      let end_of_line = 'e'
    endif
    call setpos('.', end_pos)
    exe "norm! i\<cr>"
    let end_pos = getpos('.')
    call setpos('.', begin_pos)
    exe "norm! ".end_of_line."a\<cr>"
    call setpos('.', begin_pos)
    if search('do|', 'c', begin_num) | :.s/do|/do |/ | endif
    exe begin_num.','.end_num.'Trim'
    call setpos('.', begin_pos)
  endif
endfunction

function! s:ConvertDoEndToBrackets()
  let char = getline('.')[col('.')-1]
  let w = expand('<cword>')
  if w=='end'
    norm %
  elseif char == 'o'
    norm! h
  endif
  let do_pos = getpos('.')
  let begin_num = line('.')
  norm %
  let end_pos = getpos('.')
  let end_num = line('.')

  norm ciw}
  call setpos('.', do_pos)
  norm ciw{

  if (end_num-begin_num) == 2
    norm! JJ
    " Remove extraneous spaces
    if search('  \+', 'c', begin_num) | :.s/\([^ ]\)  \+/\1 /g | endif
    call setpos('.', do_pos)
  endif
endfunction

function! s:goToNearestBlockBounds()
  let char = getline('.')[col('.')-1]
  if char =~ '[{}]'
    return char
  endif

  let word = expand('<cword>')
  if word =~ '\vdo|end'
    return word
  endif

  let endline = line('.')+5
  echo endline
  if search('\vend|}', 'cs', endline)
    return expand('<cword>')
  endif

  return ''
endfunction

function! s:ToggleDoEndOrBrackets()
  if &ft!='ruby' | return | endif

  let block_bound = s:goToNearestBlockBounds()

  if block_bound =~ '[{}]'
    call <SID>ConvertBracketsToDoEnd()
  elseif block_bound =~ '\vdo|end'
    call <SID>ConvertDoEndToBrackets()
  else
    throw 'Cannot toggle block: cursor is not on {, }, do or end'
  endif

  silent! call repeat#set("\<Plug>BlockToggle", -1)
endfunction

nnoremap <silent> <Plug>BlockToggle :<C-U>call <SID>ToggleDoEndOrBrackets()<CR>

map <leader>b <Plug>BlockToggle


let &cpo = s:cpo_save

" vim:set ft=vim ff=unix ts=4 sw=2 sts=2:

" blockle.vim - Ruby Block Toggling
" Author:       Joshua Davey <josh@joshuadavey.com>
" Version:      0.4
"
" Licensed under the same terms as Vim itself.
" ============================================================================

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set
if (exists('g:loaded_blockle') && g:loaded_blockle) || &cp
  finish
endif
let g:loaded_blockle = 1

let s:cpo_save = &cpo
set cpo&vim

function! s:CharUnderCursor()
  return getline('.')[col('.') - 1]
endfunction

function! s:CharBeforeCursor()
  return getline('.')[col('.') - 2]
endfunction

function! s:WordUnderCursor()
  return expand('<cword>')
endfunction

function! s:WordUnderCursorEquals(word)
  return s:WordUnderCursor() ==# a:word
endfunction

function! s:CharUnderCursorEquals(char)
  return s:CharUnderCursor() ==# a:char
endfunction

function! s:CharBeforeCursorMatches(pattern)
  return s:CharBeforeCursor() =~# a:pattern
endfunction

function! s:ReplaceOpeningBracketWithDo()
  " The cursor has to be on the opening bracket.
  normal! sdo
endfunction

function! s:ReplaceClosingBracketWithEnd()
  " The cursor has to be on the closing bracket.
  normal! send
endfunction

function! s:SetCursorPosition(position)
  call setpos('.', a:position)
endfunction

function! s:InsertCharBeforeCursor(char)
  exe 'normal! i'.a:char."\<esc>l"
endfunction

function! s:ConvertOneLinerBracketsToDoEnd(start_position, end_position, start_line)
  let end_position = a:end_position
  if s:CharUnderCursorEquals(' ')
    normal! x
  else
    normal! l
    let end_position = getpos('.')
  endif
  set paste
  normal! send
  set nopaste
  call s:SetCursorPosition(a:start_position)

  " Has block parameters
  if search('\vdo *\|', 'c', a:start_line)
    let end_of_line = '2f|'
  else
    let end_of_line = 'e'
  endif
  call s:SetCursorPosition(end_position)
  exe "normal! i\<cr>"
  call s:SetCursorPosition(a:start_position)
  exe 'normal! '.end_of_line."a\<cr>"
  call s:SetCursorPosition(a:start_position)
  if search('do|', 'c', a:start_line)
    :.s/do|/do |/
    call s:SetCursorPosition(a:start_position)
  endif
endfunction

function! s:ConvertBracketsToDoEnd()
  " Cursor should be on the opening bracket.

  " Bracket touching previous word.
  if s:CharBeforeCursorMatches('[^ ;]')
    call s:InsertCharBeforeCursor(' ')
  endif

  let start_position = getpos('.')
  let start_line = line('.')
  normal! %
  let end_position = getpos('.')
  let end_line = line('.')

  call s:SetCursorPosition(start_position)
  call s:ReplaceOpeningBracketWithDo()
  call s:SetCursorPosition(end_position)

  if start_line == end_line " Was a one-liner
    call s:ConvertOneLinerBracketsToDoEnd(start_position, end_position, start_line)
  else
    call s:ReplaceClosingBracketWithEnd()
    call s:SetCursorPosition(start_position)
  endif
endfunction

function! s:ConvertDoEndToBrackets()
  if s:WordUnderCursorEquals('end')
    normal! %
  elseif s:CharUnderCursorEquals('o')
    normal! h
  endif
  let do_pos = getpos('.')
  let begin_num = line('.')
  normal! %
  let try_again = 10
  while try_again && s:WordUnderCursor() !=# 'end'
    let try_again = try_again - 1
    normal! %
  endwhile
  let lines = (line('.')-begin_num+1)

  normal! ciw}
  call s:SetCursorPosition(do_pos)
  normal! de

  let line = getline(begin_num)
  let before_do_str = strpart(line, 0, do_pos[2] - 1)
  let after_do_str  = strpart(line, do_pos[2] - 1)

  call setline(begin_num, before_do_str . '{' . after_do_str)

  if lines == 3
    normal! JJ
    " Remove extraneous spaces
    " if search('  \+', 'c', begin_num) | :.s/\([^ ]\)  \+/\1 /g | endif
    call s:SetCursorPosition(do_pos)
  endif
endfunction

function! s:goToNearestBlockBounds()
  if s:CharUnderCursorEquals('}')
    normal! %
    return
  elseif s:WordUnderCursorEquals('do') || s:WordUnderCursorEquals('end') && s:CharUnderCursor() !=# ' '
    return s:WordUnderCursor()
  elseif searchpair('{', '', '}', 'bcW')
    return
  elseif searchpair('\<do\>', '', '\<end\>\zs', 'bcW',
        \ 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string"')
    return s:WordUnderCursor()
  else
    return ''
  endif
endfunction

function! s:ToggleDoEndOrBrackets()
  " Save anonymous register and clipboard settings
  let reg = getreg('"', 1)
  let regtype = getregtype('"')
  let cb_save = &clipboard
  set clipboard-=unnamed
  let paste_mode = &paste

  let block_bound = s:goToNearestBlockBounds()
  echo 'block_bound = "'.block_bound.'"'
  if s:CharUnderCursorEquals('{')
    call s:ConvertBracketsToDoEnd()
  elseif block_bound ==# 'do' || block_bound ==# 'end'
    call s:ConvertDoEndToBrackets()
  else
    echo 'Cannot toggle block: cursor is not on {, }, do or end'
  endif

  " Restore anonymous register and clipboard settings
  call setreg('"', reg, regtype)
  let &clipboard = cb_save
  let &paste = paste_mode

  silent! call repeat#set("\<Plug>BlockToggle", -1)
endfunction

nnoremap <silent> <Plug>BlockToggle :<C-U>call <SID>ToggleDoEndOrBrackets()<CR>

if !exists('g:blockle_mapping')
  let g:blockle_mapping = '<Leader>b'
endif

augroup blockle
  autocmd!
  exec 'autocmd FileType ruby map <buffer> ' . g:blockle_mapping . ' <Plug>BlockToggle'
augroup END

let &cpo = s:cpo_save

" vim:set ft=vim ff=unix ts=4 sw=2 sts=2:

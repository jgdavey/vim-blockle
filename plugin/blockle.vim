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

function! s:ConvertBracketsToDoEnd()
  let char = getline('.')[col('.')-1]
  if char ==# '}'
    normal %
  endif
  normal! h
  " Bracket touching previous word
  if getline('.')[col('.')-1] =~# '[^ ;]'
    exe 'normal! a '
  endif
  normal! l
  let begin_pos = getpos('.')
  let begin_num = line('.')
  normal %
  let end_pos = getpos('.')
  let end_num = line('.')

  call setpos('.', begin_pos)
  normal! sdo
  call setpos('.', end_pos)

  if begin_num == end_num " Was a one-liner
    if getline('.')[col('.')-1] ==# ' '
      normal! x
    else
      normal! l
      let end_pos = getpos('.')
    endif
    set paste
    normal! send
    set nopaste
    call setpos('.', begin_pos)

    " Has block parameters
    if search('\vdo *\|', 'c', begin_num)
      let end_of_line = '2f|'
    else
      let end_of_line = 'e'
    endif
    call setpos('.', end_pos)
    exe "normal! i\<cr>"
    call setpos('.', begin_pos)
    exe 'normal! '.end_of_line."a\<cr>"
    call setpos('.', begin_pos)
    if search('do|', 'c', begin_num)
      :.s/do|/do |/
      call setpos('.', begin_pos)
    endif
  else
    normal! send
    call setpos('.', begin_pos)
  endif
endfunction

function! s:ConvertDoEndToBrackets()
  let char = getline('.')[col('.')-1]
  let w = expand('<cword>')
  if w ==# 'end'
    normal %
  elseif char ==# 'o'
    normal! h
  endif
  let do_pos = getpos('.')
  let begin_num = line('.')
  normal %
  let try_again = 10
  while try_again && expand('<cword>') !=# 'end'
    let try_again = try_again - 1
    normal %
  endwhile
  let lines = (line('.')-begin_num+1)

  normal! ciw}
  call setpos('.', do_pos)
  normal! de

  let line = getline(begin_num)
  let before_do_str = strpart(line, 0, do_pos[2] - 1)
  let after_do_str  = strpart(line, do_pos[2] - 1)

  call setline(begin_num, before_do_str . '{' . after_do_str)

  if lines == 3
    normal! JJ
    " Remove extraneous spaces
    " if search('  \+', 'c', begin_num) | :.s/\([^ ]\)  \+/\1 /g | endif
    call setpos('.', do_pos)
  endif
endfunction

function! s:goToNearestBlockBounds()
  let char = getline('.')[col('.')-1]
  if char ==# '{' || char ==# '}'
    return char
  endif
  let word = expand('<cword>')
  if (word ==# 'do' || word ==# 'end') && char !=# ' '
    return word
  elseif searchpair('{', '', '}', 'bcW') > 0
    return getline('.')[col('.')-1]
  elseif searchpair('\<do\>', '', '\<end\>\zs', 'bcW',
        \ 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string"') > 0
    return expand('<cword>')
  endif

  return ''
endfunction

function! s:ToggleDoEndOrBrackets()
  " Save anonymous register and clipboard settings
  let reg = getreg('"', 1)
  let regtype = getregtype('"')
  let cb_save = &clipboard
  set clipboard-=unnamed
  let paste_mode = &paste

  let block_bound = s:goToNearestBlockBounds()
  if block_bound ==# '{' || block_bound ==# '}'
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

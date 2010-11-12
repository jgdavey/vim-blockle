function! s:ToggleBeginOrBracket()
  let c = getline('.')[col('.')-1]
  if c =~ '[{}]'
    if c=='}'
      normal %
    endif
    exe "normal! mr%s\<cr>end\<esc>me`rsdo\<cr>\<esc>='e`r"
  else
    let w = expand('<cword>')
    if w =~ 'do\|end'
      if w=='end'
        normal %
      endif
      normal mr%ciw}
      normal `rciw{
    else
      throw 'Cannot toggle block: cursor is not on {, }, do or end'
    endif
  endif
endfunction

" To use, have the cursor on either {, }, do or end, and use <leader>b

nnoremap <buffer> <leader>b :call <sid>ToggleBeginOrBracket()<cr>
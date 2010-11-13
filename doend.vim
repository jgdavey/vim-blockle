function! s:ToggleDoEndOrBrackets()
  let c = getline('.')[col('.')-1]
  if c =~ '[{}]'
    if c=='}'
      normal %
    endif
    normal md
    let begin_num = line('.')
    let begin_line = getline('.')
    normal %
    let end_num = line('.')

    normal send
    normal me`dsdo
    normal ='e`d

    if begin_num == end_num " Was a one-liner
      if begin_line =~ '\v\|.*\|'
        let end_of_line = '2f|'
      else
        let end_of_line = 'e'
      endif
      exe "normal! `ehi\<cr>\<esc>me`d".end_of_line."a\<cr>\<esc>"
      normal `d
      silent! :'d,'ds/do|/do |/
      :'d,'eTrim
      normal `d
    endif
  else
    let w = expand('<cword>')
    if w =~ 'do\|end'
      if w=='end'
        normal %
      endif
      let begin_num = line('.')
      normal md%
      let end_num = line('.')
      normal ciw}
      normal `dciw{
      if (end_num-begin_num) == 2
        normal JJ`d
      endif
    else
      throw 'Cannot toggle block: cursor is not on {, }, do or end'
    endif
  endif
endfunction

nnoremap <leader>b :call <sid>ToggleDoEndOrBrackets()<CR>

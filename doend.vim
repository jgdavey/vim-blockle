function! s:ToggleDoEndOrBrackets()
  let char = getline('.')[col('.')-1]
  if char =~ '[{}]'
    if char=='}'
      norm %
    endif
    norm md
    let begin_num = line('.')
    let begin_line = getline('.')
    norm %
    let end_num = line('.')

    norm! send
    norm me`dsdo
    norm! ='e`d

    if begin_num == end_num " Was a one-liner
      if begin_line =~ '\v\|.*\|'
        let end_of_line = '2f|'
      else
        let end_of_line = 'e'
      endif
      exe "norm! `ehi\<cr>\<esc>me`d".end_of_line."a\<cr>\<esc>"
      norm `d
      if search('do|', 'c', begin_num) | :.s/do|/do |/ | endif
      :'d,'eTrim
      norm `d
    endif
  else
    let w = expand('<cword>')
    if w =~ 'do\|end'
      if w=='end'
        norm %
      endif
      let begin_num = line('.')
      norm lbmd%
      let end_num = line('.')
      norm! ciw}
      norm! `dciw{
      if (end_num-begin_num) == 2
        norm! JJ`d
      endif
    else
      throw 'Cannot toggle block: cursor is not on {, }, do or end'
    endif
  endif
endfunction

nnoremap <leader>b :call <sid>ToggleDoEndOrBrackets()<CR>

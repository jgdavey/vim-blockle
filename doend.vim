function! s:ToggleDoEndOrBrackets()
  let char = getline('.')[col('.')-1]
  if char =~ '[{}]'
    if char=='}'
      norm %
    endif
    norm h
    " Bracket touching previous word
    if getline('.')[col('.')-1] =~ '[^ ;]'
      exe "norm! a "
    endif
    norm lmd
    let begin_num = line('.')
    let begin_line = getline('.')
    norm %
    let end_num = line('.')

    norm! send
    norm me`dsdo
    norm! ='e`d

    if begin_num == end_num " Was a one-liner
      " Has block parameters
      if search('\vdo *\|', 'c', begin_num)
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
    if w =~ '\vdo|end'
      if w=='end'
        norm %
      elseif char == 'o'
        norm! h
      endif
      let begin_num = line('.')
      norm md%
      let end_num = line('.')
      norm! ciw}
      norm! `dciw{
      if (end_num-begin_num) == 2
        norm! JJ`d
        " Remove extraneous spaces
        if search('  \+', 'c', begin_num) | :.s/\([^ ]\)  \+/\1 /g | endif
        if search('{ |', 'c', begin_num) | :.s/{ |/{|/ | endif
        normal `d
      endif
    else
      throw 'Cannot toggle block: cursor is not on {, }, do or end'
    endif
  endif
endfunction

nnoremap <leader>b :call <sid>ToggleDoEndOrBrackets()<CR>

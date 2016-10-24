let g:quick_chars = "asdfghjklm"

fun! QuicksWin() "{{{
  call Quick_Add_Entries()
endfunction "}}}

fun! Open_quicks_win() "{{{
  let l:winnr = bufwinnr('^quicks_window$')
  if l:winnr < 0
    keepalt botright new
    resize 10
    nnoremap <buffer> q ZQ
    silent f quicks_window
    setlocal wrap buftype=nowrite bufhidden=wipe nobuflisted noswapfile nonu
  endif
  norm ggdG
endfunction "}}}

fun! Quick_Add_Entries() "{{{
  let l:list_of_commands = []
  let l:start = min([10, histnr('cmd')]) - 1
  if Print_warn_when_no_history_nr()
      return
  endif
  for my in range(l:start , 0, -1)
    let l:index_cmd = histnr('cmd') - my
    let l:cmd = histget('cmd', l:index_cmd)
    if  l:cmd=~ '\v.+'
      let l:command_map = {'key' : g:quick_chars[l:start - len(l:list_of_commands)] ,
            \ 'command' : l:cmd}
      let l:list_of_commands += [l:command_map]
    endif
  endfor
  if Print_warn_when_no_history(l:list_of_commands)
    return
  endif
  call Open_quicks_win()
  for l:command_map in l:list_of_commands
    call append(0, Eval_command_map(l:command_map))
    call Prepare_mapping(l:command_map)
  endfor
  setl nomodifiable
  normal! :g/^$/d
  normal! gg
endfunction "}}}

fun! Prepare_mapping(command) "{{{
  execute 'nmap <buffer> ' . a:command['key'] . ' :normal q<cr>:' . substitute(a:command['command'] . '<cr>', '\\', '\\\\', 'g')
  execute 'nmap <buffer> g' . a:command['key'] . ' :normal q<cr>:' . substitute(a:command['command'], '\', '\\', 'g')
endfunction"}}}

fun! Eval_command_map(command_map) "{{{
  return "[" . a:command_map['key'] . "] " . a:command_map['command']
endfunction "}}}

fun! Print_warn_when_no_history_nr() "{{{
  let l:retval = 0
  if histnr('cmd') <= 0
    echohl WARNINGMSG | echo "NO HISTORY" | echohl NONE
    let l:retval = 1
  endif
  return l:retval
endfunction "}}}

fun! Print_warn_when_no_history(commands) "{{{
  let l:ret_val = 0
  if empty(a:commands)
    echohl WARNINGMSG
    echo "NO HISTORY"
    echohl NONE
    let l:ret_val = 1
  endif
  return l:ret_val
endfunction "}}}


command! Quick call QuicksWin()
nnoremap Q :Quick<cr>

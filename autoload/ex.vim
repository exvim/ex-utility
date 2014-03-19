" msg: string
function ex#warning(msg)
  echohl WarningMsg
  echomsg 'Warning(exVim): ' . a:msg
  echohl None
endfunction

" msg: string
function ex#error(msg)
  echohl ErrorMsg
  echomsg 'Error(exVim): ' . a:msg
  echohl None
endfunction

" vim:ts=2:sw=2:sts=2

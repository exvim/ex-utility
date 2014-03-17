" msg: string
function ex#warning(msg)
  echohl WarningMsg
  echomsg a:msg
  echohl None
endfunction

" vim:ts=2:sw=2:sts=2

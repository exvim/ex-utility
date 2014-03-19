" msg: string
function ex#warning(msg)
    echohl WarningMsg
    echomsg a:msg
    echohl None
endfunction

" msg: string
function ex#error(msg)
    echohl ErrorMsg
    echomsg 'Error(exVim): ' . a:msg
    echohl None
endfunction

" vim:ts=4:sw=4:sts=4 et fdm=marker:

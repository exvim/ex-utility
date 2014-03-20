
" ex#buffer#navigate {{{2
" the cmd must be 'bn', 'bp', ....
function ex#buffer#navigate(cmd)
    " TODO:
    " " if this is a registered plugin buffer, then go to the edit buffer first 
    " if exUtility#IsRegisteredPluginBuffer(bufname('%')) 
    "     call exUtility#GotoEditBuffer()
    " endif

    " 
    silent exec a:cmd."!"
endfunction

" vim:ts=4:sw=4:sts=4 et fdm=marker:

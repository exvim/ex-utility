
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

" ex#buffer#is_registered_buffer {{{2
function ex#buffer#is_registered_buffer ( bufname ) " <<<
    " if the buf didn't exists, don't do anything else
    if !bufexists(a:bufname)
        return 0
    endif

    let bufnr = bufnr(a:bufname) 
    let filetype = getbufvar( bufnr, '&filetype' )

    " if this is not empty filetype, use regular rules for buffer checking
    if filetype == ''
        let filetype = "__EMPTY__"
    endif

    " get rules directly from registered dict, if rules not found, 
    " simply return flase because we didn't register the filetype
    if !has_key( g:ex_registered_plugin, filetype )
        return 0
    endif

    " if rules is empty, which means it just need to check the filetype
    let rules = g:ex_registered_plugin[filetype]
    if empty(rules)
        return 1
    endif

    " check each rule dict to make sure this buffer meet our request
    for ruledict in rules 
        let failed = 0

        for [key, value] in items(ruledict) 
            if key ==# "bufname"
                if match( a:bufname, value ) == -1
                    echomsg ( 'bufname = ' . a:bufname . " value = " . value )
                    let failed = 1
                endif
            else
                let bufoption = getbufvar( bufnr, '&'.key )
                if bufoption !=# value 
                    echomsg ( 'bufoption = ' . bufoption . " value = " . value )
                    let failed = 1
                endif
            endif

            if failed == 1
                break
            endif
        endfor

        " congratuation, all rules passed!
        if failed == 0
            return 1
        endif
    endfor 

    return 0
endfunction

" ex#buffer#record {{{2
let s:last_edit_bufnr = -1
let s:last_edit_bufpos = []

function ex#buffer#record()
    let bufnr = bufnr('%')
    if buflisted(bufnr) 
                \ && bufloaded(bufnr)
                \ && !ex#buffer#is_registered_buffer(bufname('%'))
        let s:last_edit_bufnr = bufnr
        let s:last_edit_bufpos = getpos('.')
    endif
endfunction

" ex#buffer#swap_to_last_edit_buffer() {{{2
function ex#buffer#swap_to_last_edit_buffer() " <<<
    " check if current buffer can use swap
    if ex#buffer#is_registered_buffer(bufname('%'))
        call ex#warning('Swap buffer in plugin window is not allowed!')
        return
    endif

    " check if last_edit buffer is valid for swap
    if bufexists(s:last_edit_bufnr)
                \ && buflisted(s:last_edit_bufnr) 
                \ && bufloaded(s:last_edit_bufnr) 
        silent exec s:last_edit_bufnr."b!"
        silent call setpos('.',s:last_edit_bufpos)
        return
    endif

    " check if we can use alternate buffer '#' for swap
    let last_bufnr = bufnr("#")
    if bufexists(last_bufnr) 
                \ && buflisted(last_bufnr) 
                \ && bufloaded(last_bufnr) 
                \ && !ex#buffer#is_registered_buffer(bufname(last_bufnr))
        silent exec last_bufnr."b!"
        return
    endif

    call ex#warning ( "Can't swap to buffer " . bufname(s:last_edit_bufnr) . ", buffer not listed."  )
endfunction

" vim:ts=4:sw=4:sts=4 et fdm=marker:

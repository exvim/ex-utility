
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

" ex#buffer#record {{{
function ex#buffer#record()
    " TODO
    " let bufnr = bufnr('%')
    " let short_bufname = fnamemodify(bufname(bufnr),":p:t")
    " if buflisted(bufnr) && bufloaded(bufnr) && bufexists(bufnr) && !exUtility#IsRegisteredPluginBuffer(bufname('%'))
    "     let s:ex_swap_buf_num = bufnr
    "     let s:ex_swap_buf_pos = getpos('.')
    " endif
endfunction

" vim:ts=4:sw=4:sts=4 et fdm=marker:

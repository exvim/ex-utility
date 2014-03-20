
" ex#buffer#navigate {{{2
" the cmd must be 'bn', 'bp', ....
function ex#buffer#navigate(cmd)
    " if we are in plugin window, go back to edit window
    if ex#window#is_plugin_window()
        call ex#window#goto_edit_window()
    endif

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
                    let failed = 1
                endif
            else
                let bufoption = getbufvar( bufnr, '&'.key )
                if bufoption !=# value 
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
let s:alt_edit_bufnr = -1
let s:alt_edit_bufpos = []

function ex#buffer#record()
    let bufnr = bufnr('%')
    if buflisted(bufnr) 
                \ && bufloaded(bufnr)
                \ && !ex#buffer#is_registered_buffer(bufname('%'))
        let s:alt_edit_bufnr = bufnr
        let s:alt_edit_bufpos = getpos('.')
    endif
endfunction

" ex#buffer#to_alternate_edit_buf() {{{2
" this function will swap current buffer with alternate buffer ('aka. #') 
" it will prevent swap in plugin window, and will restore the cursor position
" after swap.
function ex#buffer#to_alternate_edit_buf() " <<<
    " check if current buffer can use swap
    if ex#window#is_plugin_window()
        call ex#warning('Swap buffer in plugin window is not allowed!')
        return
    endif

    " check if we can use alternate buffer '#' for swap
    let alt_bufnr = bufnr("#")
    if bufexists(alt_bufnr) 
                \ && buflisted(alt_bufnr) 
                \ && bufloaded(alt_bufnr) 
                \ && !ex#buffer#is_registered_buffer(bufname(alt_bufnr))
        " NOTE: because s:alt_edit_bufnr."b!" will invoke BufLeave event  
        " and that will overwrite s:alt_edit_bufpos
        let record_alt_bufpos = deepcopy(s:alt_edit_bufpos)
        let record_alt_bufnr = s:alt_edit_bufnr
        silent exec alt_bufnr."b!"

        " only recover the pos when we record the write alt buffer pos 
        if alt_bufnr == record_alt_bufnr
            silent call setpos('.',record_alt_bufpos)
        endif

        return
    endif

    call ex#warning ( "Can't swap to buffer " . fnamemodify(bufname(alt_bufnr),":p:t") . ", buffer not listed."  )
endfunction

" vim:ts=4:sw=4:sts=4 et fdm=marker:

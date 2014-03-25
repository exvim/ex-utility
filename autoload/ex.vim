" ex#hint {{{1
" msg: string
function ex#hint(msg)
    silent echohl ModeMsg
    echon a:msg
    silent echohl None
endfunction

" ex#warning {{{1
" msg: string
function ex#warning(msg)
    silent echohl WarningMsg
    echomsg a:msg
    silent echohl None
endfunction

" ex#error {{{1
" msg: string
function ex#error(msg)
    silent echohl ErrorMsg
    echomsg 'Error(exVim): ' . a:msg
    silent echohl None
endfunction

" ex#debug {{{1
" msg: string
function ex#debug(msg)
    silent echohl Special
    echom 'Debug(exVim): ' . a:msg . ', ' . expand('<sfile>') 
    silent echohl None
endfunction

" ex#register_plugin {{{1

" registered plugin used in exVim to make sure the current buffer is a
" plugin buffer.
" this is done by first check the filetype, and go through each item and 
" make sure the option of the buffer is same as the option you provide
" NOTE: if the filetype is empty, exVim will use '__EMPTY__' rules to check  
" your buffer
" DISABLE: we use ex#register_plugin instead
" let s:registered_plugin = {
"             \ 'explugin': [],
"             \ 'exproject': [], 
"             \ 'minibufexpl': [ { 'bufname': '-MiniBufExplorer-', 'buftype': 'nofile' } ], 
"             \ 'taglist': [ { 'bufname': '__Tag_List__', 'buftype': 'nofile' } ],
"             \ 'tagbar': [ { 'bufname': '__TagBar__', 'buftype': 'nofile' } ],
"             \ 'nerdtree': [ { 'bufname': 'NERD_tree_\d\+', 'buftype': 'nofile' } ], 
"             \ 'undotree': [ { 'bufname': 'undotree_\d\+', 'buftype': 'nowrite' } ],
"             \ 'diff': [ { 'bufname': 'diffpanel_\d\+', 'buftype': 'nowrite' } ], 
"             \ 'gitcommit': [], 
"             \ 'gundo': [],
"             \ 'vimfiler': [], 
"             \ '__EMPTY__': [ { 'bufname': '-MiniBufExplorer-' } ]
"             \ }
let s:registered_plugin = {}

" debug print of registered plugins
function ex#echo_registered_plugins ()
    silent echohl Statement
    echo 'List of registered plugins:'
    silent echohl None

    for [k,v] in items(s:registered_plugin)
        if empty(v)
            echo k . ': {}'
        else
            for i in v
                echo k . ': ' . string(i) 
            endfor
        endif
    endfor
endfunction

" filetype: the filetype you wish to register as plugin, can be ''
" options: buffer options you wish to check
" special options: bufname, winpos
function ex#register_plugin ( filetype, options )
    let filetype = a:filetype
    if filetype == ''
        let filetype = '__EMPTY__'
    endif

    " get rules by filetype, if not found add new rules
    let rules = []
    if !has_key( s:registered_plugin, filetype )
        let s:registered_plugin[filetype] = rules
    else
        let rules = s:registered_plugin[filetype]
    endif

    " check if we have options
    if !empty(a:options)
        silent call add ( rules, a:options ) 
    endif
endfunction

" ex#is_registered_plugin {{{1
function ex#is_registered_plugin ( bufnr )
    " if the buf didn't exists, don't do anything else
    if !bufexists(a:bufnr)
        return 0
    endif

    let bufname = bufname(a:bufnr)
    let filetype = getbufvar( a:bufnr, '&filetype' )

    " if this is not empty filetype, use regular rules for buffer checking
    if filetype == ''
        let filetype = "__EMPTY__"
    endif

    " get rules directly from registered dict, if rules not found, 
    " simply return flase because we didn't register the filetype
    if !has_key( s:registered_plugin, filetype )
        return 0
    endif

    " if rules is empty, which means it just need to check the filetype
    let rules = s:registered_plugin[filetype]
    if empty(rules)
        return 1
    endif

    " check each rule dict to make sure this buffer meet our request
    for ruledict in rules 
        let failed = 0

        for [key, value] in items(ruledict) 
            if key ==# "bufname"
                if match( bufname, value ) == -1
                    let failed = 1
                endif
            else
                let bufoption = getbufvar( a:bufnr, '&'.key )
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

" vim:ts=4:sw=4:sts=4 et fdm=marker:


" variables {{{1

" registered plugin used in exVim to make sure the current buffer is a
" plugin buffer.
" this is done by first check the filetype, and go through each item and 
" make sure the option of the buffer is same as the option you provide
" NOTE: if the filetype is empty, exVim will use '__EMPTY__' rules to check  
" your buffer
if !exists('g:ex_registered_plugin')
    let g:ex_registered_plugin = {
                \ 'explugin': [],
                \ 'exproject': [], 
                \ 'minibufexpl': [ { 'bufname': '-MiniBufExplorer-', 'buftype': 'nofile' } ], 
                \ 'taglist': [ { 'bufname': '__Tag_List__', 'buftype': 'nofile' } ],
                \ 'tagbar': [ { 'bufname': '__TagBar__', 'buftype': 'nofile' } ],
                \ 'nerdtree': [ { 'bufname': 'NERD_tree_\d\+', 'buftype': 'nofile' } ], 
                \ 'undotree': [ { 'bufname': 'undotree_\d\+', 'buftype': 'nowrite' } ],
                \ 'diff': [ { 'bufname': 'diffpanel_\d\+', 'buftype': 'nowrite' } ], 
                \ 'gitcommit': [], 
                \ 'gundo': [],
                \ 'vimfiler': [], 
                \ '__EMPTY__': [ { 'bufname': '-MiniBufExplorer-' } ]
                \ }
endif

" }}}1

" commands {{{1
command! EXbn call ex#buffer#navigate('bn')
command! EXbp call ex#buffer#navigate('bp')
" }}}1

" autocmd {{{1
augroup ex_auto_cmds
    autocmd VimEnter,WinLeave * call ex#window#record()
    autocmd BufLeave * call ex#buffer#record()
augroup END
" }}}1

" vim:ts=4:sw=4:sts=4 et fdm=marker:

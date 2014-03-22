
" variables {{{1

" }}}1

" commands {{{1
command! EXbn call ex#buffer#navigate('bn')
command! EXbp call ex#buffer#navigate('bp')
command! EXbalt call ex#buffer#to_alternate_edit_buf()
command! EXbd call ex#buffer#keep_window_bd()

command! EXwp call ex#window#switch_window()

command! EXplugins call ex#echo_registered_plugins()
" }}}1

" autocmd {{{1
augroup ex_utility
    au!
    au VimEnter,WinLeave * call ex#window#record()
    au BufLeave * call ex#buffer#record()
augroup END
" }}}1

" register Vim builtin window
silent call ex#register_plugin( 'help', { 'buftype': 'help' } )
silent call ex#register_plugin( 'qf', { 'buftype': 'quickfix' } )
" register ex-plugins
silent call ex#register_plugin( 'explugin', {} )
silent call ex#register_plugin( 'exproject', {} )
" register 3rd-plugins
silent call ex#register_plugin( 'minibufexpl', { 'bufname': '-MiniBufExplorer-', 'buftype': 'nofile' } )
silent call ex#register_plugin( 'taglist', { 'bufname': '__Tag_List__', 'buftype': 'nofile' } )
silent call ex#register_plugin( 'tagbar', { 'bufname': '__TagBar__', 'buftype': 'nofile' } )
silent call ex#register_plugin( 'nerdtree', { 'bufname': 'NERD_tree_\d\+', 'buftype': 'nofile' } )
silent call ex#register_plugin( 'undotree', { 'bufname': 'undotree_\d\+', 'buftype': 'nowrite' } )
silent call ex#register_plugin( 'diff', { 'bufname': 'diffpanel_\d\+', 'buftype': 'nowrite' } )
silent call ex#register_plugin( 'gitcommit', {} )
silent call ex#register_plugin( 'gundo', {} )
silent call ex#register_plugin( 'vimfiler', {} )
" register empty filetype 
silent call ex#register_plugin( '__EMPTY__', { 'bufname': '-MiniBufExplorer-' } )

" vim:ts=4:sw=4:sts=4 et fdm=marker:

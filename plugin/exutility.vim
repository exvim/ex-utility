
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

" vim:ts=4:sw=4:sts=4 et fdm=marker:

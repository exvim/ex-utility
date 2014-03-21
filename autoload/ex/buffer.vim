
" ex#buffer#navigate {{{2
" the cmd must be 'bn', 'bp', ....
function ex#buffer#navigate(cmd)
    " if we are in plugin window, go back to edit window
    if ex#window#is_plugin_window()
        call ex#window#goto_edit_window()
    endif

    silent exec a:cmd."!"
endfunction

" ex#buffer#record {{{2
let s:alt_edit_bufnr = -1
let s:alt_edit_bufpos = []

function ex#buffer#record()
    let bufnr = bufnr('%')
    if buflisted(bufnr) 
                \ && bufloaded(bufnr)
                \ && !ex#is_registered_plugin(bufname('%'))
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
                \ && !ex#is_registered_plugin(bufname(alt_bufnr))
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

" ex#buffer#keep_window_bd {{{1
" Desc: VimTip #1119: How to use Vim like an IDE
" delete the buffer; keep windows; create a scratch buffer if no buffers left 
" Using this Kwbd function (:call ex#buffer#keep_window_bd(1)) will make Vim behave like an IDE; 
" or maybe even better. 

function ex#buffer#keep_window_bd(stage) " <<<
    if a:stage == 1
        " if you are in plugin window. close it directly.
        " NOTE: if use \bd close a plugin window, when reopen will loose plugin ability problem
        if ex#window#is_plugin_window()
            silent exec 'close'
            call ex#window#goto_edit_window()
            return
        endif

        "
        if !buflisted(winbufnr(0)) 
            bd! 
            return 
        endif 
        let s:kwbdBufNum = bufnr("%") 
        let s:kwbdWinNum = winnr() 
        windo call ex#buffer#keep_window_bd(2) 
        exe s:kwbdWinNum . 'wincmd w'
        let s:kwbdBuflistedLeft = 0 
        let s:kwbdBufFinalJump = 0 
        let l:nBufs = bufnr("$") 
        let l:i = 1 
        while l:i <= l:nBufs 
            if l:i != s:kwbdBufNum 
                if buflisted(l:i) 
                    let s:kwbdBuflistedLeft = s:kwbdBuflistedLeft + 1 
                else 
                    if bufexists(l:i) && !strlen(bufname(l:i)) && !s:kwbdBufFinalJump 
                        let s:kwbdBufFinalJump = l:i 
                    endif 
                endif 
            endif 
            let l:i = l:i + 1 
        endwhile 
        if !s:kwbdBuflistedLeft 
            if s:kwbdBufFinalJump 
                windo if buflisted(winbufnr(0)) | execute "b! " . s:kwbdBufFinalJump | endif 
            else 
                silent exec 'enew' 
                let l:newBuf = bufnr("%") 
                windo if buflisted(winbufnr(0)) | execute "b! " . l:newBuf | endif 
            endif 
            exe s:kwbdWinNum . 'wincmd w'
        endif 
        if buflisted(s:kwbdBufNum) || s:kwbdBufNum == bufnr("%") 
            execute "bd! " . s:kwbdBufNum 
        endif 
        if !s:kwbdBuflistedLeft 
            set buflisted 
            set bufhidden=delete 
            set buftype=nofile 
            setlocal noswapfile 
            normal athis is the scratch buffer 
        endif 
    else 
        if bufnr("%") == s:kwbdBufNum 
            let prevbufvar = bufnr("#") 
            if prevbufvar > 0 && buflisted(prevbufvar) && prevbufvar != s:kwbdBufNum 
                b # 
            else 
                bn 
            endif 
        endif 
    endif 
endfunction

" vim:ts=4:sw=4:sts=4 et fdm=marker:

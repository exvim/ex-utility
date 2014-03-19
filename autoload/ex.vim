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

" ex#keep_window_bd {{{1
" Desc: VimTip #1119: How to use Vim like an IDE
" delete the buffer; keep windows; create a scratch buffer if no buffers left 
" Using this Kwbd function (:call ex#keep_window_bd(1)) will make Vim behave like an IDE; 
" or maybe even better. 

function ex#keep_window_bd(stage) " <<<
    if a:stage == 1
        " check it is plugin window, if yes, close it directly to prevent use \bd
        " close, reopen will loose plugin ability problem
        let cru_short_bufname = fnamemodify(bufname('%'),":p:t")

        " TODO:
        " if exUtility#IsRegisteredPluginBuffer(bufname('%')) 
        "     silent exec 'close'
        "     call exUtility#GotoEditBuffer()
        "     return
        " endif

        "
        if !buflisted(winbufnr(0)) 
            bd! 
            return 
        endif 
        let g:kwbdBufNum = bufnr("%") 
        let g:kwbdWinNum = winnr() 
        windo call ex#keep_window_bd(2) 
        exe g:kwbdWinNum . 'wincmd w'
        let g:kwbdBuflistedLeft = 0 
        let g:kwbdBufFinalJump = 0 
        let l:nBufs = bufnr("$") 
        let l:i = 1 
        while l:i <= l:nBufs 
            if l:i != g:kwbdBufNum 
                if buflisted(l:i) 
                    let g:kwbdBuflistedLeft = g:kwbdBuflistedLeft + 1 
                else 
                    if bufexists(l:i) && !strlen(bufname(l:i)) && !g:kwbdBufFinalJump 
                        let g:kwbdBufFinalJump = l:i 
                    endif 
                endif 
            endif 
            let l:i = l:i + 1 
        endwhile 
        if !g:kwbdBuflistedLeft 
            if g:kwbdBufFinalJump 
                windo if buflisted(winbufnr(0)) | execute "b! " . g:kwbdBufFinalJump | endif 
            else 
                silent exec 'enew' 
                let l:newBuf = bufnr("%") 
                windo if buflisted(winbufnr(0)) | execute "b! " . l:newBuf | endif 
            endif 
            exe g:kwbdWinNum . 'wincmd w'
        endif 
        if buflisted(g:kwbdBufNum) || g:kwbdBufNum == bufnr("%") 
            execute "bd! " . g:kwbdBufNum 
        endif 
        if !g:kwbdBuflistedLeft 
            set buflisted 
            set bufhidden=delete 
            set buftype=nofile 
            setlocal noswapfile 
            normal athis is the scratch buffer 
        endif 
    else 
        if bufnr("%") == g:kwbdBufNum 
            let prevbufvar = bufnr("#") 
            if prevbufvar > 0 && buflisted(prevbufvar) && prevbufvar != g:kwbdBufNum 
                b # 
            else 
                bn 
            endif 
        endif 
    endif 
endfunction

" vim:ts=4:sw=4:sts=4 et fdm=marker:

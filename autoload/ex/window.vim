" ex#window#new {{{
" bufname: the buffer you wish to open a window edit it
" size: the initial size of the window
" pos: 'left', 'right', 'top', 'bottom'
" nested: 0 or 1. if nested, the window will be created besides current window 

function ex#window#new( bufname, size, pos, nested )
    let winpos = ""
    if a:nested == 1
        if a:pos == "left" || a:pos == "top"
            let winpos = "leftabove"
        elseif a:pos == "right" || a:pos == "bottom"
            let winpos = "rightbelow"
        endif
    else
        if a:pos == "left" || a:pos == "top"
            let winpos = "topleft"
        elseif a:pos == "right" || a:pos == "bottom"
            let winpos = "botright"
        endif
    end

    let vcmd = ""
    if a:pos == "left"
        let vcmd = "vertical"
    elseif a:pos == "right"
        let vcmd = "vertical"
    endif

    " If the buffer already exists, reuse it.
    " Otherwise create a new buffer
    let bufnum = bufnr(a:bufname)
    let bufcmd = ""
    if bufnum == -1
        " Create a new buffer
        let bufcmd = a:bufname
    else
        " Edit exists buffer
        " NOTE: in old exvim script, it wrote +buffer.bufnum, what's the meaning of + here? 
        let bufcmd = '+b' . bufnum
    endif

    " Create the ex_window
    silent exe winpos . ' ' . vcmd . ' ' . a:size . ' split ' .  bufcmd

    " init window after window craeted

    " TODO: Register bufname
    " " after create the window, record the bufname into the plugin buffer name list
    " let short_bufname = fnamemodify(a:buffer_name,":p:t")
    " if index( g:ex_plugin_registered_bufnames, short_bufname ) == -1
    "     silent call add( g:ex_plugin_registered_bufnames, short_bufname )
    " endif

    " " record the filetype into the plugin filetype list
    " let buf_filetype = getbufvar(a:buffer_name,'&filetype')
    " if index( g:ex_plugin_registered_filetypes, buf_filetype ) == -1
    "     silent call add( g:ex_plugin_registered_filetypes, buf_filetype )
    " endif

    " the winfix height width will let plugin-window not join into the <c-w>= operations
    silent setlocal winfixheight
    silent setlocal winfixwidth

    " TODO: does this should be here or should move it global in ex_utility settings?
    " " Define the ex autocommands
    " augroup ex_auto_cmds
    "     autocmd WinLeave * call exUtility#RecordCurrentBufNum()
    "     autocmd BufLeave * call exUtility#RecordSwapBufInfo()
    " augroup end

    " TODO: do we need this??
    " " avoid cwd change problem
    " if exists( 'g:exES_CWD' )
    "     au BufEnter * silent exec 'lcd ' . escape(g:exES_CWD, " ")
    " endif

endfunction

" ex#window#open {{{
" bufname: the buffer you wish to open a window edit it
" size: the initial size of the window
" pos: 'left', 'right', 'top', 'bottom'
" nested: 0 or 1. if nested, the window will be created besides current window 
" focus: 0 or 1. if focus, we will move cursor to opened window

function ex#window#open( bufname, size, pos, nested, focus )
    " TODO:
    " " close ex_plugin window in same position
    " call exUtility#ClosePluginWindowInSamePosition ( position, nested )

    " " go to edit buffer first, then open the window, this will avoid some bugs
    " call exUtility#RecordCurrentBufNum()
    " call exUtility#GotoEditBuffer()

    " new window
    call ex#window#new( a:bufname, a:size, a:pos, a:nested )

    "
    if a:focus == 0
        " TODO: call exUtility#GotoEditBuffer()
    endif
endfunction

" ex#window#close {{{
function ex#window#close(winnr)
    if a:winnr == -1
        return
    endif

    " jump to the window
    exe a:winnr . 'wincmd w'

    " if this is not the only window, close it
    " if winbufnr(2) != -1
    "     close
    " endif
    try
        close
    catch /E444:/
        call ex#warning( 'Can not close last window' )
    endtry

    " go back to edit buffer
    " TODO: call exUtility#GotoEditBuffer()
    " TODO: call exUtility#ClearObjectHighlight()

endfunction

" ex#window#resize {{{
function ex#window#resize( winnr, position, nested, size )
    " TODO:
    " if a:use_vertical
    "     let new_size = a:original_size
    "     if winwidth('.') <= a:original_size
    "         let new_size = a:original_size + a:increase_size
    "     endif
    "     silent exe 'vertical resize ' . new_size
    " else
    "     let new_size = a:original_size
    "     if winheight('.') <= a:original_size
    "         let new_size = a:original_size + a:increase_size
    "     endif
    "     silent exe 'resize ' . new_size
    " endif
endfunction

" vim:ts=4:sw=4:sts=4 et fdm=marker:

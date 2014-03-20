" ex#window#new {{{
" bufname: the buffer you wish to open a window edit it
" size: the initial size of the window
" pos: 'left', 'right', 'top', 'bottom'
" nested: 0 or 1. if nested, the window will be created besides current window 

function ex#window#new( bufname, size, pos, nested, callback )
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
        " NOTE: '+' here is to make it work with other command 
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

    call a:callback()

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
" callback: init callback when window created

function ex#window#open( bufname, size, pos, nested, focus, callback )
    " TODO:
    " " close ex_plugin window in same position
    " call exUtility#ClosePluginWindowInSamePosition ( position, nested )

    " " go to edit buffer first, then open the window, this will avoid some bugs
    " call exUtility#RecordCurrentBufNum()
    " call exUtility#GotoEditBuffer()

    " new window
    call ex#window#new( a:bufname, a:size, a:pos, a:nested, a:callback )

    "
    if a:focus == 0
        call ex#window#goto_edit_window()
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
    call ex#window#goto_edit_window()
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

" ex#window#record {{{

" NOTE: Vim's window is manage by winnr. however, winnr will change when
" there's window closed. Basically, win sort the all exists window, and  
" give them winnr by the created time. This is bad for locate window in 
" the runtime. 

" NOTE: The WinEnter,BufWinEnter event will not invoke when you do it 
" from script. That's why I don't init w:ex_winid when WinEnter

" NOTE: Cause Vim not fire WinEnter event precisely, when you script plugin,
" It is highly recommend you manually call ex#window#record() when leaving
" window 

" What we do is when window leaving, give it a w:ex_winid 
" that holds a unique id.

let s:last_editbuf_winid = -1
let s:last_editplugin_bufnr = -1
let s:winid_generator = 0

function s:new_winid () 
    let s:winid_generator = s:winid_generator + 1
    return s:winid_generator
endfunction

function s:winid2nr (winid)
    if a:winid == -1
        return -1
    endif

    let i = 1
    let winnr = winnr("$")
    while i <= winnr
        if getwinvar(i, "ex_winid") == a:winid
            return i
        endif
        let i = i + 1
    endwhile
    return -1
endfunction

function ex#window#record()
    if getwinvar(0, "ex_winid") == ""
        let w:ex_winid = s:new_winid()
    endif

    if ex#window#is_plugin_window()
        let s:last_editplugin_bufnr = bufnr('%')
    else
        let s:last_editbuf_winid = w:ex_winid
    endif
endfunction

" ex#window#is_plugin_window {{{
function ex#window#is_plugin_window()
    return ex#buffer#is_registered_buffer(bufname('%'))
endfunction

" ex#window#last_edit_bufnr {{{
function ex#window#last_edit_bufnr()
    return winbufnr(s:winid2nr(s:last_editbuf_winid))
endfunction

" ex#window#goto_edit_window {{{
function ex#window#goto_edit_window()
    " get winnr from winid
    let winnr = s:winid2nr(s:last_editbuf_winid)

    " this will fix the jump error in the vimentry buffer, 
    " cause the winnr for vimentry buffer is -1
    if winnr != -1 && winnr() != winnr
        exe winnr . 'wincmd w'
    endif

    " TODO: do we need this???
    " call ex#window#record()
endfunction

" ex#window#goto_plugin_window {{{
function ex#window#goto_plugin_window() " <<<
    " get winnr from bufnr
    let winnr = bufwinnr(s:last_editplugin_bufnr)

    if winnr != -1 && winnr() != winnr
        exe winnr . 'wincmd w'
    endif

    " TODO: do we need this???
    " call ex#window#record()
endfunction " >>>

" vim:ts=4:sw=4:sts=4 et fdm=marker:

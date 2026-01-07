function! floaterm#asyncrun#run(opts, floaterm_wintype, position)
    let opts = copy(a:opts)
    let floaterm_wintype = copy(a:floaterm_wintype)
    let position = copy(a:position)
    if !g:has_popup_floating && floaterm_wintype == 'float'
        call preview#errmsg("Please update to vim8.1+/nvim0.6+ to run script in floating or popup window.")
        return
    endif
    let found_floaterm = v:false
    let buflist = floaterm#buflist#gather()
    if len(buflist) > 0
        for floaterm_bufnr in buflist
            " NOTE: found floaterm of same floaterm wintype and position
            if floaterm#config#get(floaterm_bufnr, 'wintype') == floaterm_wintype && floaterm#config#get(floaterm_bufnr, 'position') == position
                let found_floaterm = v:true
                break
            endif
        endfor
    endif
    if found_floaterm
        call floaterm#terminal#open_existing(floaterm_bufnr)
    else
        let cmd = 'FloatermNew --wintype=' . floaterm_wintype
        if has_key(opts, 'width')
            let cmd .= " --width="  . opts.width
        elseif floaterm_wintype == 'float'
            let cmd .= " --width=0.7"
        elseif floaterm_wintype == 'vsplit'
            let cmd .= " --width=0.45"
        endif
        if has_key(opts, 'height')
            let cmd .= " --height=" . opts.height
        elseif floaterm_wintype == 'float' || floaterm_wintype == 'split'
            let cmd .= " --height=0.3"
        endif
        let cmd .= " --position=" . position
        exec cmd
        let floaterm_bufnr = floaterm#buflist#curr()
    endif
    if has_key(a:opts, 'silent') && a:opts.silent == 1
        FloatermHide!
    endif
    let cd = 'cd ' . shellescape(getcwd())
    call floaterm#terminal#send(floaterm_bufnr, [cd])
    call floaterm#terminal#send(floaterm_bufnr, [a:opts.cmd])
    let ft = &filetype
    if get(a:opts, 'focus', 1) == 0
        if has('nvim')
            stopinsert | noa wincmd p
        elseif floaterm_wintype != 'float'
            call feedkeys("\<C-_>w", "n")
        endif
    elseif ft == 'floaterm'
        call floaterm#util#startinsert()
    endif
endfunction
function! floaterm#asyncrun#right(opts)
    call floaterm#asyncrun#run(a:opts, 'vsplit', 'right')
endfunction
function! floaterm#asyncrun#left(opts)
    call floaterm#asyncrun#run(a:opts, 'vsplit', 'left')
endfunction
function! floaterm#asyncrun#float(opts)
    call floaterm#asyncrun#run(a:opts, 'float', 'center')
endfunction
function! floaterm#asyncrun#float_bottom(opts)
    call floaterm#asyncrun#run(a:opts, 'float', 'bottomright')
endfunction
function! floaterm#asyncrun#bottom(opts)
    call floaterm#asyncrun#run(a:opts, 'split', 'botright')
endfunction
function! floaterm#asyncrun#top(opts)
    call floaterm#asyncrun#run(a:opts, 'split', 'top')
endfunction
function! floaterm#asyncrun#topleft(opts)
    call floaterm#asyncrun#run(a:opts, 'vsplit', 'topleft')
endfunction
function! floaterm#asyncrun#center(opts)
    call floaterm#asyncrun#run(a:opts, 'float', 'center')
endfunction

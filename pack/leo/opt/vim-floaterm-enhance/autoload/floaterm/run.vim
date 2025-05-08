" -------------------------------------
" get run buf nr
" -------------------------------------
function! s:get_run_bufnr(idx) abort
    if exists('t:floaterm_run_dict') && has_key(t:floaterm_run_dict, a:idx)
        let termname = t:floaterm_run_dict[a:idx]
        let bufnr = floaterm#terminal#get_bufnr(termname)
        return [bufnr, termname]
    else
        return [-1, '']
    endif
endfunction
" -------------------------------------
" set run terminal name
" -------------------------------------
function! s:set_run_tername(ft, bufnr, termname) abort
    if !exists('t:floaterm_run_dict')
        let t:floaterm_run_dict = {}
    endif
    let idx = a:ft . a:bufnr
    let t:floaterm_run_dict[idx] = a:termname
endfunction
" -------------------------------------
" choose run command
" -------------------------------------

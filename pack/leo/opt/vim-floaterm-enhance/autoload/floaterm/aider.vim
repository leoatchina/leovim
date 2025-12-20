" -------------------------------------
" get run buf nr
" -------------------------------------
function! s:get_aider_bufnr(idx) abort
    if exists('t:floaterm_aider_terms') && has_key(t:floaterm_aider_terms, a:idx)
        let termname = t:floaterm_aider_terms[a:idx]
        let bufnr = floaterm#terminal#get_bufnr(termname)
        return [bufnr, termname]
    else
        return [-1, '']
    endif
endfunction
" -------------------------------------
" set run terminal name
" -------------------------------------
function! s:set_aider_term(ft, bufnr, termname) abort
    if !exists('t:floaterm_aider_terms')
        let t:floaterm_run_terms = {}
    endif
    let idx = a:ft . a:bufnr
    let t:floaterm_run_terms[idx] = a:termname
endfunction

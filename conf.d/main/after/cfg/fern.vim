" fern_open
function! FernOpen(type, ...) abort
    if a:type == 'lcd'
        let l:dir = '.'
    elseif a:type == 'gitroot'
        let l:dir = git#root_dir()
    else
        let l:dir = utils#get_root_dir()
    endif
    let l:cmd = 'Fern ' . l:dir
    if !get(a:, 1, 0)
        let l:cmd .= ' -drawer -stay -reveal=%:p'
    endif
    execute l:cmd
endfunction
command! FernLCD call FernOpen('lcd', 1)
command! FernSideLCD call FernOpen('lcd')
command! FernSideGitRoot call FernOpen('gitroot')
command! FernSideGetRoot call FernOpen('getroot')
nnoremap <leader>fn :Fern
nnoremap <silent><leader>f. :Fern ./ -reveal=%:p<Cr>
nnoremap <silent><leader>fl :FernSideLCD<Cr>
nnoremap <silent><leader>fg :FernSideGitRoot<Cr>
nnoremap <silent><leader>fr :FernSideGetRoot<Cr>
" ---------------
" fzf
" ---------------
function! Fern_mapping_fzf_customize_option(spec)
    let a:spec.options .= ' --multi'
    if exists('*fzf#vim#with_preview')
        return fzf#vim#with_preview(a:spec)
    else
        return a:spec
    endif
endfunction
function! Fern_mapping_fzf_before_all(dict)
    if !len(a:dict.lines)
        return
    endif
    return a:dict.fern_helper.async.update_marks([])
endfunction
function! s:reveal(dict)
    execute "Fern . -opener=edit/split -stay -reveal=%:p"
    execute "normal \<Plug>(fern-action-mark:set)"
endfunction
let g:Fern_mapping_fzf_file_sink = function('s:reveal')
let g:Fern_mapping_fzf_dir_sink = function('s:reveal')
PlugAdd 'fern-mapping-fzf.vim'
" ---------------
" preview
" ---------------
function! s:fern_settings() abort
    nmap <silent><buffer>p      <Plug>(fern-action-preview:toggle)
    nmap <silent><buffer><C-p>  <Plug>(fern-action-preview:auto:toggle)
    nmap <silent><buffer><C-f>  <Plug>(fern-action-preview:scroll:down:half)
    nmap <silent><buffer><C-b>  <Plug>(fern-action-preview:scroll:up:half)
    nmap <silent><buffer><expr> <Plug>(fern-quit-or-close-preview) fern_preview#smart_preview("\<Plug>(fern-action-preview:close)", ":q\<CR>")
    nmap <silent><buffer>q      <Plug>(fern-quit-or-close-preview)
    nmap <silent><buffer><M-q>  <Plug>(fern-quit-or-close-preview)
endfunction
augroup fern-settings
    autocmd!
    autocmd FileType fern call s:fern_settings()
augroup END
PlugAdd 'fern-preview.vim'

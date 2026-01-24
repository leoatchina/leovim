PlugAdd 'vim-eunuch'
" ------------------------------
" conflict marker
" ------------------------------
let g:conflict_marker_enable_mappings = 0
PlugAdd 'conflict-marker.vim'
nnoremap <leader>ct :ConflictMarkerThemselves<Cr>
nnoremap <leader>co :ConflictMarkerOurselves<Cr>
nnoremap <leader>cx :ConflictMarkerNone<Cr>
nnoremap <leader>c. :ConflictMarkerBoth<Cr>
nnoremap <leader>c; :ConflictMarkerNextHunk<Cr>
nnoremap <leader>c, :ConflictMarkerPrevHunk<Cr>
" ------------------------------
" nerdcommenter
" ------------------------------
" Create default mappings
let g:NERDCreateDefaultMappings = 1
" Add space after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1
" Enable NERDCommenterToggle to check all selected lines is commented or not
let g:NERDToggleCheckAllLines = 1
PlugAdd 'nerdcommenter'
nnoremap <silent><leader>c] V}:call nerdcommenter#Comment('x', 'toggle')<CR>
nnoremap <silent><leader>c[ V{:call nerdcommenter#Comment('x', 'toggle')<CR>
" ----------------------------------
" hl searchindex && multi replace
" ----------------------------------
if has('nvim')
    PlugAdd 'nvim-hlslens'
else
    PlugAdd 'vim-searchindex'
endif
xnoremap <silent><C-n> :<C-u>call utils#enhance_search()<Cr>/<C-R>=@/<Cr><Cr>gvc
" ------------------------
" quick jump in buffer
" ------------------------
if has('nvim')
    PlugAdd 'flash.nvim'
else
    let g:clever_f_smart_case = 1
    let g:clever_f_repeat_last_char_inputs = ['<Tab>']
    PlugAdd 'clever-f.vim'
endif
if utils#is_vscode()
    PlugAdd 'hop.nvim'
else
    PlugAdd 'vim-easymotion'
    PlugAdd 'vim-easymotion-chs'
endif
" --------------------------
" textobj
" --------------------------
" surround
nmap SW viw<Plug>VSurround
nmap SL v$<Plug>VSurround
nmap SH v^<Plug>VSurround
nnoremap S) va)hol
nnoremap S} va}hol
nnoremap S] va]hol
for s:v in ['', 'v', 'V', '<C-V>']
    execute 'omap <expr>' s:v.'I%' "(v:count?'':'1').'".s:v."i%'"
    execute 'omap <expr>' s:v.'A%' "(v:count?'':'1').'".s:v."a%'"
endfor
if exists('*search') && exists('*getpos')
    PlugAdd 'vim-textobj-user'
    PlugAdd 'vim-textobj-uri'
    PlugAdd 'vim-textobj-line'
    PlugAdd 'vim-textobj-syntax'
    PlugAdd 'vim-textobj-function'
    nmap <leader>vf vafo
    nmap <leader>vF vifo
    nmap <leader>vc vaco
    nmap <leader>vC vico
    nmap <leader>vu viu
    nmap <leader>vU vau
    nmap <leader>vb vib
    nmap <leader>vB vaB
    nmap <leader>vn vin
    nmap <leader>vN vaN
    " -------------------
    " indent textobj
    " -------------------
    let g:vindent_motion_OO_prev   = ',i' " jump to prev block of same indent.
    let g:vindent_motion_OO_next   = ';i' " jump to next block of same indent.
    let g:vindent_motion_more_prev = ',=' " jump to prev line with more indent.
    let g:vindent_motion_more_next = ';=' " jump to next line with more indent.
    let g:vindent_motion_less_prev = ',-' " jump to prev line with less indent.
    let g:vindent_motion_less_next = ';-' " jump to next line with less indent.
    let g:vindent_motion_diff_prev = ',I' " jump to prev line with different indent.
    let g:vindent_motion_diff_next = ';I' " jump to next line with different indent.
    let g:vindent_motion_XX_ss     = ',p' " jump to start of the current block scope.
    let g:vindent_motion_XX_se     = ';p' " jump to end   of the current block scope.
    let g:vindent_object_XX_ii     = 'ii' " select current block.
    let g:vindent_object_XX_ai     = 'ai' " select current block + one extra line  at beginning.
    let g:vindent_object_XX_aI     = 'aI' " select current block + two extra lines at beginning and end.
    let g:vindent_jumps            = 1    " make vindent motion count as a |jump-motion| (works with |jumplist|).
    PlugAdd 'vindent.vim'
    " -------------------
    " targets.vim
    " -------------------
    PlugAdd 'targets.vim'
    nmap <leader>vt vit
    nmap <leader>vT vat
    nmap <leader>va via
    nmap <leader>vA vaa
    nmap <leader>vl vil
    nmap <leader>vL val
    nmap <leader>vn vin
    nmap <leader>vN vaN
    nmap <leader>Vt vIt
    nmap <leader>VT vAt
    nmap <leader>Va vIa
    nmap <leader>VA vAa
    nmap <leader>Vl vIl
    nmap <leader>VL vAl
    nmap <leader>Vn vIn
    nmap <leader>VN vAN
    " -------------------
    " sandwich
    " -------------------
    PlugAdd 'vim-sandwich'
    xmap is <Plug>(textobj-sandwich-auto-i)
    xmap as <Plug>(textobj-sandwich-auto-a)
    omap is <Plug>(textobj-sandwich-auto-i)
    omap as <Plug>(textobj-sandwich-auto-a)
    xmap iq <Plug>(textobj-sandwich-query-i)
    xmap aq <Plug>(textobj-sandwich-query-a)
    omap iq <Plug>(textobj-sandwich-query-i)
    omap aq <Plug>(textobj-sandwich-query-a)
    nmap <leader>vs vis
    nmap <leader>vS vas
    nmap <leader>vq viq
    nmap <leader>vQ vaq
endif

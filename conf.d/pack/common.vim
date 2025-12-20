PlugOpt 'vim-eunuch'
" ------------------------------
" conflict marker
" ------------------------------
let g:conflict_marker_enable_mappings = 0
PlugOpt 'conflict-marker.vim'
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
PlugOpt 'nerdcommenter'
nnoremap <silent><leader>c] V}:call nerdcommenter#Comment('x', 'toggle')<CR>
nnoremap <silent><leader>c[ V{:call nerdcommenter#Comment('x', 'toggle')<CR>
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
    " -------------------
    " textobj
    " -------------------
    PlugOpt 'vim-textobj-user'
    PlugOpt 'vim-textobj-uri'
    PlugOpt 'vim-textobj-line'
    PlugOpt 'vim-textobj-syntax'
    PlugOpt 'vim-textobj-function'
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
    PlugOpt 'vindent.vim'
    " -------------------
    " targets.vim
    " -------------------
    PlugOpt 'targets.vim'
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
    PlugOpt 'vim-sandwich'
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
    " -------------------
    " leo'defined textobj
    " -------------------
    nnoremap SS :call textobj#viw()<Cr>
    call textobj#user#plugin('line', {
                \   '-': {
                \     'select-a-function': 'textobj#current_lina_a',
                \     'select-a': 'ak',
                \     'select-i-function': 'textobj#current_line_i',
                \     'select-i': 'ik',
                \   },
                \ })
    vnoremap ik ^o$h
    onoremap ik :normal vik<Cr>
    vnoremap ak ^o$
    onoremap ak :normal vak<Cr>
    nmap <leader>vk vik
    nmap <leader>vK vak
    " find block
    let s:block_str = '^# In\[\d*\]\|^# %%\|^# STEP\d\+'
    " Block TextObj functions moved to utils.vim
    call textobj#user#plugin('block', {
                \ 'block': {
                \  'select-a-function': 'textobj#block_a',
                \  'select-a': 'av',
                \  'select-i-function': 'textobj#block_i',
                \  'select-i': 'iv',
                \  'region-type': 'V'
                \ },
                \ })
    nmap <leader>vv viv
    nmap <leader>vV vav
endif
" ----------------------------------
" hl searchindex && multi replace
" ----------------------------------
if has('nvim')
    PlugOpt 'nvim-hlslens'
    lua require('hlslens').setup()
    nnoremap <silent><nowait>n <Cmd>execute('normal! ' . v:count1 . 'n')<Cr><Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait>N <Cmd>execute('normal! ' . v:count1 . 'N')<Cr><Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait>* *``<Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait># #``<Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait>g* g*``<Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait>g# g#``<Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait><C-n> *``<Cmd>lua require('hlslens').start()<Cr>cgn
else
    PlugOpt 'vim-searchindex'
    nnoremap <silent><nowait>* *``
    nnoremap <silent><nowait># #``
    nnoremap <silent><nowait>g* g*``
    nnoremap <silent><nowait>g# g#``
    nnoremap <silent><nowait><C-n> *``cgn
endif
xnoremap <silent><C-n> :<C-u>call utils#enhance_search()<Cr>/<C-R>=@/<Cr><Cr>gvc
" ------------------------
" quick jump in buffer
" ------------------------
let g:EasyMotion_key = "123456789asdghklqwertyuiopzxcvbnmfj,;"
if has('nvim')
    PlugOpt 'flash.nvim'
    lua require("cfg/flash")
    nmap SJ vt<Space><Cr>S
    nmap SK vT<Space><Cr>S
else
    let g:clever_f_smart_case = 1
    let g:clever_f_repeat_last_char_inputs = ['<Tab>']
    PlugOpt 'clever-f.vim'
    nmap ;s <Plug>(clever-f-repeat-forward)
    xmap ;s <Plug>(clever-f-repeat-forward)
    nmap ,s <Plug>(clever-f-repeat-back)
    xmap ,s <Plug>(clever-f-repeat-back)
    nmap SJ vt<Space>S
    nmap SK vT<Space>S
endif
if utils#is_vscode()
    imap <C-a> <ESC>ggVG
    xmap <C-a> <ESC>ggVG
    nmap <C-a> ggVG
    imap <C-x> <C-o>"*
    xmap <C-x> "*x
    nmap <C-x> "*x
    PlugOpt 'hop.nvim'
    lua require("cfg/hop")
else
    imap <expr><C-a> pumvisible()? "\<C-a>":"\<C-o>0"
endif


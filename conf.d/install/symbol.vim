" ------------------------------
" fullscreen
" ------------------------------
if LINUX() && HAS_GUI() && executable('wmctrl')
    PlugAdd 'lambdalisue/vim-fullscreen'
    if has('nvim')
        let g:fullscreen#start_command = "call rpcnotify(0, 'Gui', 'WindowFullScreen', 1)"
        let g:fullscreen#stop_command  = "call rpcnotify(0, 'Gui', 'WindowFullScreen', 0)"
    endif
endif
" ------------------------------
" marks
" ------------------------------
PlugAdd 'kshenoy/vim-signature'
" ----------------------------
" schemes && textobj
" ----------------------------
if has('nvim-0.9.2') && get(g:, 'nvim_treesitter_install', UNIX())
    PlugAdd 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    PlugAdd 'nvim-treesitter/nvim-treesitter-textobjects'
    PlugAdd 'nvim-treesitter/nvim-treesitter-refactor'
    PlugAdd 'nvim-treesitter/nvim-treesitter-context', {'for': ['toml', 'yaml', 'json']}
    PlugAdd 'm-demare/hlargs.nvim'
elseif exists('*search') && exists('*getpos') && g:complete_engine != 'coc'
    PlugAdd 'bps/vim-textobj-python', {'for': 'python'}
    PlugAdd 'thinca/vim-textobj-function-perl', {'for': 'perl'}
    PlugAdd 'thinca/vim-textobj-function-javascript', {'for': ['javascript', 'typescript']}
    PlugAdd 'gcmt/wildfire.vim'
endif
if !Planned('nvim-treesitter') && Require('c') && PlannedAdv()
    PlugAdd 'jackguo380/vim-lsp-cxx-highlight', {'for': g:c_filetypes}
endif
if g:has_truecolor
    PlugAdd 'sainnhe/edge'
    PlugAdd 'sainnhe/sonokai'
    PlugAdd 'bluz71/vim-nightfly-colors'
    if has('nvim-0.8')
        PlugAdd 'folke/tokyonight.nvim'
        PlugAdd 'EdenEast/nightfox.nvim'
        PlugAdd 'catppuccin/nvim', {'as': 'catppuccin'}
    endif
endif
" ------------------------------
"  symbol_tool
" ------------------------------
let g:symbol_tool = []
function! s:planned_symbol(symbol) abort
    return count(g:symbol_tool, a:symbol)
endfunction
function! s:add_symbol(symbol) abort
    if s:planned_symbol(a:symbol) <= 0
        call add(g:symbol_tool, a:symbol)
    endif
endfunction
" ------------------------------
" lsp or vista or tagbar
" ------------------------------
if g:complete_engine == 'cmp'
    call s:add_symbol('nvimlsp')
    call s:add_symbol('vista')
elseif g:complete_engine == 'coc'
    call s:add_symbol('coc')
    call s:add_symbol('vista')
elseif g:complete_engine == 'mcm'
    if v:version >= 800 && get(g:, 'ctags_type', '') =~ 'Universal'
        call s:add_symbol('vista')
    elseif get(g:, 'ctags_type', '') != ''
        call s:add_symbol('tagbar')
    endif
endif
" ------------------------------
" tags
" ------------------------------
if get(g:, 'ctags_type', '') != ''
    if Planned('leaderf')
        call s:add_symbol("leaderftags")
    elseif Planned('fzf.vim')
        call s:add_symbol("fzftags")
        if has('nvim') || v:version >= 802
            call s:add_symbol('quickui')
        endif
    else
        call s:add_symbol("ctrlptags")
    endif
    if v:version >= 800 && g:complete_engine != 'apm'
        call s:add_symbol("gutentags")
        if get(g:, 'gtags_version', 0) > 6.0606
            if executable('gtags-cscope') && exists('$GTAGSCONF') && filereadable($GTAGSCONF)
                call s:add_symbol('plus')
            endif
        endif
    endif
endif
" ------------------------------
" install
" ------------------------------
if s:planned_symbol('gutentags')
    PlugAdd 'skywind3000/vim-gutentags'
endif
if s:planned_symbol('plus')
    PlugAdd 'skywind3000/gutentags_plus'
endif
if s:planned_symbol('vista')
    PlugAddOpt 'vista.vim'
elseif s:planned_symbol('tagbar')
    PlugAddOpt 'tagbar'
endif

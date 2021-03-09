set background=dark
function! SetScheme(scheme, ...) abort
    let scheme = a:scheme
    let defaultscheme = get(a:, 1, 'darkblue')
    try
        if get(g:, 'has_truecolor', 0) > 0
            let s:tried_true_color = 1
            execute('colorscheme '. scheme)
        else
            execute('colorscheme '. defaultscheme)
        endif
    catch
        try
            execute('colorscheme '. defaultscheme)
        catch
            colorscheme darkblue
        endtry
    endtry
endfunction
" --------------------------
" schmes intergrated
" --------------------------
if HasPlug('deus')
    colorscheme deus
elseif HasPlug('gruvbox')
    colorscheme gruvbox
elseif HasPlug('atomdark')
    colorscheme atom-dark-256
elseif HasPlug('dracula')
    colorscheme dracula
elseif HasPlug('hybrid')
    colorscheme hybrid
elseif HasPlug('sublime')
    colorscheme sublime
elseif HasPlug('codedark')
    colorscheme codedark
elseif HasPlug('space-vim')
    colorscheme space-vim-dark
elseif HasPlug('one')
    colorscheme one
" --------------------------
" schmes need truecolor
" --------------------------
elseif HasPlug('ayu')
    call SetScheme('ayu')
elseif HasPlug('edge')
    call SetScheme('edge')
elseif HasPlug('dogrun')
    call SetScheme('dogrun')
elseif HasPlug('embark')
    call SetScheme('embark')
elseif HasPlug('oceanicnext')
    call SetScheme('OceanicNext')
elseif HasPlug('sonokai')
    call SetScheme('sonokai')
elseif HasPlug('gruvbox_material')
    call SetScheme('gruvbox-material')
elseif HasPlug('equinusocio_material')
    call SetScheme('equinusocio_material')
elseif HasPlug('tokyonight')
    call SetScheme('tokyonight')
elseif HasPlug('oceanic_material')
    call SetScheme('oceanic_material')
" --------------------------
" schmes auto selected
" --------------------------
elseif get(g:, 'complete_engine', '') == ''
    colorscheme dracula
elseif get(g:, 'complete_engine', '') == 'apc'
    if get(g:, 'fuzzy_finder', '') == 'ctrlp'
        call SetScheme('dogrun', 'atom-dark-256')
    else
        call SetScheme('embark', 'space-vim-dark')
    endif
elseif get(g:, 'complete_engine', '') == 'coc'
    if g:fuzzy_finder == 'leaderf'
        call SetScheme('sonokai', 'sublime')
    else
        call SetScheme('ayu', 'deus')
    endif
elseif g:fuzzy_finder == 'leaderf'
    if get(g:, 'complete_engine', '') =~ 'YCM'
        if g:complete_engine =~ 'legacy'
            call SetScheme('oceanic_material', 'gruvbox')
        else
            call SetScheme('gruvbox-material', 'gruvbox')
        endif
    elseif get(g:, 'complete_engine', '') == 'vim-lsp'
        call SetScheme('OceanicNext', 'hybrid')
    else
        call SetScheme('tokyonight', 'codedark')
    endif
else
    call SetScheme('edge', 'one')
endif
" settings for scheme
try
    if g:colors_name == 'edge'
        let g:edge_style                  = get(g:, 'edge_style', 'aura')
        let g:edge_enable_italic          = 0
        let g:edge_disable_italic_comment = 0
    elseif g:colors_name == 'sonokai'
        let g:sonokai_style                  = get(g:, 'sonokai_style', 'andromeda')
        let g:sonokai_enable_italic          = 0
        let g:sonokai_disable_italic_comment = 0
    elseif g:colors_name == 'gruvbox-material'
        let g:gruvbox_material_background             = get(g:, 'gruvbox_material_background', 'medium')
        let g:gruvbox_material_palette                = get(g:, 'gruvbox_material_palette', 'mix')
        let g:gruvbox_material_visual                 = 'reverse'
        let g:gruvbox_material_enable_italic          = 0
        let g:gruvbox_material_disable_italic_comment = 0
    elseif g:colors_name == 'oceanic_material'
        let g:oceanic_material_background      = get(g:, 'oceanic_material_background', 'deep')
        let g:oceanic_material_allow_italic    = 0
        let g:oceanic_material_allow_undercurl = 0
        let g:oceanic_material_allow_reverse   = 1
    elseif g:colors_name == 'tokyonight'
        let g:tokyonight_style = get(g:, 'tokyonight', 'night')
        let g:tokyonight_enable_italic = 0
    elseif g:colors_name == 'embark'
        let g:embark_terminal_italics = 0
    elseif g:colors_name == 'ayu'
        let g:ayucolor = get(g:, 'ayucolor', 'mirage')
    elseif g:colors_name == 'OceanicNext'
        let g:oceanic_next_terminal_bold = get(g:, 'oceanic_next_terminal_bold', 0)
    endif
catch
    colorscheme desert
endtry

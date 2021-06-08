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
elseif HasPlug('nightfly')
    call SetScheme('nightfly')
elseif HasPlug('embark')
    call SetScheme('embark')
elseif HasPlug('oceanicnext') || HasPlug('oceanic')
    call SetScheme('OceanicNext')
elseif HasPlug('sonokai')
    call SetScheme('sonokai')
elseif HasPlug('everforest')
    call SetScheme('everforest')
elseif HasPlug('gruvbox_material')
    call SetScheme('gruvbox-material')
elseif HasPlug('tokyonight')
    call SetScheme('tokyonight')
" --------------------------
" schmes auto selected
" --------------------------
elseif get(g:, 'complete_engine', '') == ''
    colorscheme space-vim-dark
elseif get(g:, 'complete_engine', '') == 'apc'
    call SetScheme('nightfly', 'dracula')
elseif get(g:, 'complete_engine', '') == 'ECM'
    call SetScheme('embark', 'dracula')
elseif get(g:, 'complete_engine', '') == 'coc'
    if get(g:, 'fuzzy_finder', '') == 'leaderf'
        call SetScheme('sonokai', 'sublime')
    else
        call SetScheme('tokyonight', 'codedark')
    endif
elseif get(g:, 'fuzzy_finder', '') == 'leaderf'
    if get(g:, 'complete_engine', '') =~ 'YCM'
        if get(g:, 'complete_engine', '') =~ 'legacy'
            call SetScheme('everforest', 'deus')
        else
            call SetScheme('gruvbox-material', 'gruvbox')
        endif
    elseif get(g:, 'complete_engine', '') == 'vim-lsp'
        call SetScheme('edge', 'one')
    else
        call SetScheme('OceanicNext', 'hybrid')
    endif
else
    call SetScheme('ayu', 'atom-dark-256')
endif
" settings for scheme
try
    if get(g:, 'colors_name', '') == 'edge'
        let g:edge_style                  = get(g:, 'edge_style', 'aura')
        let g:edge_enable_italic          = 0
        let g:edge_disable_italic_comment = 1
    elseif get(g:, 'colors_name', '') == 'sonokai'
        let g:sonokai_style                  = get(g:, 'sonokai_style', 'andromeda')
        let g:sonokai_enable_italic          = 0
        let g:sonokai_disable_italic_comment = 1
    elseif get(g:, 'colors_name', '') == 'everforest'
        let g:everforest_background             = get(g:, 'everforest_background', 'hard')
        let g:everforest_enable_italic          = 0
        let g:everforest_disable_italic_comment = 1
    elseif get(g:, 'colors_name', '') == 'gruvbox-material'
        let g:gruvbox_material_background = get(g:, 'gruvbox_material_background', 'medium')
        let g:gruvbox_material_palette    = get(g:, 'gruvbox_material_palette', 'mix')
        let g:gruvbox_material_visual                 = 'reverse'
        let g:gruvbox_material_enable_italic          = 0
        let g:gruvbox_material_disable_italic_comment = 1
    elseif get(g:, 'colors_name', '') == 'tokyonight'
        let g:tokyonight_style         = get(g:, 'tokyonight', 'night')
        let g:tokyonight_enable_italic = 0
    elseif get(g:, 'colors_name', '') == 'embark'
        let g:embark_terminal_italics = 0
    elseif get(g:, 'colors_name', '') == 'nightfly'
        let g:nightflyItalics    = 0
        let g:nightflyUndercurls = 0
    elseif get(g:, 'colors_name', '') == 'ayu'
        let g:ayucolor = get(g:, 'ayucolor', 'mirage')
    elseif get(g:, 'colors_name', '') == 'OceanicNext'
        let g:oceanic_next_terminal_bold = get(g:, 'oceanic_next_terminal_bold', 0)
    endif
catch
    colorscheme desert
endtry

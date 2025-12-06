if (executable('delance-langserver') || g:node_version > 18) && g:complete_engine == 'cmp'
    let g:ensure_installed = ['pyright']
    if g:python_version > 3
        if executable('unzip')
            let g:ensure_installed += ['debugpy', 'ruff']
        else
            let g:ensure_installed += ['debugpy']
        endif
    endif
elseif g:python_version > 3
    if executable('unzip')
        let g:ensure_installed = ['basedpyright', 'debugpy', 'ruff']
    else
        let g:ensure_installed = ['basedpyright', 'debugpy']
    endif
else
    let g:ensure_installed = []
endif
if g:node_version > 18
    if executable('unzip')
        let g:ensure_installed += ['vimls', 'lua_ls', 'bashls']
    else
        let g:ensure_installed += ['vimls']
    endif
    if pack#require('web')
        let g:ensure_installed += ['cssls', 'eslint', 'html', 'vuels', 'angularls']
    endif
endif
if pack#require('R') && g:R_exe != ''
    let g:ensure_installed += ['r_language_server']
endif
if pack#require('c')
    let g:ensure_installed += ['cmake']
    if g:clangd_exe != ''
        let g:ensure_installed += ['clangd']
    endif
endif
if pack#require('rust') && g:cargo_exe != ''
    let g:ensure_installed += ['rust_analyzer']
endif
if pack#require('go') && g:gobin_exe != ''
    let g:gobin_exe_version = matchstr(utils#execute(printf('!%s version', g:gobin_exe)), '\v\zs\d{1,}.\d{1,}.\d{1,}\ze')
    let g:gobin_exe_version = utils#string_to_float(gobin_exe_version, 2)
    let g:ensure_installed += ['gopls']
endif
if pack#installed('spring-boot.nvim')
    lua pack#require('cfg/springboot')
endif
if pack#installed('nvim-java', 'nvim-java-core', 'nvim-java-test', 'nvim-java-refactor', 'nvim-java-dap', 'lua-async-await')
    lua pack#require('java').setup()
endif
lua pack#require("lsp")

if g:node_version > 16
    let g:ensure_installed = ['vimls', 'lua_ls', 'bashls']
else
    let g:ensure_installed = []
endif
if g:node_version > 16
    if g:python_version > 3.06
        let g:ensure_installed += ['basedpyright', 'ruff']
    else
        let g:ensure_installed += ['pyright']
    endif
endif
if Require('web') && g:node_version > 16
    let g:ensure_installed += ['cssls', 'eslint', 'html', 'vuels', 'angularls']
endif
if Require('R') && g:R_exe != ''
    let g:ensure_installed += ['r_language_server']
endif
if Require('c')
    let g:ensure_installed += ['cmake']
    if g:clangd_exe != ''
        let g:ensure_installed += ['clangd']
    endif
endif
if Require('rust') && g:cargo_exe != ''
    let g:ensure_installed += ['rust_analyzer']
endif
if Require('go') && g:gobin_exe != ''
    let g:gobin_exe_version = matchstr(execute(printf('!%s version', g:gobin_exe)), '\v\zs\d{1,}.\d{1,}.\d{1,}\ze')
    let g:gobin_exe_version = StringToFloat(gobin_exe_version, 2)
    let g:ensure_installed += ['gopls']
endif
if Installed('spring-boot.nvim')
    lua require('cfg/springboot')
endif
if Installed('nvim-java', 'nvim-java-core', 'nvim-java-test', 'nvim-java-refactor', 'nvim-java-dap', 'lua-async-await')
    lua require('java').setup()
endif
lua require("lsp")

if g:node_version > 16
    let g:ensure_installed = ['vimls', 'lua_ls', 'vale_ls']
else
    let g:ensure_installed = []
endif
if g:node_version > 16 && (g:python_version > 3.06 && !Require('pylsp') || g:python_version <= 3.06)
    let g:ensure_installed += ['pyright']
elseif g:python_version > 3.06
    let g:ensure_installed += ['pylsp']
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
if Require('go') && g:go_exe != ''
    let g:go_exe_version = matchstr(execute(printf('!%s version', g:go_exe)), '\v\zs\d{1,}.\d{1,}.\d{1,}\ze')
    let g:go_exe_version = StringToFloat(go_exe_version, 2)
    let g:ensure_installed += ['gopls']
endif
if Installed('spring-boot.nvim')
    lua require("springboot")
endif
if Installed('nvim-java', 'nvim-java-dap', 'nvim-java-core', 'nvim-java-test', 'nvim-java-refactor', 'lua-async-await', 'spring-boot.nvim')
    lua require('java').setup({verification = { invalid_mason_registry = false }})
endif
lua require("lsp")

let g:require_group = copy(get(g:, 'preset_group', []))

let g:leovim_osc52_yank = 1
let g:leovim_whichkey = 1
let g:leovim_openmap = 1
let g:nvim_treesitter_install = UNIX()

" if v:version < 800
"     call AddRequire('notags')
" endif

" call AddRequire('r')
" call AddRequire('web')
" call AddRequire('wubi')
" call AddRequire('debug')
" call AddRequire('query')
" call AddRequire('bioinfo')
" call AddRequire('markdown')
" call AddRequire('c', 'rust', 'go')

" call AddRequire('java')
" call AddRequire('neoconf')

" let g:open_vim="nvim.exe"
" let g:open_editor="code.exe"

" let g:jupynium_urls = ['localhost:9999/nbclassic']

" let $XAI_API_KEY=''
" let $GEMINI_API_KEY=''
" let $OPENAI_API_KEY=''
" let $DEEPSEEK_API_KEY=''
" let $ANTHROPIC_API_KEY=''

" let g:xai_model = 'grok-beta'
" let g:openai_model = 'gpt4o'
" let g:claude_model = 'claude-3.5-sonnet'
" let g:gemini_model = 'gemini-1.5-pro'
" let g:deepseek_model = 'deepseek-chat'

" let g:openai_compatible_api_key = ''
" let g:openai_compatible_url = ''
" let g:openai_compatible_model = ''

if has('nvim') && HAS_GUI()
    " set guifont=Cascadia\ Code:h10.5
    " set guifont=CascadiaCode\ Nerd\ Font:h11.5
endif

if WINDOWS()
    " let g:python3_host_prog='C:\\Python37\\python.exe'
    " let &pythonthreedll='C:\\Python37\\python37.dll'
    " let &pythonthreehome='C:\\Python37'

    " let g:code_user_dir = 'C:\Users\Admin\AppData\Roaming\Code\User'
    " let g:cursor_user_dir = 'C:\Users\Admin\AppData\Roaming\Cursor\User'
    " let g:windsurf_user_dir = 'C:\Users\Admin\AppData\Roaming\Windsurf\User'
    " let g:positron_user_dir = 'C:\Users\Admin\AppData\Roaming\Positron\User'
elseif UNIX()
    " let g:python3_host_prog=exepath('python3')
    " let g:code_user_dir = expand("$HOME/.config/Code/User")
    " let g:cursor_user_dir = expand("$HOME/.config/Cursor/User")
    " let g:windsurf_user_dir = expand("$HOME/.config/Windsurf/User")
    " let g:positron_user_dir = expand("$HOME/.config/Positron/User")
endif

" NOTE: visit https://ftp.gnu.org/pub/gnu/global/
" wget https://ftp.gnu.org/pub/gnu/global/global-6.6.12.tar.gz && tar xvf global-6.6.12.tar.gz && cd global-6.6.12  && ./configure --prefix ~/.local/gtags && make && make install && cd ..
" if executable('gtags') && UNIX()
    " let $GTAGSCONF=expand($HOME."/.local/gtags/share/gtags/gtags.conf")
" endif

" let g:vimtex_view_method = 'zathura'


" let g:header_field_author = ''
" let g:header_field_author_email = ''
" nnoremap <M-g>n :!git config user.name ""<Cr>:!git config user.email ""<Cr>

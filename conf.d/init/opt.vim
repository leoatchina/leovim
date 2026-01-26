if !exists('g:packs') || type(g:packs) != type([])
    let g:packs = []
endif

let g:leovim_whichkey = 1
let g:leovim_openmap = 1
let g:nvim_treesitter_install = utils#is_unix()

" if v:version < 800
"     call pack#add('notags')
" else
"     call pack#add('tags')
" endif

" call pack#add('fzfbin')

" call pack#add('web')
" call pack#add('wubi')
" call pack#add('pinyin')
" call pack#add('bioinfo')
" call pack#add('translate')

" call pack#add('r')
" call pack#add('c')
" call pack#add('go')
" call pack#add('rust')
" call pack#add('java')
" call pack#add('markdown')

" call pack#add('debug')
" call pack#add('minuet-ai')
" call pack#add('opencode')


" let g:open_editor="code.exe"
" let g:open_neovim="nvim.exe"

" let g:jupynium_urls = ['localhost:9999/nbclassic']

" let g:floaterm_ai_programs = [
"     \ "claude",
"     \ ["opencode", "--wintype=float --position=topright --width=0.45 --height=0.8"]
"   \ ]

" let $XAI_API_KEY=''
" let $GEMINI_API_KEY=''
" let $OPENAI_API_KEY=''
" let $DEEPSEEK_API_KEY=''
" let $ANTHROPIC_API_KEY=''

" let g:xai_model = 'grok-beta'
" let g:openai_model = 'gpt4o'
" let g:claude_model = 'claude-3.5-sonnet'
" let g:gemini_model = 'gemini-2.5-flash'
" let g:deepseek_model = 'deepseek-chat'


" let g:openai_compatible_api_key = ''
" let g:openai_compatible_model = ''
" let g:openai_compatible_url = ''


if has('nvim')
    " if utils#has_gui()
        " if exists('g:neovide')
        "     call pack#add('blink')
        " else
        "     call pack#add('cmp')
        " endif
    " else
        " call pack#add('builtin')
    " endif
else
    " if utils#has_gui()
        " call pack#add('coc')
    " else
        " call pack#add('mcm')
    " endif
endif

" if utils#has_gui()
    " set guifont=Cascadia\ Code\ NF:h11.5
    " set guifont=Cascadia\ Mono\ NF:h11.5
" else
    " set guifont=Cascadia\ Code:h10.5
    " set guifont=Cascadia\ Mono:h10.5
" endif


if utils#is_win()
    if has('nvim')
        " let g:python3_host_prog='C:\\Python37\\python.exe'
    else
        " In Vim, set pythonthreedll=C:\\Python37\\python37.dll or similar,
        " See :help +python3/dyn-stable.
    endif
    " let g:code_user_dir = 'C:\Users\Admin\AppData\Roaming\Code\User'
    " let g:kiro_user_dir = 'C:\Users\Admin\AppData\Roaming\Kiro\User'
    " let g:trae_user_dir = 'C:\Users\Admin\AppData\Roaming\Trae\User'
    " let g:qoder_user_dir = 'C:\Users\Admin\AppData\Roaming\Qoder\User'
    " let g:cursor_user_dir = 'C:\Users\Admin\AppData\Roaming\Cursor\User'
    " let g:windsurf_user_dir = 'C:\Users\Admin\AppData\Roaming\Windsurf\User'
    " let g:positron_user_dir = 'C:\Users\Admin\AppData\Roaming\Positron\User'
    " let g:antigravity_user_dir = 'C:\Users\Admin\AppData\Roaming\Antigravity\User'
elseif utils#is_unix()
    if has('nvim')
        " let g:python3_host_prog=exepath('python3')
    else
        " In Vim, set pythonthreedll=libpython3.10.so or similar,
        " use the shell command sudo ldconfig -p | grep libpython3 to find the library name.
        " See :help +python3/dyn-stable.
    endif
    " let g:code_user_dir = utils#expand("$HOME/.config/Code/User")
    " let g:kiro_user_dir = utils#expand("$HOME/.config/Kiro/User")
    " let g:trae_user_dir = utils#expand("$HOME/.config/Trae/User")
    " let g:qoder_user_dir = utils#expand("$HOME/.config/Qoder/User")
    " let g:cursor_user_dir = utils#expand("$HOME/.config/Cursor/User")
    " let g:windsurf_user_dir = utils#expand("$HOME/.config/Windsurf/User")
    " let g:positron_user_dir = utils#expand("$HOME/.config/Positron/User")
    " let g:antigravity_user_dir = utils#expand("$HOME/.config/Antigravity/User")
endif

" NOTE: visit https://ftp.gnu.org/pub/gnu/global/
" wget https://ftp.gnu.org/pub/gnu/global/global-6.6.12.tar.gz && tar xvf global-6.6.12.tar.gz && cd global-6.6.12
" ./configure --prefix ~/.local/gtags --disable-gtagscscope && make && make install && cd ~/.local/gtags
" ./configure --prefix ~/.local/gtags && make && make install && cd ~/.local/gtags
" if executable('gtags') && utils#is_unix()
    " let $GTAGSCONF=utils#expand($HOME."/.local/gtags/share/gtags/gtags.conf")
" endif

" let g:vimtex_view_method = 'zathura'

" let g:header_field_author = ''
" let g:header_field_author_email = ''
" nnoremap <M-g>n :!git config user.name ""<Cr>:!git config user.email ""<Cr>

" ------------------------
" open in (neo)vim
" ------------------------
if executable(get(g:, 'vim_path', ''))
    function! s:open_in_vim()
        call VSCodeNotify('copyFilePath')
        let p = fnameescape(@*)
        execute printf('!%s +%d "%s"', g:vim_path, line('.'), p)
    endfunction
    command! OpenInVim call s:open_in_vim()
    nnoremap <silent><Tab> :OpenInVim<Cr>
endif
" ------------------------
" basic enhanced shortcut
" ------------------------
nnoremap <Cr> <Cmd>lua require('vscode-neovim').action("workbench.action.navigateForward")<CR>
xnoremap <C-c> <Cmd>lua require('vscode-neovim').action('editor.action.clipboardCopyAction')<CR><ESC>
nnoremap <C-s> <Cmd>lua require('vscode-neovim').action('workbench.action.files.save')<CR>
nnoremap <C-h> <Cmd>lua require('vscode-neovim').action("editor.action.startFindReplaceAction")<CR>
nnoremap <C-n> <Cmd>lua require('vscode-neovim').action("editor.action.addSelectionToNextFindMatch")<CR>
nnoremap s<Cr> <Cmd>lua require('vscode-neovim').action('workbench.action.findInFiles', {args = {query = vim.fn.expand('<cword>')}})<CR>
nnoremap \| <Cmd>lua require('vscode-neovim').action("actions.find", {args = { query = vim.fn.expand("<cword>")}})<CR>
nnoremap <C-a> <Cmd>lua require('vscode-neovim').action("editor.action.selectAll")<Cr>
xnoremap <C-x> <Cmd>call VSCodeNotifyVisual("editor.action.clipboardCutAction", 1)<Cr>
nnoremap <C-x> x
" quickfix
nnoremap <C-.> <Cmd>lua require('vscode-neovim').action("keyboard-quickfix.openQuickFix")<CR>
" open mru view
nnoremap <leader>m <Cmd>lua require('vscode-neovim').action("workbench.action.openRecent")<Cr>
" ------------------------
" format
" ------------------------
xnoremap Q <Cmd>lua require('vscode-neovim').call('editor.action.formatSelection')<CR>
nnoremap Q <Cmd>lua require('vscode-neovim').call('editor.action.formatDocument.multiple')<CR>
" ------------------------
" vscode speicially mapping
" ------------------------
function! VSCodeNotifyVisual(cmd, leaveSelection, ...)
    let mode = mode()
    if mode ==# 'V'
        let startLine = line('v')
        let endLine = line('.')
        call VSCodeNotifyRange(a:cmd, startLine, endLine, a:leaveSelection, a:000)
    elseif mode ==# 'v' || mode ==# "\<C-v>"
        let startPos = getpos('v')
        let endPos = getpos('.')
        call VSCodeNotifyRangePos(a:cmd, startPos[1], endPos[1], startPos[2], endPos[2] + 1, a:leaveSelection, a:000)
    else
        lua require('vscode-neovim').action(a:cmd, a:000)
    endif
endfunction
xnoremap <C-S-P> <Cmd>call VSCodeNotifyVisual("workbench.action.showCommands", 1)<CR>
nnoremap <C-o> <Cmd>lua require('vscode-neovim').action("workbench.action.navigateBack")<CR>
nnoremap <C-f> <Cmd>lua require('vscode-neovim').action("actions.find")<CR>
" -------------------------------------
" for debug or repl send or run
" -------------------------------------
nnoremap <S-Cr> viB<C-Cr>
nnoremap J <Cmd>lua require('vscode-neovim').action("editor.debug.action.showDebugHover")<Cr>
nnoremap <leader>q <Cmd>lua require('vscode-neovim').action("workbench.action.debug.disconnect")<Cr>
nnoremap <leader>Q <Cmd>lua require('vscode-neovim').action("workbench.action.debug.stop")<Cr>
nnoremap <leader>l <Cmd>lua require('vscode-neovim').action("workbench.action.debug.start")<Cr>
nnoremap <leader>r <Cmd>lua require('vscode-neovim').action("workbench.action.debug.restart")<Cr>
nnoremap <leader>d <Cmd>lua require('vscode-neovim').action("workbench.action.debug.continue")<Cr>
nnoremap <leader>n <Cmd>lua require('vscode-neovim').action("workbench.action.debug.stepOver")<Cr>
nnoremap <leader>o <Cmd>lua require('vscode-neovim').action("workbench.action.debug.stepOut")<Cr>
nnoremap <leader>s <Cmd>lua require('vscode-neovim').action("workbench.action.debug.stepInto")<Cr>
nnoremap <leader>i <Cmd>lua require('vscode-neovim').action("workbench.action.debug.stepIntoTarget")<Cr>
nnoremap <leader>p <Cmd>lua require('vscode-neovim').action("workbench.action.debug.pause")<Cr>
" breakpoints
nnoremap <leader>b <Cmd>lua require('vscode-neovim').action("editor.debug.action.toggleBreakpoint")<Cr>
nnoremap <leader>B <Cmd>lua require('vscode-neovim').action("workbench.debug.viewlet.action.removeAllBreakpoints")<Cr>
nnoremap <leader>F <Cmd>lua require('vscode-neovim').action("workbench.debug.viewlet.action.addFunctionBreakpointAction")<Cr>
nnoremap <leader>C <Cmd>lua require('vscode-neovim').action("editor.debug.action.conditionalBreakpoint")<Cr>
nnoremap <leader>t <Cmd>lua require('vscode-neovim').action("debug.enableOrDisableBreakpoint")<Cr>
nnoremap <leader>d <Cmd>lua require('vscode-neovim').action("workbench.debug.viewlet.action.disableAllBreakpoints")<Cr>
nnoremap <leader>e <Cmd>lua require('vscode-neovim').action("workbench.debug.viewlet.action.enableAllBreakpoints")<Cr>
nnoremap <leader>[ <Cmd>lua require('vscode-neovim').action("editor.debug.action.goToPreviousBreakpoint")<Cr>
nnoremap <leader>] <Cmd>lua require('vscode-neovim').action("editor.debug.action.goToNextBreakpoint")<Cr>
" marker
nnoremap <leader>, <Cmd>lua require('vscode-neovim').action("editor.action.marker.prevInFiles")<Cr>
nnoremap <leader>; <Cmd>lua require('vscode-neovim').action("editor.action.marker.nextInFiles")<Cr>
" codeaction
nnoremap <leader>a <Cmd>lua require('vscode-neovim').action("editor.action.sourceAction")<Cr>
" ------------------------
" window
" ------------------------
function! s:split(...) abort
    let direction = a:1
    let file = exists('a:2') ? a:2 : ''
    call VSCodeCall(direction ==# 'h' ? 'workbench.action.splitEditorDown' : 'workbench.action.splitEditorRight')
    if !empty(file)
        call VSCodeExtensionNotify('open-file', expand(file), 'all')
    endif
endfunction
function! s:splitNew(...)
    let file = a:2
    call s:split(a:1, empty(file) ? '__vscode_new__' : file)
endfunction
function! s:closeOtherEditors()
    call VSCodeNotify('workbench.action.closeEditorsInOtherGroups')
    call VSCodeNotify('workbench.action.closeOtherEditors')
endfunction
function! s:manageEditorHeight(...)
    let count = a:1
    let to = a:2
    for i in range(1, count ? count : 1)
        call VSCodeNotify(to ==# 'increase' ? 'workbench.action.increaseViewHeight' : 'workbench.action.decreaseViewHeight')
    endfor
endfunction
function! s:manageEditorWidth(...)
    let count = a:1
    let to = a:2
    for i in range(1, count ? count : 1)
        call VSCodeNotify(to ==# 'increase' ? 'workbench.action.increaseViewWidth' : 'workbench.action.decreaseViewWidth')
    endfor
endfunction
command! -complete=file -nargs=? Split call <SID>split('h', <q-args>)
command! -complete=file -nargs=? Vsplit call <SID>split('v', <q-args>)
command! -complete=file -nargs=? New call <SID>split('h', '__vscode_new__')
command! -complete=file -nargs=? Vnew call <SID>split('v', '__vscode_new__')
command! -bang Only if <q-bang> ==# '!' | call <SID>closeOtherEditors() | else | call VSCodeNotify('workbench.action.joinAllGroups') | endif
AlterCommand sp[lit] Split
AlterCommand vs[plit] Vsplit
AlterCommand new New
AlterCommand vne[w] Vnew
AlterCommand on[ly] Only
" buffer management
nnoremap <C-w>n <Cmd>call <SID>splitNew('h', '__vscode_new__')<CR>
xnoremap <C-w>n <Cmd>call <SID>splitNew('h', '__vscode_new__')<CR>
nnoremap <C-w>q <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
xnoremap <C-w>q <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
nnoremap <C-w>c <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
xnoremap <C-w>c <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
nnoremap <C-w><C-c> <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
xnoremap <C-w><C-c> <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
" window/splits management
nnoremap <C-w>s <Cmd>call <SID>split('h')<CR>
xnoremap <C-w>s <Cmd>call <SID>split('h')<CR>
nnoremap <C-w><C-s> <Cmd>call <SID>split('h')<CR>
xnoremap <C-w><C-s> <Cmd>call <SID>split('h')<CR>

nnoremap <C-w>v <Cmd>call <SID>split('v')<CR>
xnoremap <C-w>v <Cmd>call <SID>split('v')<CR>
nnoremap <C-w><C-v> <Cmd>call <SID>split('v')<CR>
xnoremap <C-w><C-v> <Cmd>call <SID>split('v')<CR>

nnoremap <C-w>= <Cmd>call VSCodeNotify('workbench.action.evenEditorWidths')<CR>
xnoremap <C-w>= <Cmd>call VSCodeNotify('workbench.action.evenEditorWidths')<CR>
nnoremap <C-w>_ <Cmd>call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>
xnoremap <C-w>_ <Cmd>call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>

nnoremap <C-w>+ <Cmd>call <SID>manageEditorHeight(v:count, 'increase')<CR>
xnoremap <C-w>+ <Cmd>call <SID>manageEditorHeight(v:count, 'increase')<CR>
nnoremap <C-w>- <Cmd>call <SID>manageEditorHeight(v:count, 'decrease')<CR>
xnoremap <C-w>- <Cmd>call <SID>manageEditorHeight(v:count, 'decrease')<CR>
nnoremap <C-w>> <Cmd>call <SID>manageEditorWidth(v:count,  'increase')<CR>
xnoremap <C-w>> <Cmd>call <SID>manageEditorWidth(v:count,  'increase')<CR>
nnoremap <C-w>< <Cmd>call <SID>manageEditorWidth(v:count,  'decrease')<CR>
xnoremap <C-w>< <Cmd>call <SID>manageEditorWidth(v:count,  'decrease')<CR>

nnoremap <C-w>o <Cmd>call VSCodeNotify('workbench.action.joinAllGroups')<CR>
xnoremap <C-w>o <Cmd>call VSCodeNotify('workbench.action.joinAllGroups')<CR>
nnoremap <C-w><C-o> <Cmd>call VSCodeNotify('workbench.action.joinAllGroups')<CR>
xnoremap <C-w><C-o> <Cmd>call VSCodeNotify('workbench.action.joinAllGroups')<CR>

" window navigation
nnoremap <C-w>j <Cmd>call VSCodeNotify('workbench.action.focusBelowGroup')<CR>
xnoremap <C-w>j <Cmd>call VSCodeNotify('workbench.action.focusBelowGroup')<CR>
nnoremap <C-w>k <Cmd>call VSCodeNotify('workbench.action.focusAboveGroup')<CR>
xnoremap <C-w>k <Cmd>call VSCodeNotify('workbench.action.focusAboveGroup')<CR>
nnoremap <C-w>h <Cmd>call VSCodeNotify('workbench.action.focusLeftGroup')<CR>
xnoremap <C-w>h <Cmd>call VSCodeNotify('workbench.action.focusLeftGroup')<CR>
nnoremap <C-w>l <Cmd>call VSCodeNotify('workbench.action.focusRightGroup')<CR>
xnoremap <C-w>l <Cmd>call VSCodeNotify('workbench.action.focusRightGroup')<CR>

nnoremap <C-w><Down> <Cmd>call VSCodeNotify('workbench.action.focusBelowGroup')<CR>
xnoremap <C-w><Down> <Cmd>call VSCodeNotify('workbench.action.focusBelowGroup')<CR>
nnoremap <C-w><Up> <Cmd>call VSCodeNotify('workbench.action.focusAboveGroup')<CR>
xnoremap <C-w><Up> <Cmd>call VSCodeNotify('workbench.action.focusAboveGroup')<CR>
nnoremap <C-w><Left> <Cmd>call VSCodeNotify('workbench.action.focusLeftGroup')<CR>
xnoremap <C-w><Left> <Cmd>call VSCodeNotify('workbench.action.focusLeftGroup')<CR>
nnoremap <C-w><Right> <Cmd>call VSCodeNotify('workbench.action.focusRightGroup')<CR>
xnoremap <C-w><Right> <Cmd>call VSCodeNotify('workbench.action.focusRightGroup')<CR>

nnoremap <C-w><C-j> <Cmd>call VSCodeNotify('workbench.action.moveEditorToBelowGroup')<CR>
xnoremap <C-w><C-j> <Cmd>call VSCodeNotify('workbench.action.moveEditorToBelowGroup')<CR>
nnoremap <C-w><C-i> <Cmd>call VSCodeNotify('workbench.action.moveEditorToAboveGroup')<CR>
xnoremap <C-w><C-i> <Cmd>call VSCodeNotify('workbench.action.moveEditorToAboveGroup')<CR>
nnoremap <C-w><C-h> <Cmd>call VSCodeNotify('workbench.action.moveEditorToLeftGroup')<CR>
xnoremap <C-w><C-h> <Cmd>call VSCodeNotify('workbench.action.moveEditorToLeftGroup')<CR>
nnoremap <C-w><C-l> <Cmd>call VSCodeNotify('workbench.action.moveEditorToRightGroup')<CR>
xnoremap <C-w><C-l> <Cmd>call VSCodeNotify('workbench.action.moveEditorToRightGroup')<CR>

nnoremap <C-w><C-Down> <Cmd>call VSCodeNotify('workbench.action.moveEditorToBelowGroup')<CR>
xnoremap <C-w><C-Down> <Cmd>call VSCodeNotify('workbench.action.moveEditorToBelowGroup')<CR>
nnoremap <C-w><C-Up> <Cmd>call VSCodeNotify('workbench.action.moveEditorToAboveGroup')<CR>
xnoremap <C-w><C-Up> <Cmd>call VSCodeNotify('workbench.action.moveEditorToAboveGroup')<CR>
nnoremap <C-w><C-Left> <Cmd>call VSCodeNotify('workbench.action.moveEditorToLeftGroup')<CR>
xnoremap <C-w><C-Left> <Cmd>call VSCodeNotify('workbench.action.moveEditorToLeftGroup')<CR>
nnoremap <C-w><C-Right> <Cmd>call VSCodeNotify('workbench.action.moveEditorToRightGroup')<CR>
xnoremap <C-w><C-Right> <Cmd>call VSCodeNotify('workbench.action.moveEditorToRightGroup')<CR>

nnoremap <C-w><S-Down> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupDown')<CR>
xnoremap <C-w><S-Down> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupDown')<CR>
nnoremap <C-w><S-Up> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupUp')<CR>
xnoremap <C-w><S-Up> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupUp')<CR>
nnoremap <C-w><S-Left> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupLeft')<CR>
xnoremap <C-w><S-Left> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupLeft')<CR>
nnoremap <C-w><S-Right> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupRight')<CR>
xnoremap <C-w><S-Right> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupRight')<CR>

nnoremap <C-w>w <Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>
xnoremap <C-w>w <Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>
nnoremap <C-w><C-w> <Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>
xnoremap <C-w><C-w> <Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>
nnoremap <C-w>W <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>
xnoremap <C-w>W <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>

nnoremap <C-w>f <Cmd>call VSCodeNotify('workbench.action.focusFirstEditorGroup')<CR>
xnoremap <C-w>f <Cmd>call VSCodeNotify('workbench.action.focusFirstEditorGroup')<CR>
nnoremap <C-w>b <Cmd>call VSCodeNotify('workbench.action.focusLastEditorGroup')<CR>
xnoremap <C-w>b <Cmd>call VSCodeNotify('workbench.action.focusLastEditorGroup')<CR>

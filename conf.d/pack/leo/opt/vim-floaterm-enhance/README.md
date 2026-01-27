# vim-floaterm-enhance

[中文文档](README_cn.md)

This is a Vim plugin based on [vim-floaterm](https://github.com/voldikss/vim-floaterm) for enhancing the floating terminal. It provides features for REPL integration, AI interaction, and AsyncRun support.

## Architecture Overview

### 1. REPL Startup Flow

```mermaid
graph TB
    Start[FloatermReplStart] --> Check{Programs Configured?}
    Check -->|No| Error[Show Error Message]
    Check -->|Yes| SelectMode{Auto or Interactive?}
    SelectMode -->|Auto| GetFirst[Get First Program]
    SelectMode -->|Interactive| ShowMenu[Show FZF Menu]
    GetFirst --> CheckRunning{Already Running?}
    ShowMenu --> UserSelect[User Selects Program]
    UserSelect --> CheckRunning
    CheckRunning -->|Yes| OpenExist[Open Existing Terminal]
    CheckRunning -->|No| CreateNew[Create New Terminal]
    CreateNew --> SetName[Set Terminal Name]
    SetName --> StoreMap[Store in g:floaterm_repl_dict]
    OpenExist --> Return[Return to Editor]
    StoreMap --> Return
```

## Keymaps Configuration

The following keymaps are based on the configuration in `conf.d`.

### REPL Keymaps
> **Prefix**: `<Alt-i>` (`<M-i>`)
> **Source**: `conf.d/main/plugin/debug.vim`

| Key | Mode | Command | Action |
| :--- | :--- | :--- | :--- |
| **Window & Control** |
| `<M-i><M-i>` | n/i/v/t | (Map) | Switch focus between Editor and REPL Window |
| `<M-i><M-r>` | n | `:FloatermReplStart` | **Start** REPL (Interactive Selection) |
| `<M-i>r` | n | `:FloatermReplStart!` | Start Default REPL immediately |
| `<M-i><Cr>` | n | `:FloatermReplSendCrOrStart!` | Send **Enter** or Start REPL |
| `<M-i>q` | n | `:FloatermReplSendExit` | Send **Quit**/Exit command |
| `<M-i>L` | n | `:FloatermReplSendClear` | Clear REPL screen |
| **Send Code** |
| `<M-i>n` | n/v | `:FloatermReplSend` | Send Line/Selection (Move to **N**ext) |
| `<M-i>l` | n/v | `:FloatermReplSend!` | Send **L**ine/Selection (Stay) |
| `<M-i><M-e>`| n/v | `:FloatermReplSendBlock` | Send **Block** / Visual (Move Next) |
| `<M-i>e` | n | `:FloatermReplSendToEnd!` | Send to **E**nd of file |
| `<M-i>b` | n | `:FloatermReplSendFromBegin!` | Send from **B**eginning |
| `<M-i>a` | n | `:FloatermReplSendAll!` | Send **A**ll content |
| `<M-i>k` | n/v | `:FloatermReplSendWord` | Send **K**eyword (Word under cursor) |
| **Marks** |
| `<M-i>m` | n/v | `:FloatermReplMark` | **M**ark Selection |
| `<M-i>s` | n | `:FloatermReplSendMark` | **S**end Marked Code |
| `<M-i>S` | n | `:FloatermReplShowMark` | **S**how Marked Code |

### AI Keymaps
> **Prefix**: `<Alt-e>` (`<M-e>`)
> **Source**: `conf.d/main/plugin/ai.vim`

| Key | Mode | Command | Action |
| :--- | :--- | :--- | :--- |
| **Control** |
| `<M-e><M-e>` | n/i/v/t | (Map) | Switch focus between Editor and AI Window |
| `<M-e><M-r>` | n | `:FloatermAiStart` | Start AI (Interactive) |
| `<M-e>r` | n | `:FloatermAiStart!` | Start Default AI |
| `<M-e><Cr>` | n | `:FloatermAiSendCr` | Send Enter |
| **Context Sending** |
| `<M-e>l` | n/v | `:FloatermAiSendLineRange` | Send **L**ine/Selection |
| `<M-e><BS>` | n/v | `:FloatermAiSendLineRange!` | Send Line/Selection (Stay in buffer) |
| `<M-e>f` | n | `:FloatermAiSendFile` | Send **F**ile content |
| `<M-e>=` | n | `:FloatermAiSendFile!` | Send File content (Stay in buffer) |
| `<M-e>d` | n | `:FloatermAiSendDir` | Send **D**irectory file list |
| `<M-e>-` | n | `:FloatermAiSendDir!` | Send Directory list (Stay in buffer) |
| `<M-e>i` | n | `:FloatermAiFzfFiles` | Select files via FZF to send |
| `<M-e>0` | n | `:FloatermAiFzfFiles!` | Select files via FZF (Stay in buffer) |

## Configuration Example

### REPL Config
```vim
" Switch window
nnoremap <M-i><M-i> <C-w><C-w>
inoremap <M-i><M-i> <ESC><C-w><C-w>
xnoremap <M-i><M-i> <ESC><C-w><C-w>
tnoremap <M-i><M-i> <C-\><C-n><C-w><C-w>

" Start
nnoremap <silent><M-i><M-r> :FloatermReplStart<Cr>
nnoremap <silent><M-i>r :FloatermReplStart!<Cr>
nnoremap <silent><M-i><Cr> :FloatermReplSendCrOrStart!<Cr>

" Send
nnoremap <silent><M-i>n :FloatermReplSend<Cr>
nnoremap <silent><M-i>l :FloatermReplSend!<Cr>
xnoremap <silent><M-i>n :FloatermReplSend<Cr>
xnoremap <silent><M-i>l :FloatermReplSend!<Cr>

" Block & Scope
nnoremap <silent><M-i><M-e> :FloatermReplSendBlock<Cr>
nnoremap <silent><M-i>e :FloatermReplSendToEnd!<Cr> " Note: Overrides Block!
nnoremap <silent><M-i>b :FloatermReplSendFromBegin!<Cr>
nnoremap <silent><M-i>a :FloatermReplSendAll!<Cr>

" Misc
nnoremap <silent><M-i>q :FloatermReplSendExit<Cr>
nnoremap <silent><M-i>L :FloatermReplSendClear<Cr>
nnoremap <silent><M-i>k :FloatermReplSendWord<Cr>
```

### AI Config
```vim
" Switch window
nnoremap <M-e><M-e> <C-w><C-w>

" Start
nnoremap <silent><M-e><M-r> :FloatermAiStart<Cr>
nnoremap <silent><M-e>r :FloatermAiStart!<Cr>
nnoremap <silent><M-e><Cr> :FloatermAiSendCr<Cr>

" Send Context
nnoremap <silent><M-e>l    :FloatermAiSendLineRange<Cr>
nnoremap <silent><M-e><BS> :FloatermAiSendLineRange!<Cr>
nnoremap <silent><M-e>f    :FloatermAiSendFile<Cr>
nnoremap <silent><M-e>=    :FloatermAiSendFile!<Cr>
nnoremap <silent><M-e>d    :FloatermAiSendDir<Cr>
nnoremap <silent><M-e>-    :FloatermAiSendDir!<Cr>
nnoremap <silent><M-e>i    :FloatermAiFzfFiles<Cr>
nnoremap <silent><M-e>0    :FloatermAiFzfFiles!<Cr>
```

# AsyncRun.vim Integration

In addition to the REPL functionality, this plugin provides integration with [asyncrun.vim](https://github.com/skywind3000/asyncrun.vim) to run programs in floating terminals.

## Features

The following runners are registered automatically:

* **`floaterm_right`**: Run commands in a vertical split terminal on the right side
* **`floaterm_float`**: Run commands in a floating terminal window
* **`floaterm_bottom`**: Run commands in a horizontal split terminal at the bottom

## Usage Examples

```vim
" Run a simple command in a floating terminal
:AsyncRun -mode=term -pos=floaterm_float echo "Hello, World!"

" Run a Python script in a right-side terminal
:AsyncRun -mode=term -pos=floaterm_right python %

" Run a Node.js script in a bottom terminal
:AsyncRun -mode=term -pos=floaterm_bottom node %
```

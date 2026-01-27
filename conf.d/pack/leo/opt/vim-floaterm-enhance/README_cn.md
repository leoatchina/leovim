# vim-floaterm-enhance

[English Document](README.md)

这是一个基于 [vim-floaterm](https://github.com/voldikss/vim-floaterm) 的 Vim 插件，用于增强浮动终端的功能。本插件提供 REPL 集成、AI 交互以及 AsyncRun 支持等主要功能。

## 架构概览

### 1. REPL 启动流程

```mermaid
graph TB
    Start[FloatermReplStart] --> Check{是否配置程序?}
    Check -->|否| Error[显示错误信息]
    Check -->|是| SelectMode{自动或交互选择?}
    SelectMode -->|自动| GetFirst[获取第一个程序]
    SelectMode -->|交互| ShowMenu[显示 FZF 菜单]
    GetFirst --> CheckRunning{是否已运行?}
    ShowMenu --> UserSelect[用户选择程序]
    UserSelect --> CheckRunning
    CheckRunning -->|是| OpenExist[打开现有终端]
    CheckRunning -->|否| CreateNew[创建新终端]
    CreateNew --> SetName[设置终端名称]
    SetName --> StoreMap[存储到 g:floaterm_repl_dict]
    OpenExist --> Return[返回编辑器]
    StoreMap --> Return
```

## 快捷键配置

以下快捷键基于 `conf.d` 中的配置。

### REPL 快捷键
> **前缀**: `<Alt-i>` (`<M-i>`)
> **来源**: `conf.d/main/plugin/debug.vim`

| 快捷键 | 模式 | 命令 | 功能描述 |
| :--- | :--- | :--- | :--- |
| **窗口与控制** |
| `<M-i><M-i>` | n/i/v/t | (映射) | 在编辑器和 REPL 窗口间**切换焦点** |
| `<M-i><M-r>` | n | `:FloatermReplStart` | **启动** REPL (交互式选择) |
| `<M-i>r` | n | `:FloatermReplStart!` | 立即启动默认 REPL |
| `<M-i><Cr>` | n | `:FloatermReplSendCrOrStart!` | 发送**回车** 或 启动 REPL |
| `<M-i>q` | n | `:FloatermReplSendExit` | 发送**退出**命令 (Quit) |
| `<M-i>L` | n | `:FloatermReplSendClear` | **清屏** (Clear) |
| **发送代码** |
| `<M-i>n` | n/v | `:FloatermReplSend` | 发送行/选区 (光标**下移** Next) |
| `<M-i>l` | n/v | `:FloatermReplSend!` | 发送行/选区 (光标**不动** Line) |
| `<M-i><M-e>`| n/v | `:FloatermReplSendBlock` | 发送**代码块** / 可视选区 (光标下移) |
| `<M-i>e` | n | `:FloatermReplSendToEnd!` | 发送至文件**末尾** (End) |
| `<M-i>b` | n | `:FloatermReplSendFromBegin!` | 发送从**开始**的内容 (Begin) |
| `<M-i>a` | n | `:FloatermReplSendAll!` | 发送**全部**内容 (All) |
| `<M-i>k` | n/v | `:FloatermReplSendWord` | 发送光标下的**关键词**/单词 |
| **标记功能** |
| `<M-i>m` | n/v | `:FloatermReplMark` | **标记**选区 (Mark) |
| `<M-i>s` | n | `:FloatermReplSendMark` | **发送**已标记代码 (Send) |
| `<M-i>S` | n | `:FloatermReplShowMark` | **显示**已标记代码 (Show) |

### AI 快捷键
> **前缀**: `<Alt-e>` (`<M-e>`)
> **来源**: `conf.d/main/plugin/ai.vim`

| 快捷键 | 模式 | 命令 | 功能描述 |
| :--- | :--- | :--- | :--- |
| **控制** |
| `<M-e><M-e>` | n/i/v/t | (映射) | 在编辑器和 AI 窗口间**切换焦点** |
| `<M-e><M-r>` | n | `:FloatermAiStart` | 启动 AI (交互式) |
| `<M-e>r` | n | `:FloatermAiStart!` | 启动默认 AI |
| `<M-e><Cr>` | n | `:FloatermAiSendCr` | 发送回车 |
| **发送上下文** |
| `<M-e>l` | n/v | `:FloatermAiSendLineRange` | 发送**行**/选区 |
| `<M-e><BS>` | n/v | `:FloatermAiSendLineRange!` | 发送行/选区 (保持在当前缓冲区) |
| `<M-e>f` | n | `:FloatermAiSendFile` | 发送**文件**内容 |
| `<M-e>=` | n | `:FloatermAiSendFile!` | 发送文件内容 (保持在当前缓冲区) |
| `<M-e>d` | n | `:FloatermAiSendDir` | 发送**目录**列表 |
| `<M-e>-` | n | `:FloatermAiSendDir!` | 发送目录列表 (保持在当前缓冲区) |
| `<M-e>i` | n | `:FloatermAiFzfFiles` | 通过 FZF 选择文件发送 |
| `<M-e>0` | n | `:FloatermAiFzfFiles!` | 通过 FZF 选择文件 (保持在当前缓冲区) |

## 配置示例

### REPL 配置
```vim
" 切换窗口
nnoremap <M-i><M-i> <C-w><C-w>
inoremap <M-i><M-i> <ESC><C-w><C-w>
xnoremap <M-i><M-i> <ESC><C-w><C-w>
tnoremap <M-i><M-i> <C-\><C-n><C-w><C-w>

" 启动
nnoremap <silent><M-i><M-r> :FloatermReplStart<Cr>
nnoremap <silent><M-i>r :FloatermReplStart!<Cr>
nnoremap <silent><M-i><Cr> :FloatermReplSendCrOrStart!<Cr>

" 发送
nnoremap <silent><M-i>n :FloatermReplSend<Cr>
nnoremap <silent><M-i>l :FloatermReplSend!<Cr>
xnoremap <silent><M-i>n :FloatermReplSend<Cr>
xnoremap <silent><M-i>l :FloatermReplSend!<Cr>

" 代码块与范围
nnoremap <silent><M-i><M-e> :FloatermReplSendBlock<Cr>
nnoremap <silent><M-i>e :FloatermReplSendToEnd!<Cr> " 注意: 覆盖了 Block!
nnoremap <silent><M-i>b :FloatermReplSendFromBegin!<Cr>
nnoremap <silent><M-i>a :FloatermReplSendAll!<Cr>

" 其他
nnoremap <silent><M-i>q :FloatermReplSendExit<Cr>
nnoremap <silent><M-i>L :FloatermReplSendClear<Cr>
nnoremap <silent><M-i>k :FloatermReplSendWord<Cr>
```

### AI 配置
```vim
" 切换窗口
nnoremap <M-e><M-e> <C-w><C-w>

" 启动
nnoremap <silent><M-e><M-r> :FloatermAiStart<Cr>
nnoremap <silent><M-e>r :FloatermAiStart!<Cr>
nnoremap <silent><M-e><Cr> :FloatermAiSendCr<Cr>

" 发送上下文
nnoremap <silent><M-e>l    :FloatermAiSendLineRange<Cr>
nnoremap <silent><M-e><BS> :FloatermAiSendLineRange!<Cr>
nnoremap <silent><M-e>f    :FloatermAiSendFile<Cr>
nnoremap <silent><M-e>=    :FloatermAiSendFile!<Cr>
nnoremap <silent><M-e>d    :FloatermAiSendDir<Cr>
nnoremap <silent><M-e>-    :FloatermAiSendDir!<Cr>
nnoremap <silent><M-e>i    :FloatermAiFzfFiles<Cr>
nnoremap <silent><M-e>0    :FloatermAiFzfFiles!<Cr>
```

# AsyncRun.vim集成

除了REPL功能外，本插件还提供了与[asyncrun.vim](https://github.com/skywind3000/asyncrun.vim)的集成，可以在浮动终端中运行程序。

## 功能特性

以下runner被自动注册：

* **`floaterm_right`**: 在右侧垂直分割终端中运行命令
* **`floaterm_float`**: 在浮动终端窗口中运行命令
* **`floaterm_bottom`**: 在底部水平分割终端中运行命令

## 使用示例

```vim
" 在浮动终端中运行简单命令
:AsyncRun -mode=term -pos=floaterm_float echo "Hello, World!"

" 在右侧终端中运行 Python 脚本
:AsyncRun -mode=term -pos=floaterm_right python %

" 在底部终端中运行 Node.js 脚本
:AsyncRun -mode=term -pos=floaterm_bottom node %
```

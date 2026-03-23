# LeoVim

> 面向开发人员的 Vim/Neovim IDE 配置框架
> 开箱即用 · 功能完备 · 高度可定制 · 同时支持 Vim 和 Neovim

## 1. 核心特性

### 1.1. 开箱即用，零配置启动
- **一键安装** - 单条命令完成安装，无需手动配置插件
  - Linux/macOS: `git clone https://gitee.com/leoatchina/leovim ~/.leovim && cd ~/.leovim && ./install.sh`
  - Windows: `git clone https://gitee.com/leoatchina/leovim %USERPROFILE%\.leovim` 后以管理员权限运行 `install.cmd`
- **离线可用** - 内置 `pack` 基础包，无网络也能正常使用
- **智能降级** - 根据环境自动选择最佳配置（Vim/Neovim，GUI/终端）
- **预设模板** - 自动创建 `.gitignore`、`.lintr` 等常用配置文件

> **配置文件**: [`install.sh`](install.sh) · [`conf.d/pack/`](conf.d/pack/) · [`conf.d/templates/`](conf.d/templates/)

### 1.2. 跨平台兼容
- **系统支持** - Linux、Windows、macOS 统一配置
- **Vim/Neovim 通用** - 同一配置同时支持 Vim 和 Neovim
- **VSCode Neovim** - `vscode-neovim` 模式专用配置与快捷键
- **终端/GUI 自适应** - 自动检测环境，优化键位映射和颜色显示
- **便携打包** - `compress.sh` 打包整个配置，一键迁移到新机器

> **配置文件**: [`scripts/compress.sh`](scripts/compress.sh) · [`conf.d/init/vscode.vim`](conf.d/init/vscode.vim) · [`conf.d/init/keybindings.json`](conf.d/init/keybindings.json) (VSCode) · [`conf.d/main/main.vim`](conf.d/main/main.vim) (环境检测)

### 1.3. 高度可定制
- **功能开关** - `~/.vimrc.opt` 控制所有模块的启用/禁用
- **用户配置** - `~/.leovim.d/after.vim` 添加个人配置，不影响升级
- **自定义插件** - `~/.leovim.d/pack.vim` 添加额外插件
- **按文件类型定制** - 丰富的 ftplugin 配置，每种语言独立优化

> **配置文件**: `~/.vimrc.opt` · `~/.leovim.d/after.vim` · `~/.leovim.d/pack.vim` · [`conf.d/init/ftplugin/`](conf.d/init/ftplugin/)

### 1.4. AI 增强体系
- **AI 助手 (`<M-i>`)**
  - 专注于**代码理解与对话**
  - 基于 `vim-floaterm-enhance` 的统一交互体验，将代码/文件/目录发送到 CLI AI 工具（如 `claude`, `codex`, `opencode` 等）
  - **opencode.nvim**：Neovim 原生 AI 编码助手，`<M-i>o` 切换窗口，`<Tab>o` 系列操作（ask/select/diff 等）
- **REPL 交互 (`<M-a>`)**
  - 将代码发送到解释器 (Python/R/Shell) 执行
  - 支持行发送、块发送、整文件发送、标记发送

> **配置文件**: [`conf.d/main/plugin/complete.vim`](conf.d/main/plugin/complete.vim) (AI 快捷键) · [`conf.d/main/plugin/repl.vim`](conf.d/main/plugin/repl.vim) (REPL) · [`conf.d/pack/leo/opt/vim-floaterm-enhance/`](conf.d/pack/leo/opt/vim-floaterm-enhance/)

### 1.5. 智能补全，多引擎支持
- **多层补全体系**
  - 基础：vim-mucomplete（dict + buffer + path）
  - 内建：builtin（Neovim 0.11+ / Vim 9.1.1590+ 原生补全）
  - 进阶：coc.nvim（Node.js LSP，插件生态丰富）
  - 高级：blink.cmp / nvim-cmp（原生 Neovim LSP，Rust 加速，性能极致）
- **代码片段** - VSCode 格式 snippets，支持自定义和共享
- **多语言支持** - 内置 Python, Go, Rust, C/C++, Java, JS/TS, R, Lua, LaTeX 等语言配置

> **配置文件**: [`conf.d/main/plugin/complete.vim`](conf.d/main/plugin/complete.vim) · [`conf.d/plug/application.vim`](conf.d/plug/application.vim) (引擎选择) · [`conf.d/main/after/cfg/coc.vim`](conf.d/main/after/cfg/coc.vim) · [`conf.d/main/lua/lsp.lua`](conf.d/main/lua/lsp.lua) · [`conf.d/snippets/`](conf.d/snippets/)

### 1.6. Treesitter 语法感知
- **智能高亮** - 基于 AST 的精确语法高亮，支持数百种语言
- **增量选择** - 语法树级区域扩展
  - `<M-s>`: 初始化选择 / 扩展到当前范围
  - `<Tab>`: 扩展到父节点
  - `<M-S>`: 收缩到子节点
- **文本对象** - 基于语法树的操作 (`d`, `c`, `y`, `v` 后接)
  - `af` / `if`: 函数 (Function) 外部/内部
  - `ac` / `ic`: 类 (Class) 外部/内部
  - `aL` / `iL`: 循环 (Loop) 外部/内部
- **快速导航** - 在语法节点间跳转
  - `;f` / `,f`: 下/上一个函数起始
  - `;c` / `,c`: 下/上一个类起始
  - `;l` / `,l`: 下/上一个循环起始
  - `;z` / `,z`: 下/上一个折叠 (Fold)
  - `sv`: **Flash Treesitter** - 极速跳转到任意语法节点 (带标签)
  - `m`: **Flash Treesitter Search** - (可视/操作模式) 搜索并选中语法节点

> **配置文件**: [`conf.d/main/lua/treesitter.lua`](conf.d/main/lua/treesitter.lua) · [`conf.d/init/plugin/textobj.vim`](conf.d/init/plugin/textobj.vim)

### 1.7. 强大搜索，三层查找机制
- **模糊搜索** - FZF/LeaderF 快速定位文件、buffer、命令
- **全局搜索** - ripgrep 高性能全文搜索，支持正则表达式
- **符号导航** - LSP → Ctags → 全局搜索，三层智能回退
- **搜索后替换** - 搜索结果直接按 `r` 进入批量替换模式
- **增量搜索** - Buffer 内实时搜索，支持多 buffer 联合搜索

> **配置文件**: [`conf.d/main/plugin/search.vim`](conf.d/main/plugin/search.vim) · [`conf.d/main/plugin/tags.vim`](conf.d/main/plugin/tags.vim) · [`conf.d/main/plugin/atomic.vim`](conf.d/main/plugin/atomic.vim) (Flash 跳转)

### 1.8. 完整调试体系
- **双调试器支持**
  - Vimspector：跨语言调试器，配置简单
  - nvim-dap：Neovim 原生 DAP 协议，扩展性强

> **配置文件**: [`conf.d/main/plugin/debug.vim`](conf.d/main/plugin/debug.vim) · [`conf.d/dap/`](conf.d/dap/) · [`conf.d/vimspector/`](conf.d/vimspector/) · 项目根目录的 `.vimspector.json` 或 `.vscode/launch.json`

### 1.9. 高性能设计
- **模块化加载** - 功能开关文件 `~/.vimrc.opt` 按需启用模块
- **延迟加载** - 插件按需加载（利用 vim-plug 封装的 PlugAdd）
- **增量索引** - Ctags/Gtags 增量更新，大项目快速响应
- **异步执行** - 编译、测试、搜索均在后台异步运行

> **配置文件**: `~/.vimrc.opt` · [`conf.d/init/opt.vim`](conf.d/init/opt.vim) (opt 模板) · [`conf.d/plug/`](conf.d/plug/) (插件清单) · [`conf.d/main/plugin/run.vim`](conf.d/main/plugin/run.vim) (异步任务)

### 1.10. 会话管理
- **自动保存** - 退出时自动保存当前会话（窗口布局、Buffer、光标位置）
- **可视化管理** - `<Leader>ss` 调出 FZF 面板，快速搜索、加载、删除历史会话
- **启动页集成** - Startify 启动页显示最近使用的会话，一键恢复工作现场

> **配置文件**: [`conf.d/main/plugin/session.vim`](conf.d/main/plugin/session.vim) · [`conf.d/main/plugin/history.vim`](conf.d/main/plugin/history.vim) (文件历史)

### 1.11. 现代 IDE 体验
- **丰富的 UI 组件**
  - 文件管理：Oil.nvim (像编辑 buffer 一样管理文件) / fern.vim
  - 导航栏：Dropbar.nvim (Winbar 面包屑导航)
  - 状态栏：lightline，实时显示 Git 分支、LSP 状态、文件信息
  - 标签栏：智能 buffer 管理，支持快速切换和关闭
  - 浮动窗口：终端、REPL、AI 助手均支持浮动窗口
- **WhichKey 提示系统** - 按下先导键自动显示所有可用命令
- **主题丰富** - 内置 Catppuccin, TokyoNight, Edge, Gruvbox 等多种配色

> **配置文件**: [`conf.d/main/plugin/sidebar.vim`](conf.d/main/plugin/sidebar.vim) · [`conf.d/main/plugin/lightline.vim`](conf.d/main/plugin/lightline.vim) · [`conf.d/main/plugin/scheme.vim`](conf.d/main/plugin/scheme.vim) · [`conf.d/main/plugin/indicate.vim`](conf.d/main/plugin/indicate.vim) (WhichKey) · [`conf.d/main/plugin/buffer.vim`](conf.d/main/plugin/buffer.vim) · [`conf.d/main/plugin/tab.vim`](conf.d/main/plugin/tab.vim) · [`conf.d/main/plugin/window.vim`](conf.d/main/plugin/window.vim)

### 1.12. 完整的 Git 工作流
- **版本控制集成**
  - fugitive：Vim 内 Git 操作，`:Git` 系列命令
  - LazyGit：TUI Git 客户端，可视化操作
  - Leaderf Git：模糊搜索 Git 历史、状态、blame
- **增强功能**
  - 行级 blame 显示
  - 文件历史对比
  - 交互式 rebase
  - Conflict marker 高亮和快速解决

> **配置文件**: [`conf.d/main/plugin/git.vim`](conf.d/main/plugin/git.vim) · [`conf.d/init/autoload/git.vim`](conf.d/init/autoload/git.vim) (Git 工具函数)

### 1.13. 任务与模板
- **全局任务库** - `tasks_common.ini` 内置通用任务
  - `git-push-master` / `git-checkout`
  - `net-host-ip` / `net-check-port`
  - `misc-weather` / `misc-system-info`
- **项目模板** - 自动识别并生成配置文件
  - `.gitignore`, `.gitconfig`
  - `.lintr` (R Linter), `.wildignore`
  - `Rprofile`, `radian_profile`

> **配置文件**: [`conf.d/main/plugin/run.vim`](conf.d/main/plugin/run.vim) · [`conf.d/tasks/`](conf.d/tasks/) · [`conf.d/templates/`](conf.d/templates/) · 项目根目录或 `~/.config/tasks.ini`

---

## 2. 系统要求

**必需**
- Vim 7.4.399+ 或 Neovim 0.8+ (VSCode Neovim 需要 0.10+)
- Git 1.8.5+

**可选（增强功能）**
- Node.js 16.18+ (coc.nvim LSP 支持)
- Python 3.8+ + neovim + pygments
- Universal Ctags 5.8+
- GNU Global 6.6.7+
- VSCode + `vscode-neovim` (仅 VSCode 模式需要)

## 3. 配置文件说明

### 3.1. 目录结构
```
~/.leovim/
├── conf.d/                      # 主配置目录
│   ├── init.vim                 # 入口文件 (所有配置的起点)
│   ├── init/                    # 初始化阶段配置
│   │   ├── opt.vim              # ~/.vimrc.opt 模板/示例
│   │   ├── vscode.vim           # VSCode Neovim 专用配置
│   │   ├── keybindings.json     # VSCode 快捷键配置
│   │   ├── autoload/            # 核心工具函数 (utils.vim, pack.vim, git.vim, textobj.vim)
│   │   ├── plugin/              # 基础设置 (set.vim, textobj.vim, ftdetect.vim)
│   │   ├── ftplugin/            # 文件类型配置 (python, go, rust, c, java 等)
│   │   └── lua/                 # Neovim Lua 工具 (utils.lua)
│   ├── main/                    # 主配置 (非 VSCode 模式)
│   │   ├── main.vim             # Meta 键/环境检测/加载 plug/ 目录
│   │   ├── autoload/            # plug.vim (PlugAdd 相关)
│   │   ├── plugin/              # 功能模块 (30+ 个配置文件)
│   │   ├── lua/                 # Neovim Lua 配置
│   │   │   ├── lsp.lua          # LSP 核心配置
│   │   │   ├── treesitter.lua   # Treesitter 配置
│   │   │   └── cfg/             # 插件 Lua 配置 (blink, cmp, dap, flash, oil 等)
│   │   └── after/
│   │       ├── cfg/             # 插件 VimScript 配置 (coc, fzf, leaderf, fern 等)
│   │       └── lsp/             # LSP 服务器配置 (pyright, clangd, rust_analyzer 等)
│   ├── plug/                    # 插件声明清单
│   │   ├── application.vim      # 补全引擎/LSP/调试器/搜索工具/UI
│   │   ├── common.vim           # 通用插件 (surround, comment, pairs 等)
│   │   ├── languages.vim        # 语言相关插件
│   │   ├── symbol.vim           # 符号/大纲插件
│   │   └── zfvim.vim            # ZFVim 系列插件
│   ├── pack/leo/opt/            # 内置自有插件
│   │   ├── vim-floaterm-enhance/  # 浮动终端增强 (AI/REPL)
│   │   ├── fzf-registers/      # FZF 寄存器浏览
│   │   └── fzf-tabs/           # FZF 标签页管理
│   ├── snippets/                # VSCode 格式代码片段 (global, go, python)
│   ├── tasks/                   # AsyncTasks 任务模板
│   ├── templates/               # 项目文件模板 (.gitignore, .lintr 等)
│   ├── dap/                     # nvim-dap 启动配置
│   └── vimspector/              # Vimspector 调试配置
├── pack/                        # 扩展包
│   ├── fork/opt/                # Fork 修改的插件
│   ├── clone/opt/               # 直接克隆的插件
│   ├── colors/                  # 配色方案
│   └── doc/                     # 文档
├── scripts/                     # 工具脚本 (compress.sh, bashrc, zshrc 等)
├── assets/                      # 资源文件
└── fonts/                       # 字体
```

### 3.2. 加载流程

```
conf.d/init.vim (入口)
  ├── 设置目录变量 ($CONF_D_DIR, $INIT_DIR, $MAIN_DIR, $PLUG_DIR 等)
  ├── 添加 $PACK_DIR, $INIT_DIR 到 runtimepath
  ├── 扫描 opt 插件目录 (leo/opt, fork/opt, clone/opt)
  ├── 设置 mapleader=空格, maplocalleader=q
  ├── 基础键位映射
  ├── source ~/.vimrc.opt (用户功能开关)
  ├── plug#begin() → 定义 PlugAdd 命令
  ├── source ~/.leovim.d/pack.vim (用户额外插件)
  ├── [VSCode 模式] → source conf.d/init/vscode.vim
  ├── [正常模式]   → source conf.d/main/main.vim
  │     ├── Meta 键映射 (Alt 键设置)
  │     ├── Python/Node/Git 版本检测
  │     ├── 终端/Truecolor 配置
  │     ├── Ctags/Gtags 配置
  │     ├── source conf.d/plug/*.vim (所有插件声明)
  │     └── Mason/工具 PATH 设置
  ├── source ~/.leovim.d/after.vim (用户自定义配置)
  └── plug#end()
        └── Vim 自动加载 runtimepath 中的:
              ├── conf.d/init/plugin/*.vim
              ├── conf.d/main/plugin/*.vim (功能模块)
              ├── conf.d/main/after/cfg/*.vim (插件配置)
              └── conf.d/main/lua/*.lua (Neovim Lua)
```

### 3.3. 自定义配置
- `~/.vimrc.opt` - 功能开关文件（参考 [`conf.d/init/opt.vim`](conf.d/init/opt.vim) 模板）
- `~/.leovim.d/after.vim` - 用户自定义配置
- `~/.leovim.d/pack.vim` - 自定义插件列表
- `~/.leovim.d/ftplugin/` - 语言级局部配置

## 4. 快速安装

**Linux/macOS**
```bash
./install.sh          # 基础安装
./install.sh all      # 完整安装（推荐）
```

**Windows**
```cmd
install.cmd           # 以管理员权限运行
```

**安装选项**
```bash
./install.sh neovim   # 安装最新 Neovim
./install.sh nodejs   # 安装最新 Node.js
./install.sh rc       # 安装优化的 bashrc
./install.sh z.lua    # 安装路径跳转工具
./install.sh leotmux  # 安装 tmux 增强
```

**卸载**
```bash
./uninstall.sh        # Linux/macOS
uninstall.cmd         # Windows
```

## 5. VSCode Neovim 快速开始

1) 安装 VSCode 与 `vscode-neovim` 扩展，确保 `nvim` 版本 >= 0.10 且在 PATH 中
2) 在 VSCode `settings.json` 指定 LeoVim 入口：
```json
{
  "vscode-neovim.neovimInitVimPaths.linux": "~/.leovim/conf.d/init.vim",
  "vscode-neovim.neovimInitVimPaths.mac": "~/.leovim/conf.d/init.vim",
  "vscode-neovim.neovimInitVimPaths.windows": "C:\\\\Users\\\\<you>\\\\.leovim\\\\conf.d\\\\init.vim"
}
```
3) 将 `conf.d/init/keybindings.json` 合并到 VSCode 的 `keybindings.json`，以启用专用快捷键

## 6. 快速上手

### 6.1. Leader 键说明
- `<Leader>` = `空格` (主导航键)
- `<LocalLeader>` = `q` (文件类型专用)
- `<M->` = `Alt` 键

### 6.2. 核心先导键速查

按下以下先导键会进入对应的功能域：

| 先导键 | 功能域 | 说明 |
|--------|--------|------|
| `<Leader>` (空格) | **主功能菜单** | 文件、搜索、项目、Git 等主要操作 |
| `<M-h>` | **配置文件** | 快速打开配置文件和项目文件 |
| `<M-j>` | **跳转文件** | 打开文件（edit/tab/split/vsplit） |
| `<M-k>` | **功能开关** | 切换编辑器功能（主题、只读、命令等） |
| `<M-l>` | **LSP/行搜索** | LSP 操作 (CocInfo/LspInfo) + Buffer 行搜索 |
| `<M-r>` | **运行任务** | 异步任务选择菜单 (FzfAsyncTasks) |
| `<M-e>` | **调试器** | 断点、单步、变量查看等调试功能 |
| `<M-m>` | **调试 UI** | 调试窗口/UI 切换（Gdb/Source/Asm/DapUI 等） |
| `<M-i>` | **AI 助手** | AI 代码辅助（发送代码、文件、目录到 AI） |
| `<M-a>` | **REPL 交互** | 代码发送到 REPL 环境执行 |
| `<M-g>` | **Git 操作** | 版本控制、提交、推送、历史查看 |
| `<M-y>` | **复制系列** | 寄存器 yank / 路径复制、外部编辑器打开等 |
| `<M-v>` | **粘贴系列** | 寄存器 paste / 粘贴模式 |
| `<M-t>` | **浮动终端** | 浮动终端操作 |
| `;` / `,` | **快速导航** | 前进/后退跳转（buffer、错误、符号等） |
| `[` / `]` | **成对移动** | 括号、函数、类等结构间移动 |
| `s` | **快速跳转** | Flash/easymotion 跳转和文本对象操作, vim-surround/vim-sandwich 操作 |
| `m` | **标记管理** | 设置/跳转/删除标记 (marks) |
| `\` | **窗口布局** | 窗口大小调整和布局切换 |
| `<Tab>` | **窗口控制** | 分屏、任务停止等窗口操作 |

> 提示: 按下任意先导键后会自动弹出 WhichKey 提示窗口，显示该功能域下的所有可用快捷键

### 6.3. 重要修改的原生键位
| 键位 | 功能 | 原功能 |
|------|------|--------|
| `H/L` | 行首/行尾 | 屏幕顶/底 |
| `s` | 跳转/文本对象 | 替换字符 |
| `q` → `M` | 宏录制 | 宏录制 |
| `;` / `,` | 前进/后退导航 | 重复 f/t |

### 6.4. 快捷键提示系统

LeoVim 配置了 **WhichKey** 提示系统，按下任何先导键后会自动显示可用的子命令。例如：
- 按 `<M-h>` 会显示所有配置文件快捷键
- 按 `<M-e>` 会显示所有调试操作
- 按 `<Leader>` 会显示主菜单

**查看所有键位映射**：
```vim
:map          " 查看所有映射
:nmap         " 查看 normal 模式映射
:imap         " 查看 insert 模式映射
:vmap         " 查看 visual 模式映射
```

## 7. 常用功能速查

### 7.1. 文件与项目 (`<Leader>` 空格键)
```
<Leader>ff      文件搜索
<Leader>p       Git 文件搜索
<Leader>w       保存所有
<Leader>Q       关闭 buffer
<C-p>           工程浏览
;b / ,b         切换 buffer
<M-n/p>         切换标签页
<M-1~9>         跳转到标签页 1-9
```

### 7.2. 快速打开配置 (`<M-h>`)
```
# LeoVim 配置
<M-h>i          init.vim
<M-h>o          .vimrc.opt 功能开关
<M-h>O          opt.vim
<M-h>m          main.vim
<M-h>v          vscode.vim
<M-h>k          keybindings.json
<M-h>u          utils.vim
<M-h>a          application.vim
<M-h>p/d/l      main/plugin、conf.d、~/.leovim 目录
<M-h>A/P        after.vim/pack.vim
<M-h>n          VsnipOpen
<M-h>s/f        snippets 目录 (conf.d / friendly-snippets)

# 项目文件
<M-h>r          README.md
<M-h>t          TODO.md
<M-h>g          .gitignore
<M-h>w          .wildignore

# 系统配置
<M-h>b/z        .bashrc/.zshrc
<M-h>c          .configrc
<M-h>G          .gitconfig
<M-h>C          .ssh/config

# 其他
<M-h><CR>       重新加载 init.vim
<M-h>S          重新加载 .vimrc.opt
<M-h><M-h>      帮助文档搜索
```

### 7.3. 搜索与替换
> 核心配置文件: [`conf.d/main/plugin/search.vim`](conf.d/main/plugin/search.vim)

```
# Buffer 内搜索 (GrepBuf)
z/              搜索光标下单词 (Buffer)
z\              输入搜索词 (Buffer)
z?              搜索寄存器内容 (Buffer)

# 当前目录搜索 (GrepDir)
s<CR>           搜索光标下单词 (Current Dir)
s]              输入搜索词 (Current Dir)
s[              重复上次目录搜索

# 全局/Git 根目录搜索 (GrepAll)
s/              搜索光标下单词 (Project Root)
s\              输入搜索词 (Project Root)
s.              重复上次全局搜索
s?              搜索寄存器内容 (Project Root)

# 模糊搜索工具 (FZF/LeaderF)
<Leader>/       FZF 当前目录搜索
<Tab>/          FZF Git 根目录搜索
<C-f><CR>       LeaderF/FZF 强力全局搜索
  → 按 r        搜索后批量替换 (使用 Quickfix 窗口)
  → 按 W        保存所有替换
```

### 7.4. 跳转与导航
```
# 文件跳转 (<M-j>)
<M-j>e          打开光标下文件
<M-j>t          新标签打开文件
<M-j>[          水平分割打开
<M-j>]          垂直分割打开

# Flash 快速跳转 (s 系列)
sj              向前跳转 (Flash Jump Forward)
sk              向后跳转 (Flash Jump Backward)
so              远程操作 (Flash Remote) - 对远处文本执行操作
sv              Treesitter 节点跳转 (Flash Treesitter)

# 增强移动
s; / s,         下/上一个单词 (Easymotion/Word)
sl / sL         行内/跨行跳转
```

### 7.5. 会话管理 (`<Leader>s`)
```
<Leader>ss      FZF 会话列表 (搜索/加载/删除)
<Leader>st      打开 Startify 启动页
<Leader>sv      保存当前会话
<Leader>sl      加载会话
<Leader>sd      删除会话
<Leader>sc      关闭当前会话
```

### 7.6. LSP 与行搜索 (`<M-l>`)
```
# LSP 功能
<M-l>i          LSP/Coc Info
<M-l>r          LSP/Coc Restart
<M-l>e          Coc 扩展列表
<M-l>:          Coc 命令列表
<M-l>;/,        下/上一个补全

# 行搜索
<M-l><M-l>      当前 buffer 行搜索
<M-l><M-a>      所有 buffer 行搜索

# 补全
<Tab>           触发补全 / 下一个
<C-n/p>         下/上一个补全项
<CR>            确认选择

# 代码导航
<C-h>           查看文档
<C-g>           跳转定义
<C-]>           侧栏跳转定义
<M-c>           预览定义
<M-/>           预览引用
<M-d>           LSP 定义搜索
<C-q>           格式化代码
F2              重命名符号
<C-t>           符号大纲侧边栏
```

### 7.7. 调试功能 (`<M-e>` + `<M-m>`)
```
# 调试控制 (<M-e>)
<M-e>r          启动调试
<M-e><CR>       继续执行
<M-e><Space>    切换断点
<M-e>;/,        下/上一个断点
<M-e>n/i/o      StepOver/Into/Out
<M-e>p          暂停
<M-e>q          停止调试
<M-e>c          清除所有断点
<M-e><M-e>      运行到光标

# 调试 UI (<M-m>)
<M-m>           调试窗口/界面切换 (Gdb/Source/DapUI 等)

# 功能键
F5              开始/继续
F9              切换断点
F10/F11/F12     StepOver/Into/Out
-               Watch 变量
J               显示变量/诊断
```

### 7.8. 运行任务
```
<M-r>           任务选择菜单 (FzfAsyncTasks)
<M-B>           Build 任务 / 底部窗口运行
<M-R>           Run 任务 / 右侧窗口运行
<M-T>           Test 任务 / 外部终端
<M-F>           Finalize 任务 / 浮动窗口
<Tab>q          停止任务
!               可视模式运行选中代码

# 智能模式
如果定义了 AsyncTasks 配置，会运行对应任务
否则根据文件类型智能运行当前文件
```

### 7.9. AI 助手 (`<M-i>`)
> 底层依赖: [`vim-floaterm-enhance`](conf.d/pack/leo/opt/vim-floaterm-enhance/)
> 快捷键配置: [`conf.d/main/plugin/complete.vim`](conf.d/main/plugin/complete.vim)

需要在 `~/.vimrc.opt` 中设置 `g:floaterm_ai_programs` 来启用。

```
<M-i><M-i>      在编辑器和 AI 窗口间切换焦点
<M-i><M-r>      启动 AI (交互式选择)
<M-i><Cr>       启动默认 AI (立即执行)
<M-i><Space>    发送回车键到 AI 终端
<M-i>l          发送当前行 / 选中区域到 AI，跳转到 AI 终端
<M-i>f          发送当前文件路径到 AI，跳转到 AI 终端
<M-i>d          发送当前目录路径到 AI，跳转到 AI 终端
<M-i>p          FZF 选择文件发送到 AI，跳转到 AI 终端
<M-i><M-l>      发送当前行 / 选中区域 (保持在当前 buffer)
<M-i><M-f>      发送文件路径 (保持在当前 buffer)
<M-i><M-d>      发送目录路径 (保持在当前 buffer)
<M-i><M-p>      FZF 选择文件发送 (保持在当前 buffer)
```

### 7.10. REPL 交互 (`<M-a>`)
> 核心配置文件: [`conf.d/main/plugin/repl.vim`](conf.d/main/plugin/repl.vim)
> 适用于: Python, R, Shell, Lua, Ruby, Julia, JavaScript 等

```
<M-a><M-i>      在编辑器和 REPL 窗口间切换焦点
<M-a><M-r>      启动 REPL (交互式选择)
<M-a><Cr>       发送回车键或启动 REPL
<M-a>n          发送当前行 / 选中区域，光标移动到下一行
<M-a>l          发送当前行 / 选中区域，光标保持当前位置
<M-a><M-a>      发送代码块 (支持 # %% 标记)，光标移动到下一行
<M-a><Space>    发送代码块，光标保持当前位置
<M-a>b          发送从文件开头到当前行
<M-a>e          发送从当前行到文件末尾
<M-a>a          发送整个文件
<M-a>k          发送光标下的单词
<M-a>m          标记代码区域
<M-a>s          发送已标记区域
<M-a>S          显示已标记区域
<M-a>q          退出 REPL
<M-a>L          清屏 REPL
```

### 7.11. Git 操作 (`<M-g>`)
```
<M-g>a          Git add -A
<M-g>u          Git push
<M-g><CR>       Git commit -av
<M-g>v          查看 Git 历史 (GV)
<M-g>s          查看 Git 状态 (Leaderf)
<M-g>b          查看 Git blame (Leaderf)
<M-g>f/l        当前文件/行的 Git 历史
<M-g>]/[        垂直/水平 diff
<M-g><M-g>      打开 LazyGit
<M-g>:          Git 命令列表
```

### 7.12. 功能开关 (`<M-k>`)
```
<M-k><Space>    切换只读模式
<M-k>t          切换主题 (colorscheme)
<M-k>f          切换文件类型
<M-k>v          显示版本/配置信息
<M-k>V          显示 Vim 版本
<M-k><M-k>      命令列表
<M-k><M-f>      Fzf 命令搜索
<M-k><M-l>      Leaderf 自身命令
<M-k>m          显示消息历史
<M-k>u          转换为 Unix 格式
<M-k>z          切换折叠开关
<M-k>r          显示项目根目录
<M-z>           切换软换行
<Leader>o/O     切换诊断/诊断高亮
```

### 7.13. 诊断与错误
```
<Leader>d       诊断列表
;d / ,d         下/上一个诊断
;e / ,e         下/上一个错误
<Leader>o/O     切换诊断/高亮
```

### 7.14. 文本对象与编辑
```
af/if           函数外部/内部
ac/ic           类外部/内部
ik/ak           当前行
iv/av           代码块 (# %%)
<M-s>           智能扩展选择
;f/c / ,f/c     下/上一个函数/类
```

### 7.15. 窗口与终端
```
# 窗口布局 (<Tab> + \)
<Tab>]/[        垂直/水平分割打开
\a/d/w/s        调整窗口大小
<M-HJKL>        窗口间跳转

# 标签页
<M-n/p>         下/上一个标签页
<M-N/P>         移动标签页位置
<M-1>~<M-9>     跳转到标签 1-9
<M-0>           最后一个标签
<M-w/W>         关闭当前/其他标签

# 浮动终端
<M-->           切换浮动终端
<M-=>           新建终端或列表
<M-+>           切换终端位置
```

### 7.16. 复制粘贴与外部联动
```
# 智能复制
<Leader>ya      复制绝对路径
<Leader>yd      复制目录路径
<Leader>yb      复制文件名
<Leader>yl      复制行引用 (@file#L10-20)
Y               复制到系统剪贴板 (与 tmux/系统互通)

# 外部编辑器联动 (打开当前位置)
<Leader>yv      VSCode
<Leader>yc      Cursor
<Leader>yw      Windsurf
<Leader>yq      Qoder / Trae
<Leader>yz      Zed
```



## 8. 常见问题

### 8.1. 安装相关

**Q: 安装后启动很慢怎么办？**
```vim
" 1. 检查是否在首次启动安装插件
:PlugStatus

" 2. 查看启动时间分析
vim --startuptime startup.log
" 查看 startup.log 找出耗时插件

" 3. 禁用不需要的功能
" 编辑 ~/.vimrc.opt，注释掉不需要的模块
```

**Q: 如何在无网络环境安装？**
1. 在有网络的机器上执行 `./install.sh all`
2. 运行 `scripts/compress.sh` 打包
3. 复制 `~/leovim.tar.gz` 到目标机器
4. 解压后执行 `./install.sh`

**Q: Windows 下安装失败？**
- 确保以管理员权限运行 `install.cmd`
- 检查是否安装了 Git for Windows
- 关闭杀毒软件后重试
- 检查路径中是否包含中文或特殊字符

### 8.2. 功能使用

**Q: 补全不工作？**
```vim
" 1. 检查 LSP 状态
:CocInfo        " 如果使用 coc.nvim
:LspInfo        " 如果使用 nvim-lsp

" 2. 安装语言服务器
:CocInstall coc-python coc-go coc-rust-analyzer

" 3. 检查 Node.js 版本
:!node --version    " coc.nvim 需要 16.18+
```

**Q: 如何切换补全引擎？**

编辑 `~/.vimrc.opt`，按 Vim/Neovim 取消注释对应行：
```vim
" Neovim 0.11+
call pack#add('blink')    " blink.cmp (推荐)
" call pack#add('cmp')    " nvim-cmp
" call pack#add('builtin') " 原生补全

" Vim / Neovim (需要 Node.js)
" call pack#add('coc')    " coc.nvim
" call pack#add('mcm')    " mucomplete (最轻量)
```

**Q: 快捷键冲突怎么办？**

在 `~/.leovim.d/after.vim` 中重新映射：
```vim
" 取消原有映射
unmap <M-h>
" 设置新映射
nnoremap <M-h> :YourCommand<CR>
```

**Q: 如何禁用某个插件？**

编辑 `~/.vimrc.opt` 或 `~/.leovim.d/pack.vim`，注释对应 `pack#add`：
```vim
" call pack#add('fzf')       " 注释即关闭
" call pack#add('coc')       " 注释即关闭
```

### 8.3. 调试问题

**Q: REPL 无法启动？**

```bash
# 检查 Python 环境
python3 -c "import pynvim"

# 检查浮动终端插件
vim -c ':echo exists(":FloatermNew")' -c 'q'

# 手动安装 Python 包
pip3 install pynvim neovim
```

**Q: Git 功能不可用？**

```bash
# 检查 Git 版本
git --version    # 需要 1.8.5+

# 检查 fugitive 插件
vim -c ':scriptnames | grep fugitive'

# 安装 LazyGit（可选）
brew install lazygit              # macOS
sudo apt install lazygit          # Ubuntu
```


### 8.4. 更新维护

**Q: 如何更新 LeoVim？**

```bash
cd ~/.leovim
git pull
./install.sh
```

**Q: 如何更新插件？**

```vim
:PlugUpdate     " 更新所有插件
:PlugUpgrade    " 更新插件管理器
:CocUpdate      " 更新 Coc 扩展
```

**Q: 如何备份配置？**

```bash
# 使用内置打包脚本
~/.leovim/scripts/compress.sh

# 或手动备份
tar -czf leovim-backup.tar.gz \
  ~/.leovim ~/.leovim.d ~/.vimrc ~/.vimrc.opt
```

### 8.5. 高级技巧

**Q: 如何添加自定义语言支持？**

1. 安装 LSP server：`:CocInstall coc-xxx` 或通过 Mason
2. 创建 ftplugin：`~/.leovim.d/ftplugin/xxx.vim`
3. 添加 snippets：`~/.leovim/conf.d/snippets/xxx.json`

**Q: 如何自定义主题？**

在 `~/.leovim.d/after.vim` 中：
```vim
colorscheme your_theme
" 自定义高亮
highlight Normal guibg=#1e1e1e
highlight LineNr guifg=#5a5a5a
```

**Q: 快捷键提示不显示？**

```vim
" 检查 which-key 是否安装
:echo exists('g:loaded_which_key')

" 手动触发
:WhichKey '<Leader>'
:WhichKey '<M-h>'
```
---

## 9. 使用技巧

### 9.1. 快速入门工作流

**1. 项目导航**
```vim
" 打开项目
vim .

" 使用快捷键
<Leader>ff      " 模糊搜索文件
<Leader>p       " Git 文件搜索
<C-b>           " 文件树状浏览器
<C-p>           " 文件浏览器
<C-f><CR>       " 全局搜索内容
```

**2. 代码编辑**
```vim
" 智能补全
<Tab>           " 触发补全
<CR>            " 确认选择

" 跳转定义
<C-g>           " LSP 跳转定义
<C-]>           " 侧栏跳转
<M-c>           " 预览定义

" 重命名
F2              " LSP 重命名
<C-q>           " 格式化代码
```

**3. 调试代码**
```vim
" 设置断点
<M-e><Space>    " 切换断点
F9              " 快捷切换

" 开始调试
<M-e>r          " 启动调试
F5              " 继续执行
F10/F11/F12     " 单步调试

" 查看变量
-               " Watch 变量
J               " 显示变量值
```

**4. Git 工作流**
```vim
" 查看状态
<M-g>s          " Git 状态
<M-g>b          " Git blame
<M-g>f          " 文件历史

" 提交代码
<M-g>a          " Git add -A
<M-g><CR>       " Git commit
<M-g>u          " Git push

" 可视化操作
<M-g><M-g>      " LazyGit
```

**5. REPL 交互**
```vim
" Python/R/Julia 等语言
<M-a><M-r>      " 启动 REPL (交互式选择)
<M-a>n          " 发送当前行 (光标下移)
<M-a><M-a>      " 发送代码块 (光标下移)
<M-a>a          " 发送整个文件
<M-a>q          " 退出 REPL
```

**6. Symbol/Tags 系统**

符号跳转采用多层 fallback 机制（见 `conf.d/main/plugin/tags.vim` 中 `tags#lsp_tag_search`）：

```
LSP (coc/nvim_lsp) → ctags/gtags → GrepAll
```

以 `<M-d>`（definition）和 `<M-/>`（references）为例：
1. 优先使用 LSP（coc `jumpDefinition` 或 nvim_lsp）
2. LSP 未找到且 ctags 可用时，fallback 到 ctags/gtags 查找
3. references 仍未找到时，最终 fallback 到 `GrepAll` 全局搜索

```vim
" 常用跳转键位
<C-g>           " 定义（当前窗口）
<C-]>           " 定义（垂直分屏）
<M-/>           " 引用（quickfix）
<M-d>           " 定义（quickfix）
<M-D>           " 声明（quickfix）
<M-?>           " 类型（quickfix）
<M-.>           " 实现（quickfix）
<C-h>           " 预览定义（需 ctags）

" 符号浏览
<leader>t       " Vista finder（LSP 符号）
t<CR>           " 当前缓冲区大纲
f<CR>           " 函数列表 (vim-funky)
<leader>g       " 调用gtags系统
```

### 9.2. 按语言配置

**Python 开发**

```vim
" ~/.leovim.d/after.vim
autocmd FileType python setlocal
    \ tabstop=4
    \ shiftwidth=4
    \ expandtab
    \ colorcolumn=88

" 安装 Python LSP
:CocInstall coc-pyright coc-python

" 配置 Python DAP (.vscode/launch.json)
{
  "configurations": [
    {
      "type": "python",
      "request": "launch",
      "name": "Python: Current File",
      "program": "${file}"
    }
  ]
}
```

**Go 开发**

```vim
" 安装 Go LSP
:CocInstall coc-go

" 快速运行
<M-R>           " 运行当前文件
<M-T>           " 运行测试

" 格式化
<C-q>           " 自动格式化和导入
```

**Rust 开发**

```vim
" 安装 Rust LSP
:CocInstall coc-rust-analyzer

" Cargo 命令
<M-R>           " cargo run
<M-B>           " cargo build
<M-T>           " cargo test

" 文档查看
<C-h>           " 查看文档
```

**Web 开发**

```vim
" 安装扩展
:CocInstall coc-tsserver coc-html coc-css coc-json

" 前端框架
:CocInstall coc-vetur      " Vue
:CocInstall coc-angular    " Angular

" 格式化
:CocInstall coc-prettier
```

### 9.3. 项目配置示例

**AsyncTasks 配置** (`~/.config/tasks.ini`)
```ini
[project-build]
command=npm run build
cwd=$(VIM_ROOT)
output=terminal
pos=bottom

[project-test]
command=npm test
cwd=$(VIM_ROOT)
output=quickfix

[project-run]
command=npm start
cwd=$(VIM_ROOT)
output=terminal
pos=right
```

**调试配置** (`.vscode/launch.json`)
```json
{
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Launch Program",
      "program": "${workspaceFolder}/index.js"
    },
    {
      "type": "python",
      "request": "launch",
      "name": "Python: Current File",
      "program": "${file}",
      "console": "integratedTerminal"
    }
  ]
}
```

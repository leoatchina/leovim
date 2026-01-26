# LeoVim

> 🎯 面向开发人员的 Vim/Neovim IDE 配置框架
> 开箱即用 · 功能完备 · 高度可定制 · 同时支持 Vim 和 Neovim

## ✨ 核心特性

### 🚀 开箱即用，零配置启动
- **一键安装** - 单条命令完成安装，无需手动配置插件
- **离线可用** - 内置 `pack` 基础包，无网络也能正常使用
- **智能降级** - 根据环境自动选择最佳配置（Vim/Neovim，GUI/终端）
- **预设模板** - 自动创建 `.gitignore`、`.lintr` 等常用配置文件

### 🤖 AI 增强体系 (双模驱动)
- **AI 智能补全 (Ghost Text)**
  - 专注于**代码生成**，实时预测
  - 引擎：Minuet-AI (DeepSeek/Gemini/OpenAI) / Copilot / Windsurf
  - 体验：打字时自动出现灰色建议，Tab 键采纳
- **AI 助手与 REPL (交互式)**
  - 专注于**代码理解与执行**
  - **核心机制**：基于同一底层插件 (`vim-floaterm-enhance`) 实现的统一交互体验
  - **REPL (`<M-i>`)**：将代码发送到解释器 (Python/R/Shell) 执行
  - **AI 助手 (`<M-e>`)**：将代码发送到 LLM 进行解释、重构或对话
  - **统一体验**：均使用浮动窗口，支持从 Buffer 发送选中代码、文件或目录

### 🎯 智能补全，多引擎支持
- **三层补全体系**
  - 基础：vim-mucomplete（dict + buffer + path）
  - 进阶：coc.nvim（Node.js LSP，插件生态丰富）
  - 高级：blink.cmp / nvim-cmp（原生 Neovim LSP，Rust 加速，性能极致）
- **代码片段** - VSCode 格式 snippets，支持自定义和共享
- **多语言支持** - 内置 Python, Go, Rust, C/C++, Java, JS/TS, R, Lua, LaTeX 等语言配置

### 🌲 Treesitter 语法感知
- **智能高亮** - 基于 AST 的精确语法高亮，支持数百种语言
- **对象操作** - `af`/`if` (函数), `ac`/`ic` (类) 基于语法树的文本对象选择
- **智能选择** - `sv` 智能扩展选择范围，`m` 智能节点跳转
- **上下文显示** - 滚动时在顶部固定显示当前函数/类签名 (Context)

### 🔍 强大搜索，三层查找机制
- **模糊搜索** - FZF/LeaderF 快速定位文件、buffer、命令
- **全局搜索** - ripgrep 高性能全文搜索，支持正则表达式
- **符号导航** - LSP → Ctags → 全局搜索，三层智能回退
- **搜索后替换** - 搜索结果直接按 `r` 进入批量替换模式
- **增量搜索** - Buffer 内实时搜索，支持多 buffer 联合搜索

### 🐛 完整调试体系
- **双调试器支持**
  - Vimspector：跨语言调试器，配置简单
  - nvim-dap：Neovim 原生 DAP 协议，扩展性强

### ⚡ 高性能设计
- **模块化加载** - 功能开关文件 `~/.vimrc.opt` 按需启用模块
- **延迟加载** - 插件按需加载(利用vim-plug 封装)
- **增量索引** - Ctags/Gtags 增量更新，大项目快速响应
- **异步执行** - 编译、测试、搜索均在后台异步运行

### 💾 会话管理
- **自动保存** - 退出时自动保存当前会话（窗口布局、Buffer、光标位置）
- **可视化管理** - `<Leader>ss` 调出 FZF 面板，快速搜索、加载、删除历史会话
- **启动页集成** - Startify 启动页显示最近使用的会话，一键恢复工作现场

### 🎨 现代 IDE 体验
- **丰富的 UI 组件**
  - 文件管理：Oil.nvim (像编辑 buffer 一样管理文件) / fern.vim
  - 导航栏：Dropbar.nvim (Winbar 面包屑导航)
  - 状态栏：lightline，实时显示 Git 分支、LSP 状态、文件信息
  - 标签栏：智能 buffer 管理，支持快速切换和关闭
  - 浮动窗口：终端、REPL、AI 助手均支持浮动窗口
- **WhichKey 提示系统** - 按下先导键自动显示所有可用命令
- **主题丰富** - 内置 Catppuccin, TokyoNight, Edge, Gruvbox 等多种配色


### 🔄 完整的 Git 工作流
- **版本控制集成**
  - fugitive：Vim 内 Git 操作，`:Git` 系列命令
  - LazyGit：TUI Git 客户端，可视化操作
  - Leaderf Git：模糊搜索 Git 历史、状态、blame
- **增强功能**
  - 行级 blame 显示
  - 文件历史对比
  - 交互式 rebase
  - Conflict marker 高亮和快速解决

### 🛠️ 任务与模板
- **全局任务库** - `tasks_common.ini` 内置通用任务
  - `git-push-master` / `git-checkout`
  - `net-host-ip` / `net-check-port`
  - `misc-weather` / `misc-system-info`
- **项目模板** - 自动识别并生成配置文件
  - `.gitignore`, `.gitconfig`
  - `.lintr` (R Linter), `.wildignore`
  - `Rprofile`, `radian_profile`

### 🌍 跨平台兼容
- **系统支持** - Linux、Windows、macOS 统一配置
- **Vim/Neovim 通用** - 同一配置同时支持 Vim  和 Neovim
- **VSCode Neovim** - `vscode-neovim` 模式专用配置与快捷键
- **终端/GUI 自适应** - 自动检测环境，优化键位映射和颜色显示
- **便携打包** - `compress.sh` 打包整个配置，一键迁移到新机器

### 🛠️ 高度可定制
- **功能开关** - `~/.vimrc.opt` 控制所有模块的启用/禁用
- **用户配置** - `~/.leovim.d/after.vim` 添加个人配置，不影响升级
- **自定义插件** - `~/.leovim.d/pack.vim` 添加额外插件
- **按文件类型定制** - 丰富的 ftplugin 配置，每种语言独立优化

---

## 📋 系统要求

**必需**
- Vim 7.4.399+ 或 Neovim 0.8+ (VSCode Neovim 推荐 0.10+)
- Git 1.8.5+

**可选（增强功能）**
- Node.js 20+ (LSP 支持)
- Python 3.8+ + neovim + pygments
- Universal Ctags 5.8+
- GNU Global 6.6.7+
- VSCode + `vscode-neovim` (仅 VSCode 模式需要)

## 🚀 快速安装

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

## 🧩 VSCode Neovim 快速开始

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

## 🎮 快速上手

### Leader 键说明
- `<Leader>` = `空格` (主导航键)
- `<LocalLeader>` = `q` (文件类型专用)
- `<M->` = `Alt` 键

### 🎯 核心先导键速查

按下以下先导键会进入对应的功能域：

| 先导键 | 功能域 | 说明 |
|--------|--------|------|
| `<Leader>` (空格) | **主功能菜单** | 文件、搜索、项目、Git 等主要操作 |
| `<M-h>` | **配置文件** | 快速打开配置文件和项目文件 |
| `<M-j>` | **跳转文件** | 打开文件（edit/tab/split/vsplit） |
| `<M-k>` | **功能开关** | 切换编辑器功能（主题、只读、命令等） |
| `<M-l>` | **LSP/行搜索** | LSP 操作 (CocInfo/LspInfo) + Buffer 行搜索 |
| `<M-r>` | **运行任务** | 编译、运行、构建等任务执行 |
| `<M-d>` | **调试器** | 断点、单步、变量查看等调试功能 |
| `<M-e>` | **AI 助手** | AI 代码辅助（发送代码、文件、目录到 AI） |
| `<M-i>` | **REPL 交互** | 代码发送到 REPL 环境执行 |
| `<M-g>` | **Git 操作** | 版本控制、提交、推送、历史查看 |
| `;` / `,` | **快速导航** | 前进/后退跳转（buffer、错误、符号等） |
| `[` / `]` | **成对移动** | 括号、函数、类等结构间移动 |
| `s` | **快速跳转** | Flash 跳转和文本对象操作 |
| `m` | **标记管理** | 设置/跳转/删除标记 (marks) |
| `\` | **窗口布局** | 窗口大小调整和布局切换 |
| `<Tab>` | **窗口控制** | 分屏、任务停止等窗口操作 |

> 💡 **提示**: 按下任意先导键后会自动弹出提示窗口，显示该功能域下的所有可用快捷键

### 重要修改的原生键位
| 键位 | 功能 | 原功能 |
|------|------|--------|
| `H/L` | 行首/行尾 | 屏幕顶/底 |
| `s` | 跳转/文本对象 | 替换字符 |
| `\|` | buffer 内搜索 | 列跳转 |
| `q` → `M` | 宏录制 | 宏录制 |
| `;` / `,` | 前进/后退导航 | 重复 f/t |

### 💡 快捷键提示系统

LeoVim 配置了 **WhichKey** 提示系统，按下任何先导键后会自动显示可用的子命令。例如：
- 按 `<M-h>` 会显示所有配置文件快捷键
- 按 `<M-d>` 会显示所有调试操作
- 按 `<Leader>` 会显示主菜单

**查看所有键位映射**：
```vim
:map          " 查看所有映射
:nmap         " 查看 normal 模式映射
:imap         " 查看 insert 模式映射
:vmap         " 查看 visual 模式映射
```

## 🎯 常用功能速查

### 📁 文件与项目 (`<Leader>` 空格键)
```
<Leader>e       文件浏览器
<Leader>ff      文件搜索
<Leader>p       Git 文件搜索
<Leader>w       保存所有
<Leader>Q       关闭 buffer
;b / ,b         切换 buffer
<M-n/p>         切换标签页
<M-1~9>         跳转到标签页 1-9
```

### 📂 快速打开配置 (`<M-h>`)
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

### 🔍 搜索与替换
```
s<CR>           全局搜索光标下词
|               Buffer 内搜索
<Leader>/       当前目录搜索
<Tab>/          Git 仓库搜索
<C-f><CR>       强力全局搜索
  → 按 r        搜索后替换
```

### 🎯 跳转与导航
```
# 文件跳转 (<M-j>)
<M-j>e          打开光标下文件
<M-j>t          新标签打开文件
<M-j>[          水平分割打开
<M-j>]          垂直分割打开

# Treesitter 智能选择
sv              Treesitter 智能扩展选择
m               Treesitter 节点跳转

# Flash 快速跳转 (s 系列)
ss              Flash 快速跳转

sl              跳转到任意行
sf/sF/st/sT     跳转到字符
<M-f/b>         下/上一个单词
<M-g>           跳转到行（插入模式）
```

### 🎯 会话管理 (`<Leader>s`)
```
<Leader>ss      FZF 会话列表 (搜索/加载/删除)
<Leader>st      打开 Startify 启动页
<Leader>sv      保存当前会话
<Leader>sl      加载会话
<Leader>sd      删除会话
<Leader>sc      关闭当前会话
```

### 🔧 LSP 与行搜索 (`<M-l>`)
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
<C-q>           格式化代码
F2              重命名符号
<C-t>           符号大纲侧边栏
```

### 🐛 调试功能 (`<M-d>` + F 键)
```
<M-d>r          启动调试
<M-d><CR>       继续执行
<M-d><Space>    切换断点
<M-d>;/,        下/上一个断点
<M-d>n/i/o      StepOver/Into/Out
<M-d>p          暂停
<M-d>q          停止调试
<M-d>c          清除所有断点
<M-d><M-d>      运行到光标

F5              开始/继续
F9              切换断点
F10/F11/F12     StepOver/Into/Out
-               Watch 变量
J               显示变量/诊断
```

### ▶️ 运行任务
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

### 🤖 AI 助手 (`<M-e>`)
```
<M-e>r          启动 AI 对话
<M-e>;          切换到 AI 窗口
<M-e><CR>       发送换行符
<M-e>l          发送当前行/选中区域
<M-e>f          发送当前文件
<M-e>d          发送当前目录
<M-e>i          FZF 选择文件发送
```
支持模型: DeepSeek, Gemini, OpenAI, Claude (通过 Minuet-AI) 及 Copilot, Windsurf
配置入口: `~/.vimrc.opt` (设置 `g:floaterm_ai_programs` 与 API Key/模型)

### 🔄 REPL 交互 (`<M-i>`)
```
<M-i>r          启动 REPL
<M-i>n          发送当前行
<M-i><M-e>      发送代码块 (# %%)
<M-i>a          发送整个文件
<M-i>b/e        发送到开头/结尾
<M-i>q          退出 REPL
<M-i>k          发送光标下的词
```
支持: Python, R, Shell, Lua, Ruby, Julia, JavaScript 等

### 🌿 Git 操作 (`<M-g>`)
```
<M-g>a          Git add -A
<M-g>u          Git push
<M-g><CR>       Git commit
<M-g>v          查看 Git 历史
<M-g>s          查看 Git 状态
<M-g>b          查看 Git blame
<M-g>f/l        当前文件/行的 Git 历史
<M-g>]/[        垂直/水平 diff
<M-g><M-g>      打开 LazyGit
```

### 🎛️ 功能开关 (`<M-k>`)
```
<M-k>Space      切换只读模式
<M-k>t          切换主题 (colorscheme)
<M-k>f          切换文件类型
<M-k><M-k>      命令列表
<M-k><M-f>      Fzf 命令搜索
<M-k><M-l>      Leaderf 自身命令
<M-k>m          显示消息历史
<M-z>           切换软换行
<Leader>o/O     切换诊断/诊断高亮
```

### 📋 诊断与错误
```
<Leader>d       诊断列表
;d / ,d         下/上一个诊断
;e / ,e         下/上一个错误
<Leader>o/O     切换诊断/高亮
```

### 📝 文本对象与编辑
```
af/if           函数外部/内部
ac/ic           类外部/内部
ik/ak           当前行
iv/av           代码块 (# %%)
<M-s>           智能扩展选择
;f/c / ,f/c     下/上一个函数/类
```

### 🪟 窗口与终端
```
# 窗口布局 (<Tab> + \)
<Tab>v/x        垂直/水平分割
\a/d/w/s        调整窗口大小
<M-HJKL>        窗口间跳转

# 标签页
<M-n/p>         下/上一个标签页
<M-1>~<M-9>     跳转到标签 1-9
<M-0>           最后一个标签
<M-w/W>         关闭当前/其他标签

# 浮动终端
<M-->           切换浮动终端
<M-=>           新建终端或列表
<M-+>           切换终端位置
```

### 📋 复制粘贴与外部联动
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


## 📚 配置文件说明

### 目录结构
```
~/.leovim/
├── conf.d/          # 主配置目录
│   ├── init.vim     # 入口文件
│   ├── init/        # 轻量/VSCode 配置与 keybindings.json
│   ├── main/        # 主配置 (plugin/lua/after)
│   ├── plug/        # 插件清单与分组
│   ├── snippets/    # 内置 snippets
│   ├── tasks/       # AsyncTasks 模板
│   ├── templates/   # .gitignore/.lintr/.wildignore 等模板
│   ├── dap/         # nvim-dap 配置
│   ├── vimspector/  # vimspector 配置
│   └── pack/leo/opt # 内置插件包
├── pack/            # 扩展包 (fork/clone)
├── scripts/         # 工具脚本
├── assets/          # 资源文件
└── fonts/           # 字体
```

### 自定义配置
- `~/.vimrc.opt` - 功能开关文件
- `~/.leovim.d/after.vim` - 用户自定义配置
- `~/.leovim.d/pack.vim` - 自定义插件列表
- `~/.leovim.d/ftplugin/` - 语言级局部配置

## ❓ 常见问题

### 安装相关

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

### 功能使用

**Q: 补全不工作？**
```vim
" 1. 检查 LSP 状态
:CocInfo        " 如果使用 coc.nvim
:LspInfo        " 如果使用 nvim-lsp

" 2. 安装语言服务器
:CocInstall coc-python coc-go coc-rust-analyzer

" 3. 检查 Node.js 版本
:!node --version    " 需要 20.0+
```

**Q: 如何切换补全引擎？**

编辑 `~/.vimrc.opt`，按 Vim/Neovim 取消注释对应行：
```vim
" Neovim
call pack#add('blink')   " blink.cmp
" call pack#add('cmp')   " nvim-cmp
" call pack#add('builtin')

" Vim
" call pack#add('coc')
" call pack#add('mcm')   " mucomplete
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

### 调试问题



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


### 性能优化



**Q: 大文件编辑卡顿？**

在 `~/.leovim.d/after.vim` 添加：
```vim
" 大文件自动禁用重功能
autocmd BufReadPre * if getfsize(expand("%")) > 1000000 |
    \ setlocal syntax=off |
    \ setlocal noswapfile |
    \ endif
```




**Q: LSP 占用内存过高？**

```vim
" 限制 LSP 工作空间
let g:coc_workspace_folder_blacklist = ['node_modules', 'target']

" 禁用部分诊断功能
let g:coc_diagnostic_disable = 1
```


### 更新维护



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


### 高级技巧



**Q: 如何添加自定义语言支持？**

1. 安装 LSP server：`:CocInstall coc-xxx`
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

## 💡 使用技巧

### 快速入门工作流

**1. 项目导航**
```vim
" 打开项目
vim .

" 使用快捷键
<Leader>ff      " 模糊搜索文件
<Leader>p       " Git 文件搜索
<Leader>e       " 文件浏览器
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
<M-d><Space>    " 切换断点
F9              " 快捷切换

" 开始调试
<M-d>r          " 启动调试
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
<M-i>r          " 启动 REPL
<M-i>n          " 发送当前行
<M-i><M-e>      " 发送代码块
<M-i>a          " 发送整个文件
```

### 按语言配置



**Python 开发**

```vim
" ~/.leovim.d/after.vim
" Python 特定配置
autocmd FileType python setlocal
    \ tabstop=4
    \ shiftwidth=4
    \ expandtab
    \ colorcolumn=88

" 安装 Python LSP
:CocInstall coc-pyright coc-python

" 配置 Python DAP
" 创建 .vscode/launch.json
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

" 安装 Go 工具
:GoInstallBinaries

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

" 自动保存并格式化
autocmd BufWritePre *.js,*.jsx,*.ts,*.tsx :silent! CocCommand prettier.formatFile
```


### 性能优化建议

**1. 减少启动时间**
```vim
" ~/.leovim.d/after.vim
" 延迟加载重量级插件
let g:coc_start_at_startup = 0
augroup load_coc
  autocmd!
  autocmd InsertEnter * call coc#rpc#start_server() | autocmd! load_coc
augroup END
```

**2. 大项目优化**
```vim
" 限制 LSP 扫描范围
let g:coc_global_extensions_blacklist = ['node_modules']

" 禁用实时诊断
let g:coc_diagnostic_enable = 0

" 手动触发诊断
nnoremap <Leader>d :CocDiagnostics<CR>
```

**3. 内存优化**
```vim
" 限制历史记录
set history=100
set undolevels=100

" 限制 buffer 数量
set hidden
set switchbuf=useopen,usetab
```

### 项目配置示例

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

## 🎓 进阶指南

### 自定义快捷键

```vim
" ~/.leovim.d/after.vim

" 自定义保存
nnoremap <Leader>w :w<CR>

" 快速编辑配置
nnoremap <Leader>ve :edit ~/.leovim.d/after.vim<CR>
nnoremap <Leader>vs :source ~/.vimrc<CR>

" 自定义搜索
nnoremap <Leader>/ :Rg<Space>

" 窗口导航
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
```

### 自定义命令

```vim
" 快速运行当前文件
command! Run !./%

" 打开当前文件所在目录
command! OpenDir :!open %:p:h

" 删除行尾空格
command! TrimWhitespace :%s/\s\+$//e

" 转换为 Unix 换行符
command! ToUnix :set ff=unix
```

### 集成外部工具

```vim
" 集成 ripgrep
if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

" 集成 fd
if executable('fd')
  let $FZF_DEFAULT_COMMAND = 'fd --type f'
endif

" 集成 bat (语法高亮预览)
let $FZF_PREVIEW_COMMAND = 'bat --color=always --style=numbers {}'
```

## 🤝 参与贡献

欢迎提交 Issue 和 Pull Request！

### 报告问题
- 使用 Issue 模板
- 提供详细的复现步骤
- 附上 `:version` 和 `:checkhealth` 输出

### 贡献代码
1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/xxx`
3. 提交改动：`git commit -am 'Add xxx'`
4. 推送分支：`git push origin feature/xxx`
5. 提交 Pull Request

## 🔗 相关资源

- [Vim 官方文档](https://www.vim.org/docs.php)
- [Neovim 文档](https://neovim.io/doc/)
- [coc.nvim Wiki](https://github.com/neoclide/coc.nvim/wiki)
- [Awesome Vim](https://github.com/akrawchyk/awesome-vim)

## 📄 许可证
MIT License
---
**最后更新**: 2026-01
**维护者**: leoatchina

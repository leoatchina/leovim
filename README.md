# LeoVim

> 🎯 面向开发人员的 Vim/Neovim IDE 配置框架
> 开箱即用 · 功能完备 · 高度可定制 · 同时支持 Vim 和 Neovim

## ✨ 核心特性

### 🚀 开箱即用，零配置启动
- **一键安装** - 单条命令完成安装，无需手动配置插件
- **离线可用** - 内置 `pack` 基础包，无网络也能正常使用
- **智能降级** - 根据环境自动选择最佳配置（Vim/Neovim，GUI/终端）
- **预设模板** - 自动创建 `.gitignore`、`.lintr` 等常用配置文件

### 🎯 智能补全，多引擎支持
- **三层补全体系**
  - 基础：vim-mucomplete（dict + buffer + path）
  - 进阶：coc.nvim（Node.js LSP，插件生态丰富）
  - 高级：nvim-cmp（原生 Neovim LSP，性能最优）
- **AI 代码助手** - 集成 Codeium/Copilot，智能代码生成
- **代码片段** - VSCode 格式 snippets，支持自定义和共享
- **多语言支持** - 内置 Python、Go、Rust、C/C++、Java、JavaScript 等语言配置

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
- **REPL 即时执行** - Python、R、Julia、Shell 等语言的交互式执行
- **代码块发送** - 支持 `# %%` 标记的代码块发送到 REPL
- **AI 辅助调试** - 发送代码到 AI 助手进行分析和优化

### ⚡ 高性能设计
- **模块化加载** - 功能开关文件 `~/.vimrc.opt` 按需启用模块
- **延迟加载** - 插件按需加载，启动速度 < 100ms
- **增量索引** - Ctags/Gtags 增量更新，大项目快速响应
- **异步执行** - 编译、测试、搜索均在后台异步运行

### 🎨 现代 IDE 体验
- **丰富的 UI 组件**
  - 文件树：coc-explorer/nvim-tree，支持 Git 状态显示
  - 状态栏：lightline，实时显示 Git 分支、LSP 状态、文件信息
  - 标签栏：智能 buffer 管理，支持快速切换和关闭
  - 浮动窗口：终端、REPL、AI 助手均支持浮动窗口
- **WhichKey 提示系统** - 按下先导键自动显示所有可用命令
- **主题丰富** - 内置多种配色方案，支持 Fzf 快速切换

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

### 🌍 跨平台兼容
- **系统支持** - Linux、Windows、macOS 统一配置
- **Vim/Neovim 通用** - 同一配置同时支持 Vim 7.4+ 和 Neovim 0.7+
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
- Vim 7.4+ 或 Neovim 0.7.2+
- Git 1.8.5+

**可选（增强功能）**
- Node.js 20+ (LSP 支持)
- Python 3.8+ + neovim + pygments
- Universal Ctags 5.8+
- GNU Global 6.6.7+

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
<M-h>p/d/l      plugin/conf.d/leovim 目录
<M-h>A/P        after.vim/pack.vim
<M-h>n          snippets
<M-h>s/f        snippets 目录

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

# Flash 快速跳转 (s 系列)
ss              Flash 快速跳转
sl              跳转到任意行
sf/sF/st/sT     跳转到字符
<M-f/b>         下/上一个单词
<M-g>           跳转到行（插入模式）
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

### 📋 复制粘贴与标记
```
# 复制粘贴
<M-v>           寄存器选择器
<Leader>yp/yf   复制路径/文件名
<Leader>ym      复制位置 (文件:行:列)
\pw             粘贴到光标下词

# 标记 (m 先导键)
m<CR>           切换标记
m;              下一个标记
m/              列出 buffer 标记
dm              删除标记
;m / ,m         下/上一个标记 (按字母)
]m / [m         下/上一个标记 (按位置)
<Leader>M       Fzf 标记列表
```

## 📚 配置文件说明

### 目录结构
```
~/.leovim/
├── conf.d/          # 主配置目录
│   ├── init.vim     # 入口文件
│   ├── cfg/         # 核心配置
│   ├── lua/         # Lua 配置
│   ├── plugin/      # 插件配置
│   └── dap/         # 调试配置
├── pack/            # 基础包
└── scripts/         # 工具脚本
```

### 自定义配置
- `~/.vimrc.opt` - 功能开关文件
- `~/.leovim.d/after.vim` - 用户自定义配置
- `~/.leovim.d/pack.vim` - 自定义插件列表

## ❓ 常见问题

**如何禁用某个功能？**
编辑 `~/.vimrc.opt` 文件，注释掉对应的功能行

**补全不工作？**
确保已安装 Node.js 和对应的 LSP server

**如何更新插件？**
在 Vim 中执行 `:PlugUpdate`

**如何添加自定义配置？**
在 `~/.leovim.d/after.vim` 中添加你的配置

## 📄 许可证
MIT License
---
**最后更新**: 2026-01
**维护者**: leoatchina 

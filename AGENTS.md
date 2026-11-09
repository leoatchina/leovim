# 规则
- conf.d/init.vim是通用入口
- conf.d/main/autoload/plug.vim 是vim-plug的插件管理器，pack.vim和pack.lua是基于这个文件的增强 ，plug.vim不得修改
- conf.d/main/after/cfg 里是vim单项配置，conf.d/main/plugin里的配置能使用里面的内容，不能反过来
- 在vim脚本里除非能一行写入lua 命令，不要写lua 嵌入脚本
- 任何侧边栏打开 ，除非明确要求设计，默认不focus过去
- lua插件的 "init" 只能写一行，不能出现";", 而且要简单,复杂的用cfg配置

# 调试模板

## 目录
- `conf.d/vimspector/` 是 **Vimspector 模板库**。目录中的 JSON 文件按 Vimspector 项目配置格式编写，顶层必须包含 `configurations`，通常可以将一个模板文件整体复制为项目根目录的 `.vimspector.json`。
- `conf.d/dap/` 是 **nvim-dap 模板库**。目录中的 JSON 文件只表示 `configurations` 数组中的一个配置对象，不能直接当作完整的 `.vim/dap.json`；使用时应把对象合并到项目配置的 `configurations` 数组中。
- 两个目录都是模板，不是运行时配置入口。Vimspector 和 nvim-dap 的插件开关、按键、加载逻辑分别维护在 `conf.d/main/cfg/vimspector.vim`、`conf.d/main/cfg/dap.vim` 和 `conf.d/main/plugin/debug.vim`。

## 禁止混配

- 不要把 `conf.d/vimspector/` 的完整配置格式直接放进 `conf.d/dap/`，也不要把 `conf.d/dap/` 的单个对象直接当作 `.vimspector.json`。
- 不要在模板 JSON 中写 Vimscript、Lua、按键映射或插件加载逻辑；这些内容应放到对应的 `cfg` 或 `plugin` 文件。
- 不要把两个调试器的适配器字段、变量名和项目文件格式混用。修改前先确认目标是 Vimspector 还是 nvim-dap。

## 模板要求

- 文件名使用 `<语言>_<场景>.json`，例如 `go_file.json`、`python_module.json`；一个文件只描述一个清晰的调试场景。
- 优先使用 `${file}`、`${fileDirname}`、`${workspaceFolder}` 等变量，避免提交个人机器的绝对路径、用户名、端口和密钥。确需机器相关路径时，应有明确注释或改为项目级配置。
- 保留适配器所需的最小字段，并保持已有字段命名和缩进风格；新增配置时不要顺手重排其他模板。
- Vimspector 模板必须保持完整的 `configurations` 结构；nvim-dap 模板必须保持单个配置对象结构。不要为了“看起来统一”改成同一种格式。
- 修改后至少校验 JSON 格式，并确认对应的调试适配器已安装：Vimspector 使用 `:VimspectorInstall`，nvim-dap 通常使用 Mason 安装适配器。
- 模板只提供可复制的起点，不会自动合并到项目配置；使用者仍需按项目目录、启动参数和适配器实际情况调整。

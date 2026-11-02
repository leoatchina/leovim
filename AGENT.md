# 规则
- conf.d/init.vim是通用入口
- conf.d/main/autoload/plug.vim 是vim-plug的插件管理器，pack.vim和pack.lua是基于这个文件的增强 ，plug.vim不得修改
- conf.d/main/after/cfg 里是vim单项配置，conf.d/main/plugin里的配置能使用里面的内容，不能反过来
- 在vim脚本里除非能一行写入lua 命令，不要写lua 嵌入脚本
- 任何侧边栏打开 ，除非明确要求设计，默认不focus过去
- lua插件的 "init" 只能写一行，不能出现";", 而且要简单,复杂的用cfg配置

vim.o.omnifunc = 'syntaxcomplete#Complete'  -- 启用语法补全引擎
-- 增强 omni-completion 的显示
vim.api.nvim_set_hl(0, 'Pmenu', {bg = '#3b4252', fg = '#d8dee9'})
vim.api.nvim_set_hl(0, 'PmenuSel', {bg = '#81a1c1', fg = '#2e3440', bold = true})
-- 配置 omni 补全自动触发
vim.api.nvim_create_autocmd('InsertCharPre', {
  pattern = '*',
  callback = function()
    -- 定义触发补全的字符集（可根据需要修改）
    local trigger_chars = { '.', ':', '>', '<', '(', '[', '{', ',', '=', '~' }
    -- 获取当前输入的字符
    local char = vim.v.char
    -- 检查是否需要触发补全
    for _, trigger in ipairs(trigger_chars) do
      if char == trigger then
        vim.schedule(function()
          -- 确保不在补全菜单已显示时重复触发
          if vim.fn.pumvisible() == 0 then
            vim.api.nvim_feedkeys(
              vim.api.nvim_replace_termcodes('<C-X><C-O>', true, true, true),
              'n',
              false
            )
          end
        end)
        break
      end
    end
  end
})

-- 为不同文件类型设置 omnifunc
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python', 'lua', 'javascript', 'typescript', 'cpp', 'c' },
  callback = function(args)
    -- 获取当前文件类型
    local ft = vim.bo[args.buf].filetype
    -- 设置对应文件类型的 omnifunc
    local omni_funcs = {
      python = 'pythoncomplete#Complete',
      lua = 'luaomnifunc',
      javascript = 'javascriptcomplete#CompleteJS',
      typescript = 'typescriptcomplete#Complete',
      cpp = 'cppcomplete#Complete',
      c = 'ccomplete#Complete'
    }
    if omni_funcs[ft] then
      if ft == 'python' and vim.g.python_version > 0 then
        vim.bo.omnifunc = omni_funcs[ft]
      else
        vim.bo.omnifunc = omni_funcs[ft]
      end
    else
      -- 默认使用语法补全
      vim.bo.omnifunc = 'syntaxcomplete#Complete'
    end
  end
})

-- 在 insert 模式添加以下映射
vim.keymap.set('i', '<Down>', '<C-n>', {noremap = true})  -- 下一个选项
vim.keymap.set('i', '<Up>', '<C-p>', {noremap = true})    -- 上一个选项
vim.keymap.set('i', '<C-y>', '<C-y>', {noremap = true})   -- 确认选择
vim.keymap.set('i', '<C-e>', '<C-e>', {noremap = true})   -- 关闭菜单

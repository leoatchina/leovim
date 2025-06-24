-- 增强 omni-completion 的显示
vim.api.nvim_set_hl(0, 'Pmenu', {bg = '#3b4252', fg = '#d8dee9'})
vim.api.nvim_set_hl(0, 'PmenuSel', {bg = '#81a1c1', fg = '#2e3440', bold = true})
-- 配置 omni 补全自动触发
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    -- 文件类型特定的触发字符
    local ft_triggers = {
      lua = { '.', ':', },
      python = { '.', ':', },
      javascript = { '.', ':', },
      typescript = { '.', ':', },
      cpp = { '.', '::', '->', },
      c = { '.', '->', },
      html = { '<', '/', '>', ' ', },
      css = { ':', ';', ' ', },
      vim = { ':', },
      java = { '.', ':', },
      -- 默认触发字符
      default = { '.', ':', '>' },
    }
    -- 获取为当前文件类型设置的触发字符
    local triggers = ft_triggers[ft] or ft_triggers.default
    -- 创建插入模式触发自动命令
    vim.api.nvim_create_autocmd('InsertCharPre', {
      buffer = args.buf,
      callback = function()
        local char = vim.v.char
        -- 检查当前输入是否是触发字符
        for _, trigger in ipairs(triggers) do
          if char == trigger then
            -- 使用延时来确保字符先被插入
            vim.defer_fn(function()
              -- 确保不在补全菜单已显示时重复触发
              if vim.fn.pumvisible() == 0 and vim.fn.mode() == 'i' then
                -- 获取光标前的文本
                local line = vim.api.nvim_get_current_line()
                local col = vim.api.nvim_win_get_cursor(0)[2]
                -- 只在有字符的情况下触发补全
                if col > 0 then
                  vim.api.nvim_feedkeys(
                    vim.api.nvim_replace_termcodes('<C-X><C-O>', true, true, true),
                    'n',
                    false
                  )
                end
              end
            end, 50) -- 短暂停确保字符先被插入
            break
          end
        end
      end
    })
  end
})
-- 为不同文件类型设置 omnifunc
vim.api.nvim_create_autocmd('FileType', {
  pattern = {"*"},
  callback = function(args)
    -- 获取当前文件类型
    local ft = vim.bo[args.buf].filetype
    -- 设置对应文件类型的 omnifunc
    local omni_funcs = {
      python = vim.fn.has('python3') == 1 and 'python3complete#Complete' or 'syntaxcomplete#Complete',
      lua = 'v:lua.vim.lsp.omnifunc',
      javascript = 'javascriptcomplete#CompleteJS',
      typescript = 'javascriptcomplete#CompleteJS',
      cpp = 'ccomplete#Complete',
      c = 'ccomplete#Complete',
      vim = 'vimcomplete#Complete',
      html = 'htmlcomplete#CompleteTags',
      css = 'csscomplete#CompleteCSS',
      java = 'javacomplete#Complete',
    }
    -- 设置 omnifunc
    if omni_funcs[ft] then
      vim.bo[args.buf].omnifunc = omni_funcs[ft]
    else
      -- XXX, 下面是正确的，默认使用语法补全
      vim.bo[args.buf].omnifunc = 'syntaxcomplete#Complete'
    end
  end
})

-- 在 insert 模式添加以下映射
vim.keymap.set('i', '<Down>', '<C-n>', {noremap = true})  -- 下一个选项
vim.keymap.set('i', '<Up>', '<C-p>', {noremap = true})    -- 上一个选项
vim.keymap.set('i', '<C-y>', '<C-y>', {noremap = true})   -- 确认选择
vim.keymap.set('i', '<C-e>', '<C-e>', {noremap = true})   -- 关闭菜单

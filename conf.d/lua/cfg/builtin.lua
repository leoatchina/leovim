-- Neovim 0.11 内置补全 + friendly snippets 配置

-- 局部变量定义
local map = vim.keymap.set



-- 补全菜单样式
vim.api.nvim_set_hl(0, 'Pmenu', {bg = '#3b4252', fg = '#d8dee9'})
vim.api.nvim_set_hl(0, 'PmenuSel', {bg = '#81a1c1', fg = '#2e3440', bold = true})
vim.api.nvim_set_hl(0, 'PmenuKind', {bg = '#3b4252', fg = '#88c0d0'})
vim.api.nvim_set_hl(0, 'PmenuKindSel', {bg = '#81a1c1', fg = '#2e3440', bold = true})
vim.api.nvim_set_hl(0, 'PmenuExtra', {bg = '#3b4252', fg = '#8fbcbb'})
vim.api.nvim_set_hl(0, 'PmenuExtraSel', {bg = '#81a1c1', fg = '#2e3440'})

-- 解析 VSCode 格式的 snippet
local function parse_vscode_snippets(file_path)
  local snippets = {}
  local file = io.open(file_path, 'r')
  if not file then
    return snippets
  end
  
  local content = file:read('*all')
  file:close()
  
  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    return snippets
  end
  
  for name, snippet in pairs(data) do
    if type(snippet) == 'table' and snippet.prefix and snippet.body then
      local body = type(snippet.body) == 'table' and table.concat(snippet.body, '\n') or snippet.body
      local description = snippet.description or name
      
      table.insert(snippets, {
        word = snippet.prefix,
        abbr = snippet.prefix,
        menu = '[Snippet] ' .. description,
        kind = 'Snippet',
        info = body,
        user_data = {
          snippet = true,
          body = body
        }
      })
    end
  end
  
  return snippets
end

-- 全局 snippet 缓存
local snippet_cache = {}

-- 加载文件类型对应的 snippets
local function load_snippets_for_filetype(filetype)
  if snippet_cache[filetype] then
    return snippet_cache[filetype]
  end
  
  local snippets = {}
  local snippets_base_dir = vim.fn.expand('$HOME/.leovim.d/pack/add/opt/friendly-snippets/snippets')
  
  -- 检查 snippets 目录是否存在
  if vim.fn.isdirectory(snippets_base_dir) == 0 then
    snippet_cache[filetype] = {}
    return {}
  end
  
  local snippet_files = {}
  
  -- 查找全局 snippets
  local global_file = snippets_base_dir .. '/global.json'
  if vim.fn.filereadable(global_file) == 1 then
    table.insert(snippet_files, global_file)
  end
  
  -- 查找文件类型特定的 snippets - 优先检查子目录
  local ft_dir = snippets_base_dir .. '/' .. filetype
  if vim.fn.isdirectory(ft_dir) == 1 then
    -- 有子目录，加载所有 json 文件
    local ft_dir_files = vim.fn.glob(ft_dir .. '/*.json', true, true)
    vim.list_extend(snippet_files, ft_dir_files)
  else
    -- 没有子目录，检查直接的 json 文件
    local ft_file = snippets_base_dir .. '/' .. filetype .. '.json'
    if vim.fn.filereadable(ft_file) == 1 then
      table.insert(snippet_files, ft_file)
    end
  end
  
  -- 加载语言别名的 snippets
  local aliases = {
    cpp = {'c'},
    typescript = {'javascript'},
    javascript = {'html'},
  }
  
  if aliases[filetype] then
    for _, alias in ipairs(aliases[filetype]) do
      local alias_file = snippets_base_dir .. '/' .. alias .. '.json'
      if vim.fn.filereadable(alias_file) == 1 then
        table.insert(snippet_files, alias_file)
      end
      
      -- 检查别名的子目录
      local alias_dir = snippets_base_dir .. '/' .. alias
      if vim.fn.isdirectory(alias_dir) == 1 then
        local alias_dir_files = vim.fn.glob(alias_dir .. '/*.json', true, true)
        vim.list_extend(snippet_files, alias_dir_files)
      end
    end
  end
  
  -- 解析所有找到的 snippet 文件
  for _, file_path in ipairs(snippet_files) do
    local file_snippets = parse_vscode_snippets(file_path)
    vim.list_extend(snippets, file_snippets)
  end
  
  snippet_cache[filetype] = snippets
  return snippets
end

-- 自定义补全函数，包含 snippets
function _G.builtin_complete_with_snippets()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local prefix = line:sub(1, col):match('[%w_]*$') or ''
  
  if #prefix == 0 then
    return ''
  end
  
  local filetype = vim.bo.filetype
  local snippets = load_snippets_for_filetype(filetype)
  
  -- 过滤匹配的 snippets
  local matches = {}
  for _, snippet in ipairs(snippets) do
    if snippet.word:lower():find(prefix:lower(), 1, true) == 1 then
      table.insert(matches, snippet)
    end
  end
  
  if #matches > 0 then
    local start_col = col - #prefix + 1
    vim.fn.complete(start_col, matches)
  end
  
  return ''
end

-- 添加调试命令
vim.api.nvim_create_user_command('DebugSnippets', function()
  local filetype = vim.bo.filetype
  local snippets = load_snippets_for_filetype(filetype)
  print(filetype .. ": " .. #snippets .. " snippets, mode: " .. (snippet_mode_active and "on" or "off"))
end, {})

-- 添加清空 snippet 状态的命令
vim.api.nvim_create_user_command('ClearSnippet', function()
  current_snippet_placeholders = {}
  current_placeholder_index = 0
  snippet_mode_active = false
end, {})

-- 全局变量存储当前 snippet 状态
local current_snippet_placeholders = {}
local current_placeholder_index = 0
local snippet_mode_active = false

-- 展开 snippet
local function expand_snippet()
  local item = vim.v.completed_item
  if not item or vim.tbl_isempty(item) then
    return false
  end
  
  -- 检查是否是 snippet 项目
  if not item.user_data or not item.user_data.snippet then
    return false
  end
  
  local body = item.user_data.body
  if not body then
    return false
  end
  
  -- 获取当前位置信息
  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local prefix_len = #item.word
  
  -- 处理 snippet 变量和占位符
  local processed_body = body
  local placeholders = {}
  
  -- 处理 ${n:default} 格式的占位符
  processed_body = processed_body:gsub('%$%{(%d+):([^}]*)%}', function(num, default)
    local placeholder_num = tonumber(num)
    placeholders[placeholder_num] = {
      text = default
    }
    return default
  end)
  
  -- 处理简单 $n 格式的占位符
  processed_body = processed_body:gsub('%$(%d+)', function(num)
    local placeholder_num = tonumber(num)
    if placeholder_num == 0 then
      -- $0 是最终光标位置
      placeholders[0] = {text = ''}
      return ''
    else
      if not placeholders[placeholder_num] then
        placeholders[placeholder_num] = {text = ''}
      end
      return placeholders[placeholder_num].text
    end
  end)
  
  -- 分割成多行
  local lines = vim.split(processed_body, '\n', {plain = true})
  
  -- 获取当前行的前缀和后缀
  local before = line:sub(1, col - prefix_len)
  local after = line:sub(col + 1)
  
  -- 构建新的行内容
  local new_lines = {}
  for i, snippet_line in ipairs(lines) do
    if i == 1 then
      -- 第一行：前缀 + snippet行
      table.insert(new_lines, before .. snippet_line)
    elseif i == #lines then
      -- 最后一行：snippet行 + 后缀
      table.insert(new_lines, snippet_line .. after)
    else
      -- 中间行：直接插入
      table.insert(new_lines, snippet_line)
    end
  end
  
  -- 删除当前行
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, new_lines)
  
  -- 查找第一个占位符位置
  local first_placeholder_pos = nil
  for line_idx, line_content in ipairs(new_lines) do
    for placeholder_num = 1, 10 do  -- 查找 1-10 的占位符
      if placeholders[placeholder_num] and placeholders[placeholder_num].text ~= '' then
        local start_pos = line_content:find(placeholders[placeholder_num].text, 1, true)
        if start_pos then
          first_placeholder_pos = {
            row = row - 1 + line_idx - 1,
            col_start = start_pos - 1,
            col_end = start_pos + #placeholders[placeholder_num].text - 1,
            text = placeholders[placeholder_num].text
          }
          break
        end
      end
    end
    if first_placeholder_pos then break end
  end
  
  if first_placeholder_pos then
    -- 跳转到第一个占位符并选中
    vim.api.nvim_win_set_cursor(0, {first_placeholder_pos.row + 1, first_placeholder_pos.col_start})
    
    -- 在 visual 模式下选中占位符文本
    vim.defer_fn(function()
      -- 安全地进入 visual 模式并选中占位符
      local mode = vim.fn.mode()
      if mode == 'i' then
        -- 如果在插入模式，先退出到普通模式
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, true, true), 'n', false)
        vim.defer_fn(function()
          pcall(function()
            vim.api.nvim_win_set_cursor(0, {first_placeholder_pos.row + 1, first_placeholder_pos.col_start})
            vim.cmd('normal! v')
            vim.api.nvim_win_set_cursor(0, {first_placeholder_pos.row + 1, first_placeholder_pos.col_end})
            -- 延迟进入插入模式
            vim.defer_fn(function()
              vim.cmd('startinsert')
            end, 50)
          end)
        end, 20)
      else
        pcall(function()
          vim.cmd('normal! v')
          vim.api.nvim_win_set_cursor(0, {first_placeholder_pos.row + 1, first_placeholder_pos.col_end})
          -- 延迟进入插入模式
          vim.defer_fn(function()
            vim.cmd('startinsert')
          end, 50)
        end)
      end
    end, 10)
  else
    -- 没有占位符，设置光标到末尾
    local final_row = row - 1 + #new_lines - 1
    local final_col = #new_lines[#new_lines] - #after
    vim.api.nvim_win_set_cursor(0, {final_row + 1, final_col})
  end
  
  -- 存储占位符信息供后续跳转使用
  current_snippet_placeholders = placeholders
  current_placeholder_index = 1
  snippet_mode_active = true  -- 激活 snippet 模式
  
  return true
end

-- 跳转到下一个占位符
local function jump_to_next_placeholder()
  if vim.tbl_isempty(current_snippet_placeholders) then
    return false
  end
  
  current_placeholder_index = current_placeholder_index + 1
  
  -- 查找下一个占位符
  for i = current_placeholder_index, 10 do
    if current_snippet_placeholders[i] and current_snippet_placeholders[i].text ~= '' then
      -- 在当前缓冲区中查找这个占位符
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      for row, line in ipairs(lines) do
        local start_pos = line:find(current_snippet_placeholders[i].text, 1, true)
        if start_pos then
          -- 安全地选中占位符文本
          vim.api.nvim_win_set_cursor(0, {row, start_pos - 1})
          local end_col = start_pos + #current_snippet_placeholders[i].text - 1
          
          -- 使用 vim.defer_fn 和错误处理来安全地进入 visual 模式
          vim.defer_fn(function()
            -- 检查当前模式是否适合进入 visual 模式
            local mode = vim.fn.mode()
            if mode == 'i' then
              -- 如果在插入模式，先退出到普通模式
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, true, true), 'n', false)
              vim.defer_fn(function()
                pcall(function()
                  vim.api.nvim_win_set_cursor(0, {row, start_pos - 1})
                  vim.cmd('normal! v')
                  vim.api.nvim_win_set_cursor(0, {row, end_col})
                  -- 延迟进入插入模式
                  vim.defer_fn(function()
                    vim.cmd('startinsert')
                  end, 50)
                end)
              end, 20)
            else
              pcall(function()
                vim.cmd('normal! v')
                vim.api.nvim_win_set_cursor(0, {row, end_col})
                -- 延迟进入插入模式
                vim.defer_fn(function()
                  vim.cmd('startinsert')
                end, 50)
              end)
            end
          end, 10)
          current_placeholder_index = i
          return true
        end
      end
    end
  end
  
  -- 没有更多占位符，清空状态并退出 snippet 模式
  current_snippet_placeholders = {}
  current_placeholder_index = 0
  snippet_mode_active = false
  return false
end

-- 跳转到上一个占位符
local function jump_to_prev_placeholder()
  if vim.tbl_isempty(current_snippet_placeholders) then
    return false
  end
  
  current_placeholder_index = current_placeholder_index - 1
  
  -- 查找上一个占位符
  for i = current_placeholder_index, 1, -1 do
    if current_snippet_placeholders[i] and current_snippet_placeholders[i].text ~= '' then
      -- 在当前缓冲区中查找这个占位符
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      for row, line in ipairs(lines) do
        local start_pos = line:find(current_snippet_placeholders[i].text, 1, true)
        if start_pos then
          -- 安全地选中占位符文本
          vim.api.nvim_win_set_cursor(0, {row, start_pos - 1})
          local end_col = start_pos + #current_snippet_placeholders[i].text - 1
          
          -- 使用 vim.defer_fn 和错误处理来安全地进入 visual 模式
          vim.defer_fn(function()
            -- 检查当前模式是否适合进入 visual 模式
            local mode = vim.fn.mode()
            if mode == 'i' then
              -- 如果在插入模式，先退出到普通模式
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, true, true), 'n', false)
              vim.defer_fn(function()
                pcall(function()
                  vim.api.nvim_win_set_cursor(0, {row, start_pos - 1})
                  vim.cmd('normal! v')
                  vim.api.nvim_win_set_cursor(0, {row, end_col})
                  -- 延迟进入插入模式
                  vim.defer_fn(function()
                    vim.cmd('startinsert')
                  end, 50)
                end)
              end, 20)
            else
              pcall(function()
                vim.cmd('normal! v')
                vim.api.nvim_win_set_cursor(0, {row, end_col})
                -- 延迟进入插入模式
                vim.defer_fn(function()
                  vim.cmd('startinsert')
                end, 50)
              end)
            end
          end, 10)
          current_placeholder_index = i
          return true
        end
      end
    end
  end
  
  -- 如果没有找到上一个，设置为0，下次跳转会重新开始
  if current_placeholder_index < 1 then
    current_placeholder_index = 0
  end
  return false
end

-- 为不同文件类型设置 omnifunc
vim.api.nvim_create_autocmd('FileType', {
  pattern = {"*"},
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local omni_funcs = {
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
    
    -- Python 特殊处理：检查是否有 python3 支持
    if ft == 'python' then
      if vim.fn.has('python3') == 1 then
        vim.bo[args.buf].omnifunc = 'python3complete#Complete'
      else
        -- 如果没有 python3 支持，使用语法补全或 LSP
        if vim.lsp.get_clients({bufnr = args.buf})[1] then
          vim.bo[args.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
        else
          vim.bo[args.buf].omnifunc = 'syntaxcomplete#Complete'
        end
      end
    elseif omni_funcs[ft] then
      vim.bo[args.buf].omnifunc = omni_funcs[ft]
    else
      vim.bo[args.buf].omnifunc = 'syntaxcomplete#Complete'
    end
    
    -- 预加载该文件类型的 snippets
    load_snippets_for_filetype(ft)
  end
})

-- Tab 键：只用于补全和 snippet 展开
map('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    -- 菜单可见，先选择第一个项目再确认（这样会触发 completed_item）
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-n><C-y>', true, true, true), 'n', false)
    -- 延迟一点时间来展开 snippet
    vim.defer_fn(function()
      expand_snippet()
    end, 10)
    return ''
  else
    -- 菜单不可见，正常 Tab 行为
    return vim.api.nvim_replace_termcodes('<Tab>', true, true, true)
  end
end, {expr = true, silent = true})

-- Shift-Tab 只用于补全菜单向前选择
map('i', '<S-Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return vim.api.nvim_replace_termcodes('<C-p>', true, true, true)
  else
    return vim.api.nvim_replace_termcodes('<S-Tab>', true, true, true)
  end
end, {expr = true, silent = true})

-- 回车键确认选择（不展开snippet）
map('i', '<CR>', function()
  if vim.fn.pumvisible() == 1 then
    -- 直接确认选择并上屏，不展开snippet
    return vim.api.nvim_replace_termcodes('<C-y>', true, true, true)
  else
    return vim.api.nvim_replace_termcodes('<CR>', true, true, true)
  end
end, {expr = true, silent = true})

-- Ctrl-Space 手动触发补全（包含 snippets）
map('i', '<C-Space>', function()
  if vim.fn.pumvisible() == 1 then
    return vim.api.nvim_replace_termcodes('<C-y>', true, true, true)
  else
    -- 首先尝试 snippet 补全
    builtin_complete_with_snippets()
    vim.defer_fn(function()
      if vim.fn.pumvisible() == 0 then
        -- 如果没有 snippet 匹配，尝试其他补全
        if vim.lsp.get_clients({bufnr = 0})[1] then
          vim.lsp.completion.trigger()
        else
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes('<C-X><C-O>', true, true, true),
            'n',
            false
          )
        end
      end
    end, 50)
    return ''
  end
end, {expr = true, silent = true})

-- 自动触发补全和 snippet
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local ft_triggers = {
      lua = { '.', ':', },
      python = { '.', ':', },
      javascript = { '.', ':', },
      typescript = { '.', ':', },
      cpp = { '.', '::', '->', },
      c = { '.', '->', },
      html = { '<', '/', '>', },
      css = { ':', ';', },
      vim = { ':', },
      java = { '.', ':', },
      default = { '.', ':', '>' },
    }
    
    local triggers = ft_triggers[ft] or ft_triggers.default
    
    -- 字符触发补全
    vim.api.nvim_create_autocmd('InsertCharPre', {
      buffer = args.buf,
      callback = function()
        local char = vim.v.char
        for _, trigger in ipairs(triggers) do
          if char == trigger then
            vim.defer_fn(function()
              if vim.fn.pumvisible() == 0 and vim.fn.mode() == 'i' then
                local col = vim.api.nvim_win_get_cursor(0)[2]
                if col > 0 then
                  if vim.lsp.get_clients({bufnr = 0})[1] then
                    vim.lsp.completion.trigger()
                  else
                    vim.api.nvim_feedkeys(
                      vim.api.nvim_replace_termcodes('<C-X><C-O>', true, true, true),
                      'n',
                      false
                    )
                  end
                end
              end
            end, 50)
            break
          end
        end
      end
    })
    
    -- 输入时自动触发 snippet 补全
    vim.api.nvim_create_autocmd('TextChangedI', {
      buffer = args.buf,
      callback = function()
        if vim.fn.pumvisible() == 0 then
          local line = vim.api.nvim_get_current_line()
          local col = vim.api.nvim_win_get_cursor(0)[2]
          local prefix = line:sub(1, col):match('[%w_]*$') or ''
          
          -- 如果输入了2个字符以上，尝试匹配 snippet
          if #prefix >= 2 then
            local snippets = load_snippets_for_filetype(ft)
            for _, snippet in ipairs(snippets) do
              if snippet.word:lower():find(prefix:lower(), 1, true) == 1 then
                -- 找到匹配的 snippet，触发补全
                vim.defer_fn(function()
                  if vim.fn.pumvisible() == 0 then
                    builtin_complete_with_snippets()
                  end
                end, 100)
                break
              end
            end
          end
        end
      end
    })
  end
})

-- 占位符跳转快捷键 - 只在 snippet 模式下生效
map({'i', 's', 'n', 'v'}, '<C-f>', function()
  if snippet_mode_active and not vim.tbl_isempty(current_snippet_placeholders) then
    local success = jump_to_next_placeholder()
    if not success then
      snippet_mode_active = false  -- 如果跳转失败，退出 snippet 模式
    end
    return ''
  else
    return vim.api.nvim_replace_termcodes('<C-f>', true, true, true)
  end
end, {expr = true, silent = true})

map({'i', 's', 'n', 'v'}, '<C-b>', function()
  if snippet_mode_active and not vim.tbl_isempty(current_snippet_placeholders) then
    jump_to_prev_placeholder()
    return ''
  else
    return vim.api.nvim_replace_termcodes('<C-b>', true, true, true)
  end
end, {expr = true, silent = true})

-- 其他补全相关快捷键 - 只在补全菜单可见时生效
map('i', '<Down>', function()
  if vim.fn.pumvisible() == 1 then
    return vim.api.nvim_replace_termcodes('<C-n>', true, true, true)
  else
    return vim.api.nvim_replace_termcodes('<Down>', true, true, true)
  end
end, {expr = true, silent = true})

map('i', '<Up>', function()
  if vim.fn.pumvisible() == 1 then
    return vim.api.nvim_replace_termcodes('<C-p>', true, true, true)
  else
    return vim.api.nvim_replace_termcodes('<Up>', true, true, true)
  end
end, {expr = true, silent = true})

-- 自动清空 snippet 状态的情况
vim.api.nvim_create_autocmd({'InsertLeave', 'BufLeave'}, {
  callback = function()
    current_snippet_placeholders = {}
    current_placeholder_index = 0
    snippet_mode_active = false  -- 退出 snippet 模式
  end
})

-- ESC 键退出 snippet 模式
map({'i', 's', 'v'}, '<Esc>', function()
  if snippet_mode_active then
    snippet_mode_active = false
    current_snippet_placeholders = {}
    current_placeholder_index = 0
  end
  return vim.api.nvim_replace_termcodes('<Esc>', true, true, true)
end, {expr = true, silent = true})
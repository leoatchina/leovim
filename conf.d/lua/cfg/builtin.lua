-- Neovim 0.11 内置补全 + friendly snippets + buffer + path 配置
-- 局部变量定义
local map = vim.keymap.set
-- 补全菜单样式
vim.api.nvim_set_hl(0, 'Pmenu', {bg = '#3b4252', fg = '#d8dee9'})
vim.api.nvim_set_hl(0, 'PmenuSel', {bg = '#81a1c1', fg = '#2e3440', bold = true})
vim.api.nvim_set_hl(0, 'PmenuKind', {bg = '#3b4252', fg = '#88c0d0'})
vim.api.nvim_set_hl(0, 'PmenuKindSel', {bg = '#81a1c1', fg = '#2e3440', bold = true})
vim.api.nvim_set_hl(0, 'PmenuExtra', {bg = '#3b4252', fg = '#8fbcbb'})
vim.api.nvim_set_hl(0, 'PmenuExtraSel', {bg = '#81a1c1', fg = '#2e3440'})

-- 设置base_dir
local dict_base_dir = vim.fn.expand('$HOME/.leovim/pack/clone/opt/vim-dict/dict') .. '/'
local snippets_base_dir = vim.fn.expand('$HOME/.leovim.d/pack/add/opt/friendly-snippets/snippets') .. '/'

-- 全局变量存储当前 snippet 状态
local current_snippet_placeholders = {}
local current_placeholder_index = 0
local snippet_mode_active = false

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
    if type(snippet) == 'table' and snippet.prefix and snippet.body and type(snippet.prefix) == 'string' then
      local body = type(snippet.body) == 'table' and table.concat(snippet.body, '\n') or snippet.body
      local description = snippet.description or name

      table.insert(snippets, {
        word = snippet.prefix,
        abbr = snippet.prefix,
        menu = '[S] ' .. description,
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
  local prefix_len = item.word and #item.word or 0

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

-- 全局 snippet 缓存
local snippet_cache = {}

-- 加载文件类型对应的 snippets
local function load_snippets_for_filetype(filetype)
  if snippet_cache[filetype] then
    return snippet_cache[filetype]
  end
  local snippets = {}
  -- 检查 snippets 目录是否存在
  if vim.fn.isdirectory(snippets_base_dir) == 0 then
    snippet_cache[filetype] = {}
    return {}
  end

  local snippet_files = {}
  -- 查找全局 snippets
  local global_file = snippets_base_dir .. 'global.json'
  if vim.fn.filereadable(global_file) == 1 then
    table.insert(snippet_files, global_file)
  end

  -- 查找文件类型特定的 snippets - 优先检查子目录
  local ft_dir = snippets_base_dir .. filetype
  if vim.fn.isdirectory(ft_dir) == 1 then
    -- 有子目录，加载所有 json 文件
    local ft_dir_files = vim.fn.glob(ft_dir .. '/*.json', true, true)
    vim.list_extend(snippet_files, ft_dir_files)
  else
    -- 没有子目录，检查直接的 json 文件
    local ft_file = snippets_base_dir .. filetype .. '.json'
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
      local alias_file = snippets_base_dir .. alias .. '.json'
      if vim.fn.filereadable(alias_file) == 1 then
        table.insert(snippet_files, alias_file)
      end

      -- 检查别名的子目录
      local alias_dir = snippets_base_dir .. alias
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

-- 检查是否可以触发omni补全
local function can_trigger_omni()
  local omni_func = vim.bo.omnifunc
  if omni_func == '' or omni_func == 'syntaxcomplete#Complete' then
    return false
  end

  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before_cursor = line:sub(1, col)
  local filetype = vim.bo.filetype

  -- 根据文件类型检查omni补全触发条件
  local patterns = {
    python = '[%w_]+%.$',           -- obj.
    javascript = '[%w_]+%.$',       -- obj.
    typescript = '[%w_]+%.$',       -- obj.
    lua = '[%w_]+[%.:]$',          -- obj. 或 obj:
    c = '[%w_]+%.%->$',            -- obj. 或 obj->
    cpp = '[%w_]+[%.:]?:?%->$',    -- obj. 或 obj:: 或 obj->
    vim = '[%w_]+:$',              -- obj:
    html = '<[^>]*$',              -- <tag
    xml = '<[^>]*$',               -- <tag
    css = '[%w_%-]+:$',            -- property:
  }

  local pattern = patterns[filetype]
  if pattern and before_cursor:match(pattern) then
    return true
  end

  -- 通用模式：检查是否以点号、冒号、箭头结尾
  if before_cursor:match('[%w_]+[%.:]$') or before_cursor:match('[%w_]+%->$') then
    return true
  end

  return false
end

-- 检查是否需要路径补全
local function can_trigger_path()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before_cursor = line:sub(1, col)

  -- 检查路径模式
  local path_patterns = {
    '/[^%s]*$',           -- 绝对路径：/tmp, /home/user 等
    '%./[^%s]*$',         -- 相对路径：./file
    '%.%./[^%s]*$',       -- 相对路径：../file
    '~[^%s]*$',           -- 家目录路径：~/
    '[%w_%-%.]+/[^%s]*$', -- 目录/文件路径：dir/file
  }

  for _, pattern in ipairs(path_patterns) do
    if before_cursor:match(pattern) then
      return true
    end
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
    local omni_func = nil
    -- Python 特殊处理：检查是否有 python3 支持
    if ft == 'python' then
      if vim.fn.has('python3') == 1 then
        omni_func = 'python3complete#Complete'
      end
    elseif omni_funcs[ft] then
      omni_func = omni_funcs[ft]
    end

    if omni_func then
      -- 有有效的 omnifunc，直接设置，不使用字典补全
      vim.bo[args.buf].omnifunc = omni_func
    else
      -- 没有有效的 omnifunc，使用 syntaxcomplete
      vim.bo[args.buf].omnifunc = 'syntaxcomplete#Complete'

      -- 首先尝试直接匹配的字典文件
      local dict_file = dict_base_dir .. ft .. '.dict'
      if vim.fn.filereadable(dict_file) == 1 then
        vim.bo[args.buf].dictionary = dict_file
      else
        -- 如果没有直接匹配的，使用一些特殊映射
        local fallback_dict_files = {
          text = 'text.dict',
          markdown = 'text.dict',
          txt = 'text.dict',
          typescript = 'javascript.dict',
          bash = 'sh.dict',
          zsh = 'sh.dict',
          fish = 'sh.dict',
          shell = 'sh.dict',
        }

        if fallback_dict_files[ft] then
          local fallback_dict_file = dict_base_dir .. fallback_dict_files[ft]
          if vim.fn.filereadable(fallback_dict_file) == 1 then
            vim.bo[args.buf].dictionary = fallback_dict_file
          end
        end
      end
    end
    -- 预加载该文件类型的 snippets
    load_snippets_for_filetype(ft)
  end
})

-- 统一补全函数（按优先级：snippet -> omni/dict -> buffer -> path）
function _G.builtin_complete_unified()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local prefix = line:sub(1, col):match('[%w_]*$') or ''
  local path_prefix = line:sub(1, col):match('[^%s]*$') or ''

  -- 检查是否可以触发任何类型的补全
  local can_omni = can_trigger_omni()

  if #prefix == 0 and not can_trigger_path() and not can_omni then
    return ''
  end

  local filetype = vim.bo.filetype
  local all_matches = {}
  local start_col = col - #prefix + 1

  -- 如果是路径补全，调整起始列
  if can_trigger_path() and #path_prefix > #prefix then
    start_col = col - #path_prefix + 1
  end
  -- 1. 添加 snippet 补全
  if #prefix > 0 then
    local snippets = load_snippets_for_filetype(filetype)
    for _, snippet in ipairs(snippets) do
      if snippet.word and type(snippet.word) == 'string' and snippet.word:lower():find(prefix:lower(), 1, true) == 1 then
        table.insert(all_matches, snippet)
      end
    end
  end
  -- 2. 添加 omni 补全
  if can_omni then
    local omni_func = vim.bo.omnifunc
    -- 使用 omni 补全
    pcall(function()
      local omni_base = vim.fn[omni_func](1, prefix)
      if type(omni_base) == 'number' and omni_base >= 0 then
        local omni_items = vim.fn[omni_func](0, prefix)
        if type(omni_items) == 'table' then
          for _, item in ipairs(omni_items) do
            if type(item) == 'string' then
              table.insert(all_matches, {word = item, menu = '[O]'})
            elseif type(item) == 'table' and item.word then
              item.menu = item.menu and (item.menu .. ' [O]') or '[O]'
              table.insert(all_matches, item)
            end
          end
        end
      end
    end)
  end
  -- 3. 添加语法和字典补全（当有前缀且不是omni触发情况时）
  if #prefix > 0 and not can_omni then
    local omni_func = vim.bo.omnifunc
    local has_omni = omni_func ~= '' and omni_func ~= 'syntaxcomplete#Complete'

    if not has_omni then
      -- 使用语法补全 + 字典补全
      pcall(function()
        local syntax_base = vim.fn['syntaxcomplete#Complete'](1, prefix)
        if type(syntax_base) == 'number' and syntax_base >= 0 then
          local syntax_items = vim.fn['syntaxcomplete#Complete'](0, prefix)
          if type(syntax_items) == 'table' then
            for _, item in ipairs(syntax_items) do
              if type(item) == 'string' then
                table.insert(all_matches, {word = item, menu = '[Y]'})
              elseif type(item) == 'table' and item.word then
                                  item.menu = item.menu and (item.menu .. ' [Y]') or '[Y]'
                table.insert(all_matches, item)
              end
            end
          end
        end
      end)

      -- 添加字典补全
      if vim.bo.dictionary and vim.bo.dictionary ~= '' then
        local dict_words = {}
        local dict_files = vim.split(vim.bo.dictionary, ',')
        for _, dict_file in ipairs(dict_files) do
          dict_file = vim.trim(dict_file)
          if vim.fn.filereadable(dict_file) == 1 then
            pcall(function()
              local lines = vim.fn.readfile(dict_file, '', 1000) -- 限制读取行数
              for _, word in ipairs(lines) do
                word = vim.trim(word)
                if word ~= '' and word:lower():find(prefix:lower(), 1, true) == 1 then
                  if not dict_words[word] then
                    dict_words[word] = true
                    table.insert(all_matches, {word = word, menu = '[D]'})
                  end
                end
              end
            end)
          end
        end
      end
    end
  end
  -- 4. 添加 buffer 补全
  if #prefix >= 1 then
    local buffer_words = {}
    local current_buf = vim.api.nvim_get_current_buf()
    local buffers = {current_buf} -- 优先当前buffer

    -- 添加其他已加载的buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if buf ~= current_buf and vim.api.nvim_buf_is_loaded(buf) then
        table.insert(buffers, buf)
      end
    end

    for _, buf in ipairs(buffers) do
      pcall(function()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        for _, buf_line in ipairs(lines) do
          for word in buf_line:gmatch('[%w_]+') do
            if #word >= 2 and word:lower():find(prefix:lower(), 1, true) == 1 and word ~= prefix then
              if not buffer_words[word] then
                buffer_words[word] = true
                local menu = buf == current_buf and '[B]' or '[b]'
                table.insert(all_matches, {word = word, menu = menu})
              end
            end
          end
        end
      end)
    end
  end
  -- 5. 添加路径补全
  if can_trigger_path() then
    pcall(function()
      -- 处理路径补全
      local dir_part = path_prefix:match('^(.*/)')
      local file_part = path_prefix:match('([^/]*)$')

      if not dir_part then
        dir_part = './'
        file_part = path_prefix
      end
      -- 使用glob进行文件匹配
      local pattern = dir_part .. file_part .. '*'
      local glob_results = vim.fn.glob(pattern, false, true)
      for _, path in ipairs(glob_results) do
        local is_dir = vim.fn.isdirectory(path) == 1
        local basename = vim.fn.fnamemodify(path, ':t')
        if basename ~= '' and basename:lower():find(file_part:lower(), 1, true) == 1 then
          local display_name = basename .. (is_dir and '/' or '')
          table.insert(all_matches, {
            word = display_name,
            menu = '[P]',
            info = path
          })
        end
      end
    end)
  end
  -- 显示补全菜单
  if #all_matches > 0 then
    -- 确保只在插入模式下调用 complete()
    if vim.fn.mode() == 'i' then
      vim.fn.complete(start_col, all_matches)
    end
  end
  return ''
end

-- ============================================================================
-- 补全相关快捷键
-- ============================================================================
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

-- Ctrl-Space 手动触发补全（智能策略：有omni时不用dict，无omni时用syntaxcomplete+dict）
map('i', '<C-@>', function()
  if vim.fn.pumvisible() == 1 then
    return vim.api.nvim_replace_termcodes('<C-y>', true, true, true)
  else
    -- 使用统一补全函数
    builtin_complete_unified()
    return ''
  end
end, {expr = true, silent = true})

-- 为所有buffer添加通用的自动触发补全功能
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*',
  callback = function(args)
    -- 通用的输入时自动触发补全
    vim.api.nvim_create_autocmd('TextChangedI', {
      buffer = args.buf,
      callback = function()
        if vim.fn.pumvisible() == 0 then
          local line = vim.api.nvim_get_current_line()
          local col = vim.api.nvim_win_get_cursor(0)[2]
          local prefix = line:sub(1, col):match('[%w_]*$') or ''
          local can_trigger = false

          -- 1. 检查buffer词汇匹配（降低门槛到1个字符）
          if #prefix >= 1 then
            local current_buf = vim.api.nvim_get_current_buf()
            local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
            for _, buf_line in ipairs(lines) do
              for word in buf_line:gmatch('[%w_]+') do
                if #word >= 2 and word:lower():find(prefix:lower(), 1, true) == 1 and word ~= prefix then
                  can_trigger = true
                  break
                end
              end
              if can_trigger then break end
            end
          end

          -- 2. 检查路径补全
          if not can_trigger and can_trigger_path() then
            can_trigger = true
          end

          -- 触发补全
          if can_trigger then
            vim.defer_fn(function()
              if vim.fn.pumvisible() == 0 and vim.fn.mode() == 'i' then
                builtin_complete_unified()
              end
            end, 150)
          end
        end
      end
    })
  end
})

-- 自动触发补全和 snippet（文件类型特定）
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local ft_triggers = {
      lua = { '.', ':' },
      python = { '.', ':' },
      javascript = { '.', ':' },
      typescript = { '.', ':' },
      cpp = { '.', '::', '->' },
      c = { '.', '->' },
      html = { '<', '/', '>' },
      css = { ':', ';' },
      vim = { ':' },
      java = { '.', ':' },
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
                  local omni_func = vim.bo.omnifunc
                  local has_omni = omni_func ~= '' and omni_func ~= 'syntaxcomplete#Complete'

                  -- 直接使用统一补全函数
                  builtin_complete_unified()
                end
              end
            end, 50)
            break
          end
        end
      end
    })

    -- 输入时自动触发补全（包括 snippet、buffer、路径补全）
    vim.api.nvim_create_autocmd('TextChangedI', {
      buffer = args.buf,
      callback = function()
        if vim.fn.pumvisible() == 0 then
          local line = vim.api.nvim_get_current_line()
          local col = vim.api.nvim_win_get_cursor(0)[2]
          local prefix = line:sub(1, col):match('[%w_]*$') or ''
          local can_trigger = false

          -- 检查是否应该触发补全
          if #prefix >= 2 then
            -- 1. 检查 snippet 匹配
            local snippets = load_snippets_for_filetype(ft)
            for _, snippet in ipairs(snippets) do
              if snippet.word and type(snippet.word) == 'string' and snippet.word:lower():find(prefix:lower(), 1, true) == 1 then
                can_trigger = true
                break
              end
            end

            -- 2. 如果没有snippet匹配，检查是否有buffer词汇匹配
            if not can_trigger then
              local current_buf = vim.api.nvim_get_current_buf()
              local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
              for _, buf_line in ipairs(lines) do
                for word in buf_line:gmatch('[%w_]+') do
                  if #word >= 3 and word:lower():find(prefix:lower(), 1, true) == 1 and word ~= prefix then
                    can_trigger = true
                    break
                  end
                end
                if can_trigger then break end
              end
            end
          end

          -- 3. 检查路径补全
          if not can_trigger and can_trigger_path() then
            can_trigger = true
          end

          -- 触发补全
          if can_trigger then
            vim.defer_fn(function()
              if vim.fn.pumvisible() == 0 and vim.fn.mode() == 'i' then
                builtin_complete_unified()
              end
            end, 100)
          end
        end
      end
    })
  end
})

-- 占位符跳转快捷键 - 只在 snippet 模式下生效
map({'i', 's'}, '<C-f>', function()
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

map({'i', 's'}, '<C-b>', function()
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

-- ============================================================================
-- 调试命令
-- ============================================================================

-- 添加调试命令
vim.api.nvim_create_user_command('DebugSnippets', function()
  local filetype = vim.bo.filetype
  local snippets = load_snippets_for_filetype(filetype)
  local omni_func = vim.bo.omnifunc
  local has_omni = omni_func ~= '' and omni_func ~= 'syntaxcomplete#Complete'
  local strategy = has_omni and "omni[O]" or "syntax[Y]+dict[D]"
  print(filetype .. ": " .. #snippets .. " snippets[S], mode: " .. (snippet_mode_active and "on" or "off") .. ", strategy: " .. strategy)
end, {})

-- 添加补全调试命令
vim.api.nvim_create_user_command('DebugComplete', function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local prefix = line:sub(1, col):match('[%w_]*$') or ''
  local path_prefix = line:sub(1, col):match('[^%s]*$') or ''
  local can_omni = can_trigger_omni()
  local can_path = can_trigger_path()
  local before_cursor = line:sub(1, col)

  print("=== 补全调试信息 ===")
  print("文件类型: " .. vim.bo.filetype)
  print("当前行: '" .. line .. "'")
  print("光标位置: " .. col)
  print("光标前文本: '" .. before_cursor .. "'")
  print("前缀: '" .. prefix .. "' (长度: " .. #prefix .. ")")
  print("路径前缀: '" .. path_prefix .. "' (长度: " .. #path_prefix .. ")")
  print("可触发omni: " .. tostring(can_omni))
  print("可触发路径: " .. tostring(can_path))
  print("buffer补全条件: " .. tostring(#prefix >= 1))
  print("omnifunc: " .. vim.bo.omnifunc)
  print("字典文件: " .. (vim.bo.dictionary or "无"))

  -- 测试路径模式匹配
  print("\n=== 路径模式测试 ===")
  local path_patterns = {
    '/[^%s]*$',           -- 绝对路径
    '%./[^%s]*$',         -- 相对路径 ./
    '%.%./[^%s]*$',       -- 相对路径 ../
    '~[^%s]*$',           -- 家目录路径
    '[%w_%-%.]+/[^%s]*$', -- 目录/文件路径
  }

  for i, pattern in ipairs(path_patterns) do
    local matches = before_cursor:match(pattern)
    print("模式" .. i .. " '" .. pattern .. "': " .. tostring(matches ~= nil))
    if matches then
      print("  匹配内容: '" .. matches .. "'")
    end
  end

    -- 测试各种补全类型
  print("\n=== 测试补全类型 ===")

  -- 测试字典补全[D]
  if vim.bo.dictionary and vim.bo.dictionary ~= '' and #prefix > 0 then
    print("测试字典补全[D]，前缀: '" .. prefix .. "'")
    local dict_matches = 0
    local dict_files = vim.split(vim.bo.dictionary, ',')
    for _, dict_file in ipairs(dict_files) do
      dict_file = vim.trim(dict_file)
      if vim.fn.filereadable(dict_file) == 1 then
        local lines = vim.fn.readfile(dict_file, '', 100) -- 只读前100行用于测试
        for _, word in ipairs(lines) do
          word = vim.trim(word)
          if word ~= '' and word:lower():find(prefix:lower(), 1, true) == 1 then
            dict_matches = dict_matches + 1
            if dict_matches <= 3 then  -- 只显示前3个
              print("  [D]字典匹配: '" .. word .. "'")
            end
          end
        end
      end
    end
    print("[D]字典匹配数量: " .. dict_matches)
  else
    print("[D]字典补全：" .. (vim.bo.dictionary and "前缀为空" or "无字典文件"))
  end

  -- 测试buffer补全[B]
  if #prefix >= 1 then
    local current_buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
    local found_words = {}
    print("测试buffer补全[B]，前缀: '" .. prefix .. "'")
    for line_num, buf_line in ipairs(lines) do
      for word in buf_line:gmatch('[%w_]+') do
        if #word >= 2 and word:lower():find(prefix:lower(), 1, true) == 1 and word ~= prefix then
          if not found_words[word] then
            found_words[word] = true
            print("  [B]找到匹配词: '" .. word .. "' 在第" .. line_num .. "行")
          end
        end
      end
    end
    local count = 0
    for _ in pairs(found_words) do count = count + 1 end
    print("[B]Buffer词汇匹配数量: " .. count)
  else
    print("[B]Buffer补全：前缀长度不足 (#prefix=" .. #prefix .. ")")
  end

  -- 测试路径补全[P]
  if can_path then
    local dir_part = path_prefix:match('^(.*/)')
    local file_part = path_prefix:match('([^/]*)$')
    print("路径补全[P]分析:")
    print("  dir_part: '" .. (dir_part or "nil") .. "'")
    print("  file_part: '" .. file_part .. "'")

    if not dir_part then
      dir_part = './'
      file_part = path_prefix
    end
    local pattern = dir_part .. file_part .. '*'
    print("[P]路径glob模式: '" .. pattern .. "'")
    local glob_results = vim.fn.glob(pattern, false, true)
    print("[P]路径匹配数量: " .. #glob_results)
    if #glob_results > 0 then
      for i, path in ipairs(glob_results) do
        if i <= 3 then  -- 只显示前3个
          print("  [P]" .. i .. ": " .. path)
        end
      end
    end
  else
    print("[P]路径补全：不满足触发条件")
  end

  print("\n手动触发补全...")
  if vim.fn.mode() == 'i' then
    builtin_complete_unified()
  else
    print("注意：只能在插入模式下触发补全")
  end
end, {})

-- 添加清空 snippet 状态的命令
vim.api.nvim_create_user_command('ClearSnippet', function()
  current_snippet_placeholders = {}
  current_placeholder_index = 0
  snippet_mode_active = false
end, {})

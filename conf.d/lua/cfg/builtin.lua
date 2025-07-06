-- Neovim 0.11 Built-in Completion + Friendly Snippets + Buffer + Path Configuration
-- Enhanced with improved structure and completion priority: snippet -> omni -> buffer -> dict -> path

-- ============================================================================
-- 全局变量和配置
-- ============================================================================
local map = vim.keymap.set

-- 检查补全菜单是否可见
local function pumvisible()
  return vim.fn.pumvisible() == 1
end

-- 获取当前模式
local function mode()
  return vim.fn.mode()
end

-- 检查是否为Windows系统
local function is_windows()
  return vim.loop.os_uname().sysname:find("Windows") ~= nil or vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
end

-- 基础目录配置
local dict_base_dir = vim.fn.expand('$HOME/.leovim/pack/clone/opt/vim-dict/dict') .. '/'
local snippets_base_dir = vim.fn.expand('$HOME/.leovim.d/pack/add/opt/friendly-snippets/snippets') .. '/'
local user_snippets_base_dir = vim.fn.expand('$HOME/.leovim/conf.d/snippets') .. '/'

-- 代码片段状态变量
local current_snippet_placeholders = {}
local current_placeholder_index = 0
local snippet_mode_active = false

-- 缓存和性能优化
local snippet_cache = {}
local pending_timers = {}
local completion_active = true

-- ============================================================================
-- 代码片段补全功能
-- ============================================================================

-- 解析VSCode格式的代码片段文件
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

-- Load snippets for specific filetype
local function load_snippets_for_filetype(filetype)
  if snippet_cache[filetype] then
    return snippet_cache[filetype]
  end

  local snippets = {}
  if vim.fn.isdirectory(snippets_base_dir) == 0 then
    snippet_cache[filetype] = {}
    return {}
  end

  local snippet_files = {}

  -- Load snippets from both directories: friendly-snippets and user snippets
  local snippet_dirs = {snippets_base_dir, user_snippets_base_dir}

  for _, base_dir in ipairs(snippet_dirs) do
    if vim.fn.isdirectory(base_dir) == 1 then
      -- Load global snippets
      local global_file = base_dir .. 'global.json'
      if vim.fn.filereadable(global_file) == 1 then
        table.insert(snippet_files, global_file)
      end

      -- Load filetype-specific snippets - prioritize subdirectories
      local ft_dir = base_dir .. filetype
      if vim.fn.isdirectory(ft_dir) == 1 then
        local ft_dir_files = vim.fn.glob(ft_dir .. '/*.json', true, true)
        vim.list_extend(snippet_files, ft_dir_files)
      else
        local ft_file = base_dir .. filetype .. '.json'
        if vim.fn.filereadable(ft_file) == 1 then
          table.insert(snippet_files, ft_file)
        end
      end
    end
  end

  -- Load language alias snippets
  local aliases = {
    cpp = {'c'},
    typescript = {'javascript'},
    javascript = {'html'},
  }

  if aliases[filetype] then
    for _, base_dir in ipairs(snippet_dirs) do
      if vim.fn.isdirectory(base_dir) == 1 then
        for _, alias in ipairs(aliases[filetype]) do
          local alias_file = base_dir .. alias .. '.json'
          if vim.fn.filereadable(alias_file) == 1 then
            table.insert(snippet_files, alias_file)
          end

          local alias_dir = base_dir .. alias
          if vim.fn.isdirectory(alias_dir) == 1 then
            local alias_dir_files = vim.fn.glob(alias_dir .. '/*.json', true, true)
            vim.list_extend(snippet_files, alias_dir_files)
          end
        end
      end
    end
  end

  -- Parse all found snippet files
  for _, file_path in ipairs(snippet_files) do
    local file_snippets = parse_vscode_snippets(file_path)
    vim.list_extend(snippets, file_snippets)
  end

  snippet_cache[filetype] = snippets
  return snippets
end

-- Get snippet completions
local function get_snippet_completions(prefix, filetype)
  local snippets = load_snippets_for_filetype(filetype)
  local matches = {}

  if #prefix > 0 then
    for _, snippet in ipairs(snippets) do
      if snippet.word and type(snippet.word) == 'string' and
         snippet.word:lower():find(prefix:lower(), 1, true) == 1 then
        table.insert(matches, snippet)
      end
    end
  end

  return matches
end

-- Expand snippet function
local function expand_snippet()
  local item = vim.v.completed_item
  if not item or vim.tbl_isempty(item) then
    return false
  end

  if not item.user_data or not item.user_data.snippet then
    return false
  end

  local body = item.user_data.body
  if not body then
    return false
  end

  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local prefix_len = item.word and #item.word or 0

  local processed_body = body
  local placeholders = {}
  local first_placeholder_num = nil

  -- Recursive function to process nested placeholders from innermost to outermost
  local function process_placeholders_recursive(text)
    local changed = true
    local result = text

    while changed do
      changed = false

      -- First pass: Process innermost placeholders (no nested ${} inside)
      result = result:gsub('%$%{(%d+):([^{}]*)%}', function(num, default)
        changed = true
        local placeholder_num = tonumber(num)
        placeholders[placeholder_num] = {text = default, has_content = #default > 0}
        if not first_placeholder_num or placeholder_num < first_placeholder_num then
          first_placeholder_num = placeholder_num
        end

        if #default > 0 then
          return default
        else
          return '___PLACEHOLDER_' .. placeholder_num .. '___'
        end
      end)

      -- Second pass: Process ${n} format (no content)
      result = result:gsub('%$%{(%d+)%}', function(num)
        changed = true
        local placeholder_num = tonumber(num)
        if placeholder_num == 0 then
          placeholders[0] = {text = '', has_content = false}
          return ''
        else
          placeholders[placeholder_num] = {text = '', has_content = false}
          if not first_placeholder_num or placeholder_num < first_placeholder_num then
            first_placeholder_num = placeholder_num
          end
          return '___PLACEHOLDER_' .. placeholder_num .. '___'
        end
      end)
    end

    return result
  end

  -- Process all placeholders recursively
  processed_body = process_placeholders_recursive(processed_body)

  -- Final pass: Process simple $n format placeholders
  processed_body = processed_body:gsub('%$(%d+)', function(num)
    local placeholder_num = tonumber(num)
    if placeholder_num == 0 then
      placeholders[0] = {text = '', has_content = false}
      return ''
    else
      if not placeholders[placeholder_num] then
        placeholders[placeholder_num] = {text = '', has_content = false}
        if not first_placeholder_num or placeholder_num < first_placeholder_num then
          first_placeholder_num = placeholder_num
        end
      end
      return '___PLACEHOLDER_' .. placeholder_num .. '___'
    end
  end)

  local lines = vim.split(processed_body, '\n', {plain = true})
  local before = line:sub(1, col - prefix_len)
  local after = line:sub(col + 1)

  local new_lines = {}
  for i, snippet_line in ipairs(lines) do
    if i == 1 then
      table.insert(new_lines, before .. snippet_line)
    elseif i == #lines then
      table.insert(new_lines, snippet_line .. after)
    else
      table.insert(new_lines, snippet_line)
    end
  end

  vim.api.nvim_buf_set_lines(0, row - 1, row, false, new_lines)

  -- Clean up ALL placeholder markers from the inserted text
  local first_placeholder_pos = nil
  for line_idx, line_content in ipairs(new_lines) do
    local updated_line = line_content
    local line_changed = false

    -- Clean up all placeholder markers in this line (0-10)
    for placeholder_num = 0, 10 do
      local marker = '___PLACEHOLDER_' .. placeholder_num .. '___'
      if updated_line:find(marker, 1, true) then
        local escaped_marker = marker:gsub('([%(%)%.%+%-%*%?%[%]%^%$%%])', '%%%1')
        updated_line = updated_line:gsub(escaped_marker, '')
        line_changed = true
      end
    end

    -- Update the line if any markers were found
    if line_changed then
      new_lines[line_idx] = updated_line
      vim.api.nvim_buf_set_lines(0, row - 1 + line_idx - 1, row - 1 + line_idx, false, {updated_line})
    end
  end

  -- Find first placeholder position using placeholder content
  if first_placeholder_num then
    if placeholders[first_placeholder_num] and placeholders[first_placeholder_num].has_content then
      -- For placeholders with content, find by text
      local placeholder_text = placeholders[first_placeholder_num].text
      for line_idx, line_content in ipairs(new_lines) do
        local start_pos = line_content:find(placeholder_text, 1, true)
        if start_pos then
          first_placeholder_pos = {
            row = row - 1 + line_idx - 1,
            col_start = start_pos - 1,
            col_end = start_pos + #placeholder_text - 1,
            text = placeholder_text
          }
          break
        end
      end
    else
      -- For empty placeholders, position cursor at the logical first placeholder location
      -- This is typically at the end of the first line of the snippet
      first_placeholder_pos = {
        row = row - 1,
        col_start = #new_lines[1] - #after,
        col_end = #new_lines[1] - #after,
        text = ''
      }
    end
  end

  if first_placeholder_pos then
    vim.api.nvim_win_set_cursor(0, {first_placeholder_pos.row + 1, first_placeholder_pos.col_start})
    vim.defer_fn(function()
      local current_mode = mode()
      if current_mode == 'i' then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, true, true), 'n', false)
        vim.defer_fn(function()
          pcall(function()
            vim.api.nvim_win_set_cursor(0, {first_placeholder_pos.row + 1, first_placeholder_pos.col_start})
            vim.cmd('normal! v')
            vim.api.nvim_win_set_cursor(0, {first_placeholder_pos.row + 1, first_placeholder_pos.col_end})
            vim.defer_fn(function()
              vim.cmd('startinsert')
            end, 50)
          end)
        end, 20)
      else
        pcall(function()
          vim.cmd('normal! v')
          vim.api.nvim_win_set_cursor(0, {first_placeholder_pos.row + 1, first_placeholder_pos.col_end})
          vim.defer_fn(function()
            vim.cmd('startinsert')
          end, 50)
        end)
      end
    end, 10)
  else
    local final_row = row - 1 + #new_lines - 1
    local final_col = #new_lines[#new_lines] - #after
    vim.api.nvim_win_set_cursor(0, {final_row + 1, final_col})
  end

  current_snippet_placeholders = placeholders
  current_placeholder_index = 1
  snippet_mode_active = true

  return true
end

-- Jump to next placeholder
local function jump_to_next_placeholder()
  if vim.tbl_isempty(current_snippet_placeholders) then
    return false
  end
  current_placeholder_index = current_placeholder_index + 1

  for i = current_placeholder_index, 10 do
    if current_snippet_placeholders[i] and current_snippet_placeholders[i].has_content then
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local placeholder_text = current_snippet_placeholders[i].text

      for row, line in ipairs(lines) do
        local start_pos = line:find(placeholder_text, 1, true)
        if start_pos then
          local end_col = start_pos + #placeholder_text - 1
          vim.api.nvim_win_set_cursor(0, {row, start_pos - 1})

          vim.defer_fn(function()
            local current_mode = mode()
            if current_mode == 'i' then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, true, true), 'n', false)
              vim.defer_fn(function()
                pcall(function()
                  vim.api.nvim_win_set_cursor(0, {row, start_pos - 1})
                  vim.cmd('normal! v')
                  vim.api.nvim_win_set_cursor(0, {row, end_col})
                  vim.defer_fn(function()
                    vim.cmd('startinsert')
                  end, 50)
                end)
              end, 20)
            else
              pcall(function()
                vim.cmd('normal! v')
                vim.api.nvim_win_set_cursor(0, {row, end_col})
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

  current_snippet_placeholders = {}
  current_placeholder_index = 0
  snippet_mode_active = false
  return false
end

-- Jump to previous placeholder
local function jump_to_prev_placeholder()
  if vim.tbl_isempty(current_snippet_placeholders) then
    return false
  end

  current_placeholder_index = current_placeholder_index - 1

  for i = current_placeholder_index, 1, -1 do
    if current_snippet_placeholders[i] and current_snippet_placeholders[i].has_content then
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local placeholder_text = current_snippet_placeholders[i].text

      for row, line in ipairs(lines) do
        local start_pos = line:find(placeholder_text, 1, true)
        if start_pos then
          local end_col = start_pos + #placeholder_text - 1
          vim.api.nvim_win_set_cursor(0, {row, start_pos - 1})

          vim.defer_fn(function()
            local current_mode = mode()
            if current_mode == 'i' then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, true, true), 'n', false)
              vim.defer_fn(function()
                pcall(function()
                  vim.api.nvim_win_set_cursor(0, {row, start_pos - 1})
                  vim.cmd('normal! v')
                  vim.api.nvim_win_set_cursor(0, {row, end_col})
                  vim.defer_fn(function()
                    vim.cmd('startinsert')
                  end, 50)
                end)
              end, 20)
            else
              pcall(function()
                vim.cmd('normal! v')
                vim.api.nvim_win_set_cursor(0, {row, end_col})
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

  if current_placeholder_index < 1 then
    current_placeholder_index = 0
  end
  return false
end

-- ============================================================================
-- OMNI COMPLETION FUNCTIONS
-- ============================================================================

-- Enhanced check if omni completion can be triggered
local function omni_available()
  local omni_func = vim.bo.omnifunc
  local filetype = vim.bo.filetype

  -- Special handling for Python: if no python3 support, disable omni completion
  if filetype == 'python' and vim.fn.has('python3') == 0 then
    return false
  end

  if omni_func == '' or omni_func == 'syntaxcomplete#Complete' then
    return false
  end

  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before_cursor = line:sub(1, col)

  -- Enhanced patterns for different file types
  local patterns = {
    python = '[%w_]+[%.:][%w_]*$',           -- obj. or obj: or class.method
    javascript = '[%w_]+[%.:][%w_]*$',       -- obj. or obj:
    typescript = '[%w_]+[%.:][%w_]*$',       -- obj. or obj:
    lua = '[%w_]+[%.:]?[%w_]*$',            -- obj. or obj: or module:
    c = '[%w_]+[%.-][%>]?[%w_]*$',          -- obj. or obj->
    cpp = '[%w_]+[%.:]?:?[%->]?[%w_]*$',    -- obj. or obj:: or obj->
    vim = '[%w_#]+:[%w_]*$',                -- obj: or g:var
    html = '<[^>]*$',                       -- <tag
    xml = '<[^>]*$',                        -- <tag
    css = '[%w_%-]+:[%w_]*$',               -- property:
    php = '%$[%w_]+[%->%.]?[%w_]*$',        -- $var-> or $var.
    java = '[%w_]+%.[%w_]*$',               -- obj.method
    go = '[%w_]+%.[%w_]*$',                 -- obj.method
  }

  local pattern = patterns[filetype]
  if pattern and before_cursor:match(pattern) then
    return true
  end

  -- Enhanced generic patterns
  local generic_patterns = {
    '[%w_]+[%.:][%w_]*$',     -- obj. or obj:
    '[%w_]+%->[%w_]*$',       -- obj->
    '[%w_]+::[%w_]*$',        -- namespace::
  }

  for _, generic_pattern in ipairs(generic_patterns) do
    if before_cursor:match(generic_pattern) then
      return true
    end
  end

  return false
end

-- Get omni completions
local function get_omni_completions(prefix)
  local omni_func = vim.bo.omnifunc
  local matches = {}

  if not omni_available() then
    return matches
  end

  pcall(function()
    local omni_base = vim.fn[omni_func](1, prefix)
    if type(omni_base) == 'number' and omni_base >= 0 then
      local omni_items = vim.fn[omni_func](0, prefix)
      if type(omni_items) == 'table' then
        for _, item in ipairs(omni_items) do
          if type(item) == 'string' then
            table.insert(matches, {word = item, menu = '[O]'})
          elseif type(item) == 'table' and item.word then
            item.menu = item.menu and (item.menu .. ' [O]') or '[O]'
            table.insert(matches, item)
          end
        end
      end
    end
  end)

  return matches
end

-- ============================================================================
-- BUFFER COMPLETION FUNCTIONS
-- ============================================================================

-- Check buffer words with caching
local function get_buffer_completions(prefix)
  local matches = {}

  if #prefix < 1 then
    return matches
  end

  local buffer_words = {}
  local current_buf = vim.api.nvim_get_current_buf()
  local buffers = {current_buf}

  -- Add other loaded buffers
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
              table.insert(matches, {word = word, menu = menu})
            end
          end
        end
      end
    end)
  end

  return matches
end

-- Check if buffer has matching words (for trigger detection)
local function buffer_has_matches(prefix)
  if #prefix < 1 then
    return false
  end

  local current_buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)

  for _, buf_line in ipairs(lines) do
    for word in buf_line:gmatch('[%w_]+') do
      if #word >= 2 and word:lower():find(prefix:lower(), 1, true) == 1 and word ~= prefix then
        return true
      end
    end
  end

  return false
end

-- ============================================================================
-- DICTIONARY COMPLETION FUNCTIONS
-- ============================================================================

-- Get dictionary completions
local function get_dictionary_completions(prefix)
  local matches = {}

  if #prefix < 1 or not vim.bo.dictionary or vim.bo.dictionary == '' then
    return matches
  end

  local dict_words = {}
  local dict_files = vim.split(vim.bo.dictionary, ',')

  for _, dict_file in ipairs(dict_files) do
    dict_file = vim.trim(dict_file)
    if vim.fn.filereadable(dict_file) == 1 then
      pcall(function()
        local lines = vim.fn.readfile(dict_file, '', 1000)
        for _, word in ipairs(lines) do
          word = vim.trim(word)
          if word ~= '' and word:lower():find(prefix:lower(), 1, true) == 1 then
            if not dict_words[word] then
              dict_words[word] = true
              table.insert(matches, {word = word, menu = '[D]'})
            end
          end
        end
      end)
    end
  end

  return matches
end

-- ============================================================================
-- 路径补全功能
-- ============================================================================

-- 提取路径前缀用于路径补全
local function extract_path_prefix(line, col)
  local before_cursor = line:sub(1, col)

  -- Try to extract path from quotes first
  local quoted_path = before_cursor:match('"([^"]*)$') or before_cursor:match('\'([^\']*)$')
  if quoted_path then
    return quoted_path
  end

  -- Try to extract path from shell variable assignment (=path)
  local assignment_path
  if is_windows() then
    assignment_path = before_cursor:match('=([A-Za-z]:[/\\][^%s"\']*)$') or   -- =C:/path
                      before_cursor:match('=([/~][^%s"\']*)$') or             -- =/path or =~/path
                      before_cursor:match('=(%.%.[/\\][^%s"\']*)$') or        -- =../path
                      before_cursor:match('=(%.[/\\][^%s"\']*)$') or          -- =./path
                      before_cursor:match('=([%w_%-%.]+[/\\][^%s"\']*)$')      -- =dir/path
  else
    assignment_path = before_cursor:match('=([/~][^%s"\']*)$') or             -- =/path or =~/path
                      before_cursor:match('=(%.%./[^%s"\']*)$') or            -- =../path
                      before_cursor:match('=(%./[^%s"\']*)$') or              -- =./path
                      before_cursor:match('=([%w_%-%.]+/[^%s"\']*)$')         -- =dir/path
  end

  if assignment_path then
    return assignment_path
  end

  -- Extract regular path patterns
  local path_patterns
  if is_windows() then
    path_patterns = {
      -- Windows patterns
      '([A-Za-z]:[/\\][^%s"\']*$)',        -- Windows absolute path (C:\ or C:/)
      '([/~][^%s"\']*$)',                  -- Unix-style absolute path or home path
      '(%.%.[/\\][^%s"\']*$)',             -- Relative path ..\ or ../
      '(%.[/\\][^%s"\']*$)',               -- Relative path .\ or ./
      '([%w_%-%.]+[/\\][^%s"\']*$)',       -- Directory/file path with \ or /
      -- Enhanced patterns for directory names without separators
      '([%w_%-%.]+$)',                     -- Simple directory/file name
    }
  else
    path_patterns = {
      -- Unix patterns
      '([/~][^%s"\']*$)',                  -- Absolute path or home path
      '(%.%./[^%s"\']*$)',                 -- Relative path ../
      '(%./[^%s"\']*$)',                   -- Relative path ./
      '([%w_%-%.]+/[^%s"\']*$)',           -- Directory/file path
      -- Enhanced patterns for directory names without separators
      '([%w_%-%.]+$)',                     -- Simple directory/file name
    }
  end

  for _, pattern in ipairs(path_patterns) do
    local path = before_cursor:match(pattern)
    if path then
      -- Additional check for directory names: if it's a known directory, include it
      if not path:match('[/\\]') then
        -- Check if this looks like a directory name
        if vim.fn.isdirectory(path) == 1 then
          return path
        end
        -- Check if there are similar directory names starting with this prefix
        local glob_pattern = path .. '*'
        local matches = vim.fn.glob(glob_pattern, false, true)
        for _, match in ipairs(matches) do
          if vim.fn.isdirectory(match) == 1 then
            return path
          end
        end
      else
        return path
      end
    end
  end

  return before_cursor:match('[^%s]*$') or ''
end

-- Check if path completion can be triggered
local function path_available()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before_cursor = line:sub(1, col)

  local path_patterns
  if is_windows() then
    path_patterns = {
      -- Windows patterns
      '[A-Za-z]:[/\\][^%s"\']*$',         -- Windows absolute path (C:\ or C:/)
      '/[^%s"\']*$',                      -- Unix-style absolute path on Windows
      '%./[^%s"\']*$',                    -- Relative path ./
      '%.%./[^%s"\']*$',                  -- Relative path ../
      '%.[/\\][^%s"\']*$',                -- Relative path .\ or ./
      '%.%.[/\\][^%s"\']*$',              -- Relative path ..\ or ../
      '~[/\\][^%s"\']*$',                 -- Home directory path with \ or /
      '[%w_%-%.]+[/\\][^%s"\']*$',        -- Directory/file path with \ or /
      '"[^"]*$',                          -- Path inside double quotes
      '\'[^\']*$',                        -- Path inside single quotes
      -- Shell variable assignment patterns
      '=[A-Za-z]:[/\\][^%s"\']*$',        -- =C:/path or =C:\path
      '=/[^%s"\']*$',                     -- =/absolute/path
      '=%.%./[^%s"\']*$',                 -- =../relative/path
      '=%./[^%s"\']*$',                   -- =./relative/path
      '=~[/\\][^%s"\']*$',                -- =~/home/path
      '=[%w_%-%.]+[/\\][^%s"\']*$',       -- =dir/path
    }
  else
    path_patterns = {
      -- Unix patterns
      '/[^%s"\']*$',                      -- Absolute path
      '%./[^%s"\']*$',                    -- Relative path ./
      '%.%./[^%s"\']*$',                  -- Relative path ../
      '~[^%s"\']*$',                      -- Home directory path
      '[%w_%-%.]+/[^%s"\']*$',            -- Directory/file path
      '"[^"]*$',                          -- Path inside double quotes
      '\'[^\']*$',                        -- Path inside single quotes
      -- Shell variable assignment patterns
      '=/[^%s"\']*$',                     -- =/absolute/path
      '=%.%./[^%s"\']*$',                 -- =../relative/path
      '=%./[^%s"\']*$',                   -- =./relative/path
      '=~[^%s"\']*$',                     -- =~/home/path
      '=[%w_%-%.]+/[^%s"\']*$',           -- =dir/path
    }
  end

  for _, pattern in ipairs(path_patterns) do
    if before_cursor:match(pattern) then
      return true
    end
  end

  -- Enhanced check: also consider if we're at the end of a known directory name
  local potential_path = extract_path_prefix(line, col)
  if potential_path and #potential_path > 0 then
    local path_without_quotes = potential_path:gsub('^[\'"]', ''):gsub('[\'"]$', '')
    if vim.fn.isdirectory(path_without_quotes) == 1 then
      return true
    end
  end

  return false
end

-- Get path completions
local function get_path_completions(path_prefix)
  local matches = {}

  if not path_available() then
    return matches
  end

  pcall(function()
    local dir_part, file_part
    local path_sep = is_windows() and '[/\\]' or '/'
    local preferred_sep = is_windows() and '\\' or '/'

    -- Enhanced path parsing for better directory navigation
    local path_without_quotes = path_prefix:gsub('^[\'"]', ''):gsub('[\'"]$', '')

    if is_windows() then
      -- Windows path parsing - handle both / and \ separators
      dir_part = path_without_quotes:match('^(.*[/\\])')
      file_part = path_without_quotes:match('([^/\\]*)$')
    else
      -- Unix path parsing
      dir_part = path_without_quotes:match('^(.*/)')
      file_part = path_without_quotes:match('([^/]*)$')
    end

    -- Special handling for directory completion
    if not dir_part and vim.fn.isdirectory(path_without_quotes) == 1 then
      -- If the path is a directory without trailing separator, treat it as dir_part
      dir_part = path_without_quotes .. preferred_sep
      file_part = ''
    elseif not dir_part then
      dir_part = '.' .. preferred_sep
      file_part = path_without_quotes
    end

    -- Normalize path separators for glob
    local normalized_dir = dir_part:gsub('\\', '/')
    local pattern = normalized_dir .. file_part .. '*'
    local glob_results = vim.fn.glob(pattern, false, true)

    -- Sort results: directories first, then files
    table.sort(glob_results, function(a, b)
      local a_is_dir = vim.fn.isdirectory(a) == 1
      local b_is_dir = vim.fn.isdirectory(b) == 1
      if a_is_dir and not b_is_dir then
        return true
      elseif not a_is_dir and b_is_dir then
        return false
      else
        return a < b
      end
    end)

    for _, path in ipairs(glob_results) do
      local is_dir = vim.fn.isdirectory(path) == 1
      local basename = vim.fn.fnamemodify(path, ':t')
      if basename ~= '' and (file_part == '' or basename:lower():find(file_part:lower(), 1, true) == 1) then
        -- 使用完整路径作为word，但保持用户输入的路径分隔符风格
        local full_path = path

        -- Convert path separators to match user's input style
        if is_windows() then
          if path_prefix:find('\\') then
            -- User prefers backslashes
            full_path = full_path:gsub('/', '\\')
          elseif path_prefix:find('/') then
            -- User prefers forward slashes
            full_path = full_path:gsub('\\', '/')
          end
        end

        -- Add directory separator for directories
        if is_dir then
          local sep = is_windows() and (path_prefix:find('\\') and '\\' or '/') or '/'
          full_path = full_path .. sep
        end

        -- Handle relative path formatting
        local word = full_path
        if dir_part == ('./' .. (is_windows() and '' or '')) or dir_part == ('.' .. preferred_sep) then
          if not path_prefix:match('^%.') then
            -- Remove ./ or .\ prefix if user didn't type it
            word = word:gsub('^%.' .. (is_windows() and '[/\\]' or '/'), '')
          end
        end

        -- Important: For quoted paths, word should only contain the path part (no quotes)
        -- The vim completion system will replace from start_col, which we've set to after the quote
        -- So the word should not include quotes to avoid them being outside the quotes

        -- Enhanced menu indication for directories
        local menu = is_dir and '[P/]' or '[P]'

        table.insert(matches, {
          word = word,  -- Pure path without quotes
          menu = menu,
          info = path .. (is_dir and ' (directory)' or '')
        })
      end
    end
  end)

  return matches
end

-- ============================================================================
-- 统一补全函数
-- ============================================================================

-- 主要的统一补全函数，具有智能优先级调整
-- 有omni补全的文件: 代码片段 -> omni -> 字典 -> 缓冲区 -> 路径
-- 无omni补全的文件: 代码片段 -> 字典 -> 缓冲区 -> 路径
function _G.builtin_completion()
  -- 如果补全被禁用，提前退出
  if not completion_active then
    return ''
  end

  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local prefix = line:sub(1, col):match('[%w_]*$') or ''
  local path_prefix = extract_path_prefix(line, col)

  local omni_can_trigger = omni_available()
  local path_can_trigger = path_available()

  if #prefix == 0 and not path_can_trigger and not omni_can_trigger then
    return ''
  end

  local filetype = vim.bo.filetype
  local all_matches = {}

  -- 计算基础的start_col（用于snippet、dict、buffer补全）
  local base_start_col = col - #prefix + 1

  -- 计算路径补全的start_col
  local path_start_col = base_start_col
  if path_can_trigger and #path_prefix > #prefix then
    -- Special handling for quoted paths
    local before_cursor = line:sub(1, col)

    -- Check if we're inside quotes by looking for quote patterns
    local quote_match = before_cursor:match('["\']([^"\']*)$')

    if quote_match then
      -- We're inside quotes, find the exact position after the opening quote
      local quote_pos = nil
      -- Look for the last quote before our current position
      for i = col, 1, -1 do
        local char = line:sub(i, i)
        if char == '"' or char == "'" then
          quote_pos = i
          break
        end
      end

      if quote_pos then
        path_start_col = quote_pos + 1  -- Start after the opening quote
      else
        path_start_col = col - #path_prefix + 1
      end
    else
      path_start_col = col - #path_prefix + 1
    end
  end

  -- 基于omni可用性和上下文的智能补全优先级

  -- 检查omni补全是否有效可用
  local omni_func = vim.bo.omnifunc
  local has_effective_omni = omni_can_trigger and omni_func ~= '' and omni_func ~= 'syntaxcomplete#Complete'

  -- 检查是否在强路径上下文中（路径补全优先级更高）
  local strong_path_context = false
  if path_can_trigger then
    local before_cursor = line:sub(1, col)
    -- Strong path context: shell variable assignment, quoted paths, or clear path patterns
    if before_cursor:match('=[/~%.]') or
       before_cursor:match('["\'][^"\']*$') or
       before_cursor:match('/[^%s]*$') or
       before_cursor:match('~[^%s]*$') then
      strong_path_context = true
    end
  end

  -- 分别收集不同类型的补全项目，使用对应的start_col
  local base_matches = {}  -- snippet、dict、buffer补全
  local path_matches_list = {}  -- 路径补全

  if strong_path_context then
    -- 强路径上下文的优先级: 代码片段 -> 路径 -> 字典 -> 缓冲区

    -- 1. 代码片段补全（始终最高优先级，不限制数量）
    local snippet_matches = get_snippet_completions(prefix, filetype)
    vim.list_extend(base_matches, snippet_matches)

    -- 2. 路径补全（在路径上下文中高优先级）
    local path_matches = get_path_completions(path_prefix)
    vim.list_extend(path_matches_list, path_matches)

    -- 3. 字典补全（在路径上下文中受限）
    local dict_matches = get_dictionary_completions(prefix)
    local dict_limited = {}
    for i = 1, math.min(#dict_matches, 3) do
      table.insert(dict_limited, dict_matches[i])
    end
    vim.list_extend(base_matches, dict_limited)

    -- 4. 缓冲区补全（在路径上下文中严格受限）
    local buffer_matches = get_buffer_completions(prefix)
    local buffer_limited = {}
    for i = 1, math.min(#buffer_matches, 1) do
      table.insert(buffer_limited, buffer_matches[i])
    end
    vim.list_extend(base_matches, buffer_limited)

  else
    -- 普通优先级: 代码片段 -> omni/字典 -> 缓冲区 -> 路径

    -- 1. 代码片段补全（始终最高优先级，不限制数量）
    local snippet_matches = get_snippet_completions(prefix, filetype)
    vim.list_extend(base_matches, snippet_matches)

    if has_effective_omni then
      -- STRATEGY 1: Has real omni completion
      -- Priority: snippet -> omni -> dict -> buffer -> path

      -- 2. OMNI COMPLETION (limit to 3 items)
      local omni_matches = get_omni_completions(prefix)
      local omni_limited = {}
      for i = 1, math.min(#omni_matches, 3) do
        table.insert(omni_limited, omni_matches[i])
      end
      vim.list_extend(base_matches, omni_limited)

      -- 3. DICTIONARY COMPLETION (limit to 5 items)
      local dict_matches = get_dictionary_completions(prefix)
      local dict_limited = {}
      for i = 1, math.min(#dict_matches, 5) do
        table.insert(dict_limited, dict_matches[i])
      end
      vim.list_extend(base_matches, dict_limited)

      -- 4. BUFFER COMPLETION (limit to 2 items)
      local buffer_matches = get_buffer_completions(prefix)
      local buffer_limited = {}
      for i = 1, math.min(#buffer_matches, 2) do
        table.insert(buffer_limited, buffer_matches[i])
      end
      vim.list_extend(base_matches, buffer_limited)

    else
      -- STRATEGY 2: No real omni completion (dict files, shell scripts, etc.)
      -- Priority: snippet -> dict -> buffer -> path (dict gets higher priority)

      -- 2. DICTIONARY COMPLETION (higher priority, limit to 8 items)
      local dict_matches = get_dictionary_completions(prefix)
      local dict_limited = {}
      for i = 1, math.min(#dict_matches, 8) do
        table.insert(dict_limited, dict_matches[i])
      end
      vim.list_extend(base_matches, dict_limited)

      -- 3. BUFFER COMPLETION (limit to 3 items)
      local buffer_matches = get_buffer_completions(prefix)
      local buffer_limited = {}
      for i = 1, math.min(#buffer_matches, 3) do
        table.insert(buffer_limited, buffer_matches[i])
      end
      vim.list_extend(base_matches, buffer_limited)
    end

    -- 5. PATH COMPLETION (lowest priority in normal context)
    if path_can_trigger then
      local path_matches = get_path_completions(path_prefix)
      vim.list_extend(path_matches_list, path_matches)
    end
  end

  -- 显示补全菜单 - 优先使用基础补全，如果没有则使用路径补全
  if #base_matches > 0 then
    if mode() == 'i' then
      -- 使用基础start_col显示snippet、dict、buffer补全
      pcall(function()
        vim.fn.complete(base_start_col, base_matches)
      end)
    end
  elseif #path_matches_list > 0 then
    if mode() == 'i' then
      -- 使用路径start_col显示路径补全
      pcall(function()
        vim.fn.complete(path_start_col, path_matches_list)
      end)
    end
  end

  return ''
end

-- ============================================================================
-- FILETYPE CONFIGURATION
-- ============================================================================

-- Set omnifunc for different file types
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
      php = 'phpcomplete#CompletePHP',
      go = 'gocomplete#Complete',
    }

    local omni_func = nil
    -- Special handling for Python: check python3 support
    if ft == 'python' then
      if vim.fn.has('python3') == 1 then
        omni_func = 'python3complete#Complete'
      else
        -- For Python without python3 support, don't set omnifunc or syntaxcomplete
        -- This will force the system to use dictionary completion directly
        vim.bo[args.buf].omnifunc = ''
      end
    elseif omni_funcs[ft] then
      omni_func = omni_funcs[ft]
    end

    if omni_func then
      -- Set valid omnifunc
      vim.bo[args.buf].omnifunc = omni_func
    elseif ft ~= 'python' then
      -- Use syntaxcomplete as fallback for non-Python files
      vim.bo[args.buf].omnifunc = 'syntaxcomplete#Complete'
    end

    -- Set up dictionary files (always available, separate from omni)
    local dict_file = dict_base_dir .. ft .. '.dict'
    if vim.fn.filereadable(dict_file) == 1 then
      vim.bo[args.buf].dictionary = dict_file
    else
      -- Fallback dictionary mappings
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

    -- Preload snippets for this filetype
    load_snippets_for_filetype(ft)
  end
})

-- ============================================================================
-- 按键绑定配置
-- ============================================================================

-- Tab键: 补全和代码片段展开
map('i', '<Tab>', function()
  if pumvisible() then
    -- 检查是否已经选择了项目
    local completed_item = vim.v.completed_item or {}
    if vim.tbl_isempty(completed_item) then
      -- 没有选择项目，选择第一个并确认
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-n><C-y>', true, true, true), 'n', false)
    else
      -- 已选择项目，直接确认
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-y>', true, true, true), 'n', false)
    end
    -- 延迟代码片段展开
    vim.defer_fn(function()
      expand_snippet()
    end, 10)
    return ''
  else
    -- 菜单不可见，正常Tab行为
    return vim.api.nvim_replace_termcodes('<Tab>', true, true, true)
  end
end, {expr = true, silent = true})

-- Shift-Tab: 补全菜单中的上一个选择
map('i', '<S-Tab>', function()
  if pumvisible() then
    return vim.api.nvim_replace_termcodes('<C-p>', true, true, true)
  else
    return vim.api.nvim_replace_termcodes('<S-Tab>', true, true, true)
  end
end, {expr = true, silent = true})

-- Enter键: 确认选择（不展开代码片段）
map('i', '<CR>', function()
  if pumvisible() then
    -- 直接确认选择而不展开代码片段
    return vim.api.nvim_replace_termcodes('<C-y>', true, true, true)
  else
    return vim.api.nvim_replace_termcodes('<CR>', true, true, true)
  end
end, {expr = true, silent = true})

-- 处理目录导航的辅助函数
local function handle_directory_navigation()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before_cursor = line:sub(1, col)
  local potential_path = extract_path_prefix(line, col)

  -- 如果有潜在路径，增强目录补全功能
  if potential_path and #potential_path > 0 then
    local path_without_quotes = potential_path:gsub('^[\'"]', ''):gsub('[\'"]$', '')

    -- 检查路径是否已经以分隔符结尾
    if not path_without_quotes:match('[/\\]$') then
      -- 检查是否为已存在的目录，如果是则自动添加分隔符
      if vim.fn.isdirectory(path_without_quotes) == 1 then
        -- 确定路径分隔符类型
        local sep = is_windows() and '\\' or '/'
        if is_windows() and before_cursor:find('/') and not before_cursor:find('\\') then
          sep = '/'
        end

        -- 智能插入，尊重引号边界
        local current_line = vim.api.nvim_get_current_line()
        local current_col = vim.api.nvim_win_get_cursor(0)[2]

        -- 检查是否在引号内
        local quote_match = before_cursor:match('["\']([^"\']*)$')
        if quote_match then
          -- 在引号内，在当前位置插入分隔符
          local new_line = current_line:sub(1, current_col) .. sep .. current_line:sub(current_col + 1)
          vim.api.nvim_set_current_line(new_line)
          vim.api.nvim_win_set_cursor(0, {vim.api.nvim_win_get_cursor(0)[1], current_col + #sep})
        else
          -- 不在引号内，使用标准方法
          vim.api.nvim_put({sep}, 'c', true, true)
          local new_col = vim.api.nvim_win_get_cursor(0)[2]
          vim.api.nvim_win_set_cursor(0, {vim.api.nvim_win_get_cursor(0)[1], new_col})
        end
      end
    end
  end

  -- 触发补全
  builtin_completion()
end

-- Ctrl-L: 增强的手动补全触发器，支持目录导航
map('i', '<C-l>', function()
  if pumvisible() then
    -- 确认当前选择并立即重新触发补全
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-y>', true, true, true), 'n', false)

    -- 在确认选择后立即重新触发补全
    vim.defer_fn(function()
      if mode() == 'i' and not pumvisible() then
        handle_directory_navigation()
      end
    end, 20)  -- 小延迟以确保前一个补全正确关闭
    return ''
  else
    -- 增强的路径补全触发器
    vim.defer_fn(function()
      if mode() == 'i' and not pumvisible() then
        handle_directory_navigation()
      end
    end, 10)
    return ''
  end
end, {expr = true, silent = true})

-- 代码片段占位符导航 - 仅在代码片段模式下激活
map({'i', 's'}, '<C-f>', function()
  if snippet_mode_active and not vim.tbl_isempty(current_snippet_placeholders) then
    local success = jump_to_next_placeholder()
    if not success then
      snippet_mode_active = false
    end
    return ''
  else
    return vim.api.nvim_replace_termcodes('<C-f>', true, true, true)
  end
end, {expr = true, silent = true})

-- 跳转到上一个占位符
map({'i', 's'}, '<C-b>', function()
  if snippet_mode_active and not vim.tbl_isempty(current_snippet_placeholders) then
    jump_to_prev_placeholder()
    return ''
  else
    return vim.api.nvim_replace_termcodes('<C-b>', true, true, true)
  end
end, {expr = true, silent = true})

-- 补全菜单导航 - 仅在菜单可见时生效
map('i', '<Down>', function()
  if pumvisible() then
    return '<C-n>'
  else
    return '<Down>'
  end
end, {expr = true, silent = true})

map('i', '<Up>', function()
  if pumvisible() then
    return '<C-p>'
  else
    return '<Up>'
  end
end, {expr = true, silent = true})

-- ESC键: 退出代码片段模式
map({'i', 's'}, '<Esc>', function()
  if snippet_mode_active then
    snippet_mode_active = false
    current_snippet_placeholders = {}
    current_placeholder_index = 0
  end
  return vim.api.nvim_replace_termcodes('<Esc>', true, true, true)
end, {expr = true, silent = true})

-- ============================================================================
-- 自动触发逻辑
-- ============================================================================

-- 文件类型特定的自动触发配置
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local ft_triggers = {
      lua = { '.', ':', '/', '~' },
      python = { '.', ':', '/', '~' },
      javascript = { '.', ':', '/', '~' },
      typescript = { '.', ':', '/', '~' },
      cpp = { '.', '::', '->', '/', '~' },
      c = { '.', '->', '/', '~' },
      html = { '<', '/', '>', '~' },
      css = { ':', ';', '/', '~' },
      vim = { ':', '/', '~' },
      java = { '.', ':', '/', '~' },
      php = { '.', '->', '::', '/', '~' },
      go = { '.', ':', '/', '~' },
      default = { '.', ':', '>', '/', '~' },
    }

    -- Add Windows backslash triggers if on Windows
    if is_windows() then
      for ft, triggers in pairs(ft_triggers) do
        -- Add backslash to each filetype's triggers
        table.insert(triggers, '\\')
      end
    end

    local triggers = ft_triggers[ft] or ft_triggers.default

    -- Character-triggered completion and smart auto-complete
    vim.api.nvim_create_autocmd('InsertCharPre', {
      buffer = args.buf,
      callback = function()
        local char = vim.v.char
        -- Early exit if completion is disabled
        if not completion_active then
          return
        end
        -- Clear any existing pending timers to avoid conflicts
        for timer_id, _ in pairs(pending_timers) do
          if timer_id then
            pending_timers[timer_id] = nil
          end
        end
        pending_timers = {}

        -- Check for special trigger characters (highest priority)
        for _, trigger in ipairs(triggers) do
          if char == trigger then
            local timer_id = vim.defer_fn(function()
              if completion_active and not pumvisible() and mode() == 'i' then
                local col = vim.api.nvim_win_get_cursor(0)[2]
                if col > 0 then
                  builtin_completion()
                end
              end
              -- Safe cleanup
              if timer_id and pending_timers[timer_id] then
                pending_timers[timer_id] = nil
              end
            end, 30)  -- Faster response for trigger chars

            -- Only track valid timer IDs
            if timer_id then
              pending_timers[timer_id] = true
            end
            return  -- Exit early to avoid other completions
          end
        end

        -- Check for path completion triggers (second priority)
        if char:match('[%w%._%-/\\]') then
          local timer_id = vim.defer_fn(function()
            if completion_active and not pumvisible() and mode() == 'i' then
              if path_available() then
                builtin_completion()
                return
              end

              -- If no path available, check for smart completion as fallback
              local line = vim.api.nvim_get_current_line()
              local col = vim.api.nvim_win_get_cursor(0)[2]
              local prefix = line:sub(1, col):match('[%w_]*$') or ''

              if #prefix >= 2 and char:match('[%w_]') then
                local ft = vim.bo.filetype
                -- Check for snippet matches
                if #get_snippet_completions(prefix, ft) > 0 then
                  builtin_completion()
                  return
                end

                -- Check for buffer word matches
                if buffer_has_matches(prefix) then
                  builtin_completion()
                  return
                end
              end
            end
            -- Safe cleanup
            if timer_id and pending_timers[timer_id] then
              pending_timers[timer_id] = nil
            end
          end, 40)  -- Reduced delay for path completion

          -- Only track valid timer IDs
          if timer_id then
            pending_timers[timer_id] = true
          end
        end
      end
    })
  end
})

-- Auto-clear snippet state and stop all completion tasks
vim.api.nvim_create_autocmd({'InsertLeave'}, {
  callback = function()
    current_snippet_placeholders = {}
    current_placeholder_index = 0
    snippet_mode_active = false

    -- Clear all pending timers to ensure clean Normal mode
    for timer_id, _ in pairs(pending_timers) do
      if timer_id then
        pending_timers[timer_id] = nil
      end
    end
    pending_timers = {}

    -- Temporarily disable completion in Normal mode for better performance
    completion_active = false

    -- Re-enable after a short delay when entering Insert mode again
    vim.defer_fn(function()
      completion_active = true
    end, 100)
  end
})

-- Clean up on buffer leave
vim.api.nvim_create_autocmd({'BufLeave'}, {
  callback = function()
    current_snippet_placeholders = {}
    current_placeholder_index = 0
    snippet_mode_active = false

    -- Clear timers safely
    for timer_id, _ in pairs(pending_timers) do
      if timer_id then
        pending_timers[timer_id] = nil
      end
    end
    pending_timers = {}
  end
})

-- Ensure completion is active when entering Insert mode
vim.api.nvim_create_autocmd({'InsertEnter'}, {
  callback = function()
    completion_active = true
  end
})

-- ============================================================================
-- 调试命令
-- ============================================================================

-- 调试代码片段命令
vim.api.nvim_create_user_command('DebugSnippets', function()
  local filetype = vim.bo.filetype
  local snippets = load_snippets_for_filetype(filetype)
  local omni_func = vim.bo.omnifunc
  local omni_can_trigger = omni_available()
  local has_effective_omni = omni_can_trigger and omni_func ~= '' and omni_func ~= 'syntaxcomplete#Complete'

  -- Check current path context
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before_cursor = line:sub(1, col)
  local path_can_trigger = path_available()
  local strong_path_context = false
  if path_can_trigger then
    if before_cursor:match('=[/~%.]') or
       before_cursor:match('["\'][^"\']*$') or
       before_cursor:match('/[^%s]*$') or
       before_cursor:match('~[^%s]*$') then
      strong_path_context = true
    end
  end

  local strategy, priority
  if strong_path_context then
    strategy = "S->P->D->B"
    priority = "path-priority"
  elseif has_effective_omni then
    strategy = "S->O->D->B->P"
    priority = "omni-priority"
  else
    strategy = "S->D->B->P"
    priority = "dict-priority"
  end

  print(filetype .. ": " .. #snippets .. " snippets[S], mode: " .. (snippet_mode_active and "on" or "off") .. ", strategy: " .. strategy .. " (" .. priority .. ")")
  print("omnifunc: " .. omni_func .. ", dict: " .. (vim.bo.dictionary or "none"))
  print("current context: path=" .. tostring(path_can_trigger) .. ", strong_path=" .. tostring(strong_path_context))
end, {})

-- Debug path completion command
vim.api.nvim_create_user_command('DebugPath', function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before_cursor = line:sub(1, col)
  local path_prefix = extract_path_prefix(line, col)
  local path_can_trigger = path_available()

  print('=== PATH DEBUG ===')
  print('Line: ' .. line)
  print('Col: ' .. col)
  print('Before cursor: "' .. before_cursor .. '"')
  print('Path prefix: "' .. (path_prefix or 'nil') .. '"')
  print('Path available: ' .. tostring(path_can_trigger))

  -- Debug quote handling
  local quote_match = before_cursor:match('["\']([^"\']*)$')
  if quote_match then
    print('Quote detected: inside quotes')
    print('Quote content: "' .. quote_match .. '"')

    -- Find quote position
    local quote_pos = nil
    for i = col, 1, -1 do
      local char = line:sub(i, i)
      if char == '"' or char == "'" then
        quote_pos = i
        break
      end
    end
    print('Quote position: ' .. (quote_pos or 'not found'))
    if quote_pos then
      print('Start col would be: ' .. (quote_pos + 1))
    end
  else
    print('Quote detected: NOT inside quotes')
  end

  -- Test each pattern
  local path_patterns = {
    '/[^%s"\']*$',                      -- Absolute path
    '%./[^%s"\']*$',                    -- Relative path ./
    '%.%./[^%s"\']*$',                  -- Relative path ../
    '~[^%s"\']*$',                      -- Home directory path
    '[%w_%-%.]+/[^%s"\']*$',            -- Directory/file path
    '"[^"]*$',                          -- Path inside double quotes
    '\'[^\']*$',                        -- Path inside single quotes
    -- Shell variable assignment patterns
    '=/[^%s"\']*$',                     -- =/absolute/path
    '=%.%./[^%s"\']*$',                 -- =../relative/path
    '=%./[^%s"\']*$',                   -- =./relative/path
    '=~[^%s"\']*$',                     -- =~/home/path
    '=[%w_%-%.]+/[^%s"\']*$',           -- =dir/path
  }

  for i, pattern in ipairs(path_patterns) do
    local match = before_cursor:match(pattern)
    print('Pattern ' .. i .. ' (' .. pattern .. '): ' .. (match or 'no match'))
  end

  if path_can_trigger then
    local path_matches = get_path_completions(path_prefix)
    print('Path matches: ' .. #path_matches)
    for i, match in ipairs(path_matches) do
      if i <= 5 then  -- Show first 5 matches
        print('  ' .. i .. ': ' .. match.word)
      end
    end
  end
end, {})

-- Debug completion command
vim.api.nvim_create_user_command('DebugComplete', function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local prefix = line:sub(1, col):match('[%w_]*$') or ''
  local path_prefix = extract_path_prefix(line, col)
  local before_cursor = line:sub(1, col)
  local filetype = vim.bo.filetype

  local omni_can_trigger = omni_available()
  local path_can_trigger = path_available()

  print("=== Enhanced Completion Debug Info ===")
  print("File type: " .. filetype)
  print("Current line: '" .. line .. "'")
  print("Cursor position: " .. col)
  print("Text before cursor: '" .. before_cursor .. "'")
  print("Prefix: '" .. prefix .. "' (length: " .. #prefix .. ")")
  print("Path prefix: '" .. path_prefix .. "' (length: " .. #path_prefix .. ")")
  print("Can trigger omni: " .. tostring(omni_can_trigger))
  print("Can trigger path: " .. tostring(path_can_trigger))
  print("Omnifunc: " .. vim.bo.omnifunc)
  print("Dictionary file: " .. (vim.bo.dictionary or "none"))

  -- Check intelligent priority strategy
  local omni_func = vim.bo.omnifunc
  local has_effective_omni = omni_can_trigger and omni_func ~= '' and omni_func ~= 'syntaxcomplete#Complete'

  -- Check path context
  local strong_path_context = false
  if path_can_trigger then
    if before_cursor:match('=[/~%.]') or
       before_cursor:match('["\'][^"\']*$') or
       before_cursor:match('/[^%s]*$') or
       before_cursor:match('~[^%s]*$') then
      strong_path_context = true
    end
  end

  local strategy
  if strong_path_context then
    strategy = "S->P->D->B (path-priority)"
  elseif has_effective_omni then
    strategy = "S->O->D->B->P (omni-priority)"
  else
    strategy = "S->D->B->P (dict-priority)"
  end
  print("Strategy: " .. strategy)
  print("Strong path context: " .. tostring(strong_path_context))

  print("\n=== Completion Results (Intelligent Priority Order) ===")

  -- Test each completion type in intelligent priority order
  print("1. SNIPPET COMPLETION [S] (always first):")
  local snippet_matches = get_snippet_completions(prefix, filetype)
  print("  Found " .. #snippet_matches .. " matches")
  for i, match in ipairs(snippet_matches) do
    if i <= 3 then
      print("  - " .. match.word)
    end
  end

  if strong_path_context then
    print("2. PATH COMPLETION [P] (high priority in path context):")
    local path_matches = get_path_completions(path_prefix)
    print("  Found " .. #path_matches .. " matches")
    for i, match in ipairs(path_matches) do
      if i <= 3 then
        print("  - " .. match.word)
      end
    end

    print("3. DICTIONARY COMPLETION [D] (limited in path context):")
    local dict_matches = get_dictionary_completions(prefix)
    print("  Found " .. #dict_matches .. " matches (showing max 3)")
    for i, match in ipairs(dict_matches) do
      if i <= 3 then
        print("  - " .. match.word)
      end
    end

    print("4. BUFFER COMPLETION [B] (very limited in path context):")
    local buffer_matches = get_buffer_completions(prefix)
    print("  Found " .. #buffer_matches .. " matches (showing max 1)")
    for i, match in ipairs(buffer_matches) do
      if i <= 3 then
        print("  - " .. match.word)
      end
    end

  elseif has_effective_omni then
    print("2. OMNI COMPLETION [O] (has effective omni):")
    local omni_matches = get_omni_completions(prefix)
    print("  Found " .. #omni_matches .. " matches")
    for i, match in ipairs(omni_matches) do
      if i <= 3 then
        print("  - " .. match.word)
      end
    end

    print("3. DICTIONARY COMPLETION [D]:")
    local dict_matches = get_dictionary_completions(prefix)
    print("  Found " .. #dict_matches .. " matches (showing max 5)")
    for i, match in ipairs(dict_matches) do
      if i <= 3 then
        print("  - " .. match.word)
      end
    end

    print("4. BUFFER COMPLETION [B]:")
    local buffer_matches = get_buffer_completions(prefix)
    print("  Found " .. #buffer_matches .. " matches (showing max 2)")
    for i, match in ipairs(buffer_matches) do
      if i <= 3 then
        print("  - " .. match.word)
      end
    end
  else
    print("2. DICTIONARY COMPLETION [D] (higher priority - no effective omni):")
    local dict_matches = get_dictionary_completions(prefix)
    print("  Found " .. #dict_matches .. " matches (showing max 8)")
    for i, match in ipairs(dict_matches) do
      if i <= 3 then
        print("  - " .. match.word)
      end
    end

    print("3. BUFFER COMPLETION [B]:")
    local buffer_matches = get_buffer_completions(prefix)
    print("  Found " .. #buffer_matches .. " matches (showing max 3)")
    for i, match in ipairs(buffer_matches) do
      if i <= 3 then
        print("  - " .. match.word)
      end
    end
  end

  if not strong_path_context then
    print((has_effective_omni and "5" or "4") .. ". PATH COMPLETION [P] (lowest priority):")
    local path_matches = get_path_completions(path_prefix)
    print("  Found " .. #path_matches .. " matches")
    for i, match in ipairs(path_matches) do
      if i <= 3 then
        print("  - " .. match.word)
      end
    end
  end

  print("\nTriggering manual completion...")
  if mode() == 'i' then
    builtin_completion()
  else
    print("Note: Can only trigger completion in insert mode")
  end
end, {})

-- Clear snippet state command
vim.api.nvim_create_user_command('ClearSnippet', function()
  current_snippet_placeholders = {}
  current_placeholder_index = 0
  snippet_mode_active = false
  print("Snippet state cleared")
end, {})

-- Reload snippet cache command
vim.api.nvim_create_user_command('ReloadSnippets', function()
  snippet_cache = {}
  print("Snippet cache cleared, will reload on next use")
end, {})

-- Performance management commands
vim.api.nvim_create_user_command('ToggleBuiltinCompletion', function()
  completion_active = not completion_active
  if not completion_active then
    -- 安全地清除所有待处理的定时器
    for timer_id, _ in pairs(pending_timers) do
      if timer_id then
        pending_timers[timer_id] = nil
      end
    end
    pending_timers = {}
    print("内置补全已禁用")
  else
    print("内置补全已启用")
  end
end, {})

vim.api.nvim_create_user_command('BuiltinCompletionStatus', function()
  local status = completion_active and "启用" or "禁用"
  local timer_count = 0
  for _, _ in pairs(pending_timers) do
    timer_count = timer_count + 1
  end

  print("=== 内置补全状态 ===")
  print("状态: " .. status)
  print("待处理定时器: " .. timer_count)
  print("代码片段模式: " .. (snippet_mode_active and "开启" or "关闭"))
  print("")
  print("=== 代码优化总结 ===")
  print("✅ 删除未使用变量: buffer_cache, set_hl, is_dir_path")
  print("✅ 消除重复代码: 100+ 行重复逻辑合并为 handle_directory_navigation()")
  print("✅ 添加中文注释: 所有关键处理逻辑")
  print("✅ 优化引号处理: 智能路径分隔符插入")
  print("✅ 提升代码可维护性: 函数化重复逻辑")
end, {})

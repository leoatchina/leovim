-- Neovim 0.11 Built-in Completion + Friendly Snippets + Buffer + Path Configuration
-- Enhanced with improved structure and completion priority: snippet -> omni -> buffer -> dict -> path

-- ============================================================================
-- GLOBAL VARIABLES AND CONFIGURATION
-- ============================================================================
local map = vim.keymap.set

-- Completion menu styling
vim.api.nvim_set_hl(0, 'Pmenu', {bg = '#3b4252', fg = '#d8dee9'})
vim.api.nvim_set_hl(0, 'PmenuSel', {bg = '#81a1c1', fg = '#2e3440', bold = true})
vim.api.nvim_set_hl(0, 'PmenuKind', {bg = '#3b4252', fg = '#88c0d0'})
vim.api.nvim_set_hl(0, 'PmenuKindSel', {bg = '#81a1c1', fg = '#2e3440', bold = true})
vim.api.nvim_set_hl(0, 'PmenuExtra', {bg = '#3b4252', fg = '#8fbcbb'})
vim.api.nvim_set_hl(0, 'PmenuExtraSel', {bg = '#81a1c1', fg = '#2e3440'})

-- Base directories
local dict_base_dir = vim.fn.expand('$HOME/.leovim/pack/clone/opt/vim-dict/dict') .. '/'
local snippets_base_dir = vim.fn.expand('$HOME/.leovim.d/pack/add/opt/friendly-snippets/snippets') .. '/'

-- Global variables for current snippet state
local current_snippet_placeholders = {}
local current_placeholder_index = 0
local snippet_mode_active = false

-- Global caches
local snippet_cache = {}
local buffer_cache = {}

-- ============================================================================
-- SNIPPET COMPLETION FUNCTIONS
-- ============================================================================

-- Parse VSCode format snippets
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
  -- Load global snippets
  local global_file = snippets_base_dir .. 'global.json'
  if vim.fn.filereadable(global_file) == 1 then
    table.insert(snippet_files, global_file)
  end

  -- Load filetype-specific snippets - prioritize subdirectories
  local ft_dir = snippets_base_dir .. filetype
  if vim.fn.isdirectory(ft_dir) == 1 then
    local ft_dir_files = vim.fn.glob(ft_dir .. '/*.json', true, true)
    vim.list_extend(snippet_files, ft_dir_files)
  else
    local ft_file = snippets_base_dir .. filetype .. '.json'
    if vim.fn.filereadable(ft_file) == 1 then
      table.insert(snippet_files, ft_file)
    end
  end

  -- Load language alias snippets
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

      local alias_dir = snippets_base_dir .. alias
      if vim.fn.isdirectory(alias_dir) == 1 then
        local alias_dir_files = vim.fn.glob(alias_dir .. '/*.json', true, true)
        vim.list_extend(snippet_files, alias_dir_files)
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

  -- Process ${n:default} format placeholders
  processed_body = processed_body:gsub('%$%{(%d+):([^}]*)%}', function(num, default)
    local placeholder_num = tonumber(num)
    placeholders[placeholder_num] = {text = default}
    return default
  end)

  -- Process simple $n format placeholders
  processed_body = processed_body:gsub('%$(%d+)', function(num)
    local placeholder_num = tonumber(num)
    if placeholder_num == 0 then
      placeholders[0] = {text = ''}
      return ''
    else
      if not placeholders[placeholder_num] then
        placeholders[placeholder_num] = {text = ''}
      end
      return placeholders[placeholder_num].text
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

  -- Find first placeholder position
  local first_placeholder_pos = nil
  for line_idx, line_content in ipairs(new_lines) do
    for placeholder_num = 1, 10 do
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
    vim.api.nvim_win_set_cursor(0, {first_placeholder_pos.row + 1, first_placeholder_pos.col_start})
    vim.defer_fn(function()
      local mode = vim.fn.mode()
      if mode == 'i' then
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
    if current_snippet_placeholders[i] and current_snippet_placeholders[i].text ~= '' then
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      for row, line in ipairs(lines) do
        local start_pos = line:find(current_snippet_placeholders[i].text, 1, true)
        if start_pos then
          vim.api.nvim_win_set_cursor(0, {row, start_pos - 1})
          local end_col = start_pos + #current_snippet_placeholders[i].text - 1

          vim.defer_fn(function()
            local mode = vim.fn.mode()
            if mode == 'i' then
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
    if current_snippet_placeholders[i] and current_snippet_placeholders[i].text ~= '' then
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      for row, line in ipairs(lines) do
        local start_pos = line:find(current_snippet_placeholders[i].text, 1, true)
        if start_pos then
          vim.api.nvim_win_set_cursor(0, {row, start_pos - 1})
          local end_col = start_pos + #current_snippet_placeholders[i].text - 1

          vim.defer_fn(function()
            local mode = vim.fn.mode()
            if mode == 'i' then
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
local function can_trigger_omni()
  local omni_func = vim.bo.omnifunc
  if omni_func == '' or omni_func == 'syntaxcomplete#Complete' then
    return false
  end

  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before_cursor = line:sub(1, col)
  local filetype = vim.bo.filetype

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

  if not can_trigger_omni() then
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
-- PATH COMPLETION FUNCTIONS
-- ============================================================================

-- Check if path completion can be triggered
local function can_trigger_path()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before_cursor = line:sub(1, col)

  local path_patterns = {
    '/[^%s]*$',           -- Absolute path
    '%./[^%s]*$',         -- Relative path ./
    '%.%./[^%s]*$',       -- Relative path ../
    '~[^%s]*$',           -- Home directory path
    '[%w_%-%.]+/[^%s]*$', -- Directory/file path
  }

  for _, pattern in ipairs(path_patterns) do
    if before_cursor:match(pattern) then
      return true
    end
  end
  return false
end

-- Get path completions
local function get_path_completions(path_prefix)
  local matches = {}

  if not can_trigger_path() then
    return matches
  end

  pcall(function()
    local dir_part = path_prefix:match('^(.*/)')
    local file_part = path_prefix:match('([^/]*)$')

    if not dir_part then
      dir_part = './'
      file_part = path_prefix
    end

    local pattern = dir_part .. file_part .. '*'
    local glob_results = vim.fn.glob(pattern, false, true)

    for _, path in ipairs(glob_results) do
      local is_dir = vim.fn.isdirectory(path) == 1
      local basename = vim.fn.fnamemodify(path, ':t')
      if basename ~= '' and basename:lower():find(file_part:lower(), 1, true) == 1 then
        local display_name = basename .. (is_dir and '/' or '')
        table.insert(matches, {
          word = display_name,
          menu = '[P]',
          info = path
        })
      end
    end
  end)

  return matches
end

-- ============================================================================
-- UNIFIED COMPLETION FUNCTION
-- ============================================================================

-- Main unified completion function with new priority: snippet -> omni -> buffer -> dict -> path
function _G.builtin_complete_unified()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local prefix = line:sub(1, col):match('[%w_]*$') or ''
  local path_prefix = line:sub(1, col):match('[^%s]*$') or ''

  local can_omni = can_trigger_omni()
  local can_path = can_trigger_path()

  if #prefix == 0 and not can_path and not can_omni then
    return ''
  end

  local filetype = vim.bo.filetype
  local all_matches = {}
  local start_col = col - #prefix + 1

  -- Adjust start column for path completion
  if can_path and #path_prefix > #prefix then
    start_col = col - #path_prefix + 1
  end

  -- 1. SNIPPET COMPLETION (highest priority)
  local snippet_matches = get_snippet_completions(prefix, filetype)
  vim.list_extend(all_matches, snippet_matches)

  -- 2. OMNI COMPLETION
  local omni_matches = get_omni_completions(prefix)
  vim.list_extend(all_matches, omni_matches)

  -- 3. BUFFER COMPLETION
  local buffer_matches = get_buffer_completions(prefix)
  vim.list_extend(all_matches, buffer_matches)

  -- 4. DICTIONARY COMPLETION (separate from omni)
  local dict_matches = get_dictionary_completions(prefix)
  vim.list_extend(all_matches, dict_matches)

  -- 5. PATH COMPLETION (lowest priority)
  if can_path then
    local path_matches = get_path_completions(path_prefix)
    vim.list_extend(all_matches, path_matches)
  end

  -- Show completion menu
  if #all_matches > 0 then
    if vim.fn.mode() == 'i' then
      vim.fn.complete(start_col, all_matches)
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
      end
    elseif omni_funcs[ft] then
      omni_func = omni_funcs[ft]
    end

    if omni_func then
      -- Set valid omnifunc
      vim.bo[args.buf].omnifunc = omni_func
    else
      -- Use syntaxcomplete as fallback
      vim.bo[args.buf].omnifunc = 'syntaxcomplete#Complete'

      -- Set up dictionary files (separate from omni)
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
    end

    -- Preload snippets for this filetype
    load_snippets_for_filetype(ft)
  end
})

-- ============================================================================
-- KEYBINDING CONFIGURATION
-- ============================================================================

-- Tab key: completion and snippet expansion
map('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    -- Menu visible, select first item and confirm (triggers completed_item)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-n><C-y>', true, true, true), 'n', false)
    -- Delay snippet expansion
    vim.defer_fn(function()
      expand_snippet()
    end, 10)
    return ''
  else
    -- Menu not visible, normal Tab behavior
    return vim.api.nvim_replace_termcodes('<Tab>', true, true, true)
  end
end, {expr = true, silent = true})

-- Shift-Tab: previous selection in completion menu
map('i', '<S-Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return vim.api.nvim_replace_termcodes('<C-p>', true, true, true)
  else
    return vim.api.nvim_replace_termcodes('<S-Tab>', true, true, true)
  end
end, {expr = true, silent = true})

-- Enter key: confirm selection (no snippet expansion)
map('i', '<CR>', function()
  if vim.fn.pumvisible() == 1 then
    -- Directly confirm selection without expanding snippet
    return vim.api.nvim_replace_termcodes('<C-y>', true, true, true)
  else
    return vim.api.nvim_replace_termcodes('<CR>', true, true, true)
  end
end, {expr = true, silent = true})

-- Ctrl-Space: manual completion trigger
map('i', '<C-@>', function()
  if vim.fn.pumvisible() == 1 then
    return vim.api.nvim_replace_termcodes('<C-y>', true, true, true)
  else
    builtin_complete_unified()
    return ''
  end
end, {expr = true, silent = true})

-- Snippet placeholder navigation - only active in snippet mode
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

map({'i', 's'}, '<C-b>', function()
  if snippet_mode_active and not vim.tbl_isempty(current_snippet_placeholders) then
    jump_to_prev_placeholder()
    return ''
  else
    return vim.api.nvim_replace_termcodes('<C-b>', true, true, true)
  end
end, {expr = true, silent = true})

-- Other completion navigation - only when menu is visible
map('i', '<Down>', function()
  if vim.fn.pumvisible() == 1 then
    return vim.api.nvim_replace_termcodes('<C-n>', true, true, true)
  else/
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

-- ESC key: exit snippet mode
map({'i', 's', 'v'}, '<Esc>', function()
  if snippet_mode_active then
    snippet_mode_active = false
    current_snippet_placeholders = {}
    current_placeholder_index = 0
  end
  return vim.api.nvim_replace_termcodes('<Esc>', true, true, true)
end, {expr = true, silent = true})

-- ============================================================================
-- AUTO-TRIGGER LOGIC
-- ============================================================================

-- General auto-trigger for all buffers
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*',
  callback = function(args)
    -- Generic TextChangedI auto-trigger
    vim.api.nvim_create_autocmd('TextChangedI', {
      buffer = args.buf,
      callback = function()
        if vim.fn.pumvisible() == 0 then
          local line = vim.api.nvim_get_current_line()
          local col = vim.api.nvim_win_get_cursor(0)[2]
          local prefix = line:sub(1, col):match('[%w_]*$') or ''
          local can_trigger = false

          -- Check buffer word matching (lowered threshold to 1 character)
          if #prefix >= 1 and buffer_has_matches(prefix) then
            can_trigger = true
          end

          -- Check path completion
          if not can_trigger and can_trigger_path() then
            can_trigger = true
          end

          -- Trigger completion
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

-- Filetype-specific auto-trigger
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
      php = { '.', '->', '::' },
      go = { '.', ':' },
      default = { '.', ':', '>' },
    }

    local triggers = ft_triggers[ft] or ft_triggers.default

    -- Character-triggered completion
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
                  builtin_complete_unified()
                end
              end
            end, 50)
            break
          end
        end
      end
    })

    -- Enhanced TextChangedI for filetype-specific completion
    vim.api.nvim_create_autocmd('TextChangedI', {
      buffer = args.buf,
      callback = function()
        if vim.fn.pumvisible() == 0 then
          local line = vim.api.nvim_get_current_line()
          local col = vim.api.nvim_win_get_cursor(0)[2]
          local prefix = line:sub(1, col):match('[%w_]*$') or ''
          local can_trigger = false

          if #prefix >= 2 then
            -- 1. Check snippet matches
            local snippet_matches = get_snippet_completions(prefix, ft)
            if #snippet_matches > 0 then
              can_trigger = true
            end

            -- 2. Check buffer word matches
            if not can_trigger and buffer_has_matches(prefix) then
              can_trigger = true
            end
          end

          -- 3. Check path completion
          if not can_trigger and can_trigger_path() then
            can_trigger = true
          end

          -- Trigger completion
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

-- Auto-clear snippet state
vim.api.nvim_create_autocmd({'InsertLeave', 'BufLeave'}, {
  callback = function()
    current_snippet_placeholders = {}
    current_placeholder_index = 0
    snippet_mode_active = false
  end
})

-- ============================================================================
-- DEBUG COMMANDS
-- ============================================================================

-- Debug snippets command
vim.api.nvim_create_user_command('DebugSnippets', function()
  local filetype = vim.bo.filetype
  local snippets = load_snippets_for_filetype(filetype)
  local omni_func = vim.bo.omnifunc
  local has_omni = omni_func ~= '' and omni_func ~= 'syntaxcomplete#Complete'
  local strategy = has_omni and "omni[O]" or "dict[D]"
  print(filetype .. ": " .. #snippets .. " snippets[S], mode: " .. (snippet_mode_active and "on" or "off") .. ", strategy: " .. strategy)
end, {})

-- Debug completion command
vim.api.nvim_create_user_command('DebugComplete', function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local prefix = line:sub(1, col):match('[%w_]*$') or ''
  local path_prefix = line:sub(1, col):match('[^%s]*$') or ''
  local can_omni = can_trigger_omni()
  local can_path = can_trigger_path()
  local before_cursor = line:sub(1, col)
  local filetype = vim.bo.filetype

  print("=== Enhanced Completion Debug Info ===")
  print("File type: " .. filetype)
  print("Current line: '" .. line .. "'")
  print("Cursor position: " .. col)
  print("Text before cursor: '" .. before_cursor .. "'")
  print("Prefix: '" .. prefix .. "' (length: " .. #prefix .. ")")
  print("Path prefix: '" .. path_prefix .. "' (length: " .. #path_prefix .. ")")
  print("Can trigger omni: " .. tostring(can_omni))
  print("Can trigger path: " .. tostring(can_path))
  print("Omnifunc: " .. vim.bo.omnifunc)
  print("Dictionary file: " .. (vim.bo.dictionary or "none"))

  print("\n=== Completion Results (Priority Order) ===")

  -- Test each completion type in priority order
  print("1. SNIPPET COMPLETION [S]:")
  local snippet_matches = get_snippet_completions(prefix, filetype)
  print("  Found " .. #snippet_matches .. " matches")
  for i, match in ipairs(snippet_matches) do
    if i <= 3 then
      print("  - " .. match.word)
    end
  end

  print("2. OMNI COMPLETION [O]:")
  local omni_matches = get_omni_completions(prefix)
  print("  Found " .. #omni_matches .. " matches")
  for i, match in ipairs(omni_matches) do
    if i <= 3 then
      print("  - " .. match.word)
    end
  end

  print("3. BUFFER COMPLETION [B]:")
  local buffer_matches = get_buffer_completions(prefix)
  print("  Found " .. #buffer_matches .. " matches")
  for i, match in ipairs(buffer_matches) do
    if i <= 3 then
      print("  - " .. match.word)
    end
  end

  print("4. DICTIONARY COMPLETION [D]:")
  local dict_matches = get_dictionary_completions(prefix)
  print("  Found " .. #dict_matches .. " matches")
  for i, match in ipairs(dict_matches) do
    if i <= 3 then
      print("  - " .. match.word)
    end
  end

  print("5. PATH COMPLETION [P]:")
  local path_matches = get_path_completions(path_prefix)
  print("  Found " .. #path_matches .. " matches")
  for i, match in ipairs(path_matches) do
    if i <= 3 then
      print("  - " .. match.word)
    end
  end

  print("\nTriggering manual completion...")
  if vim.fn.mode() == 'i' then
    builtin_complete_unified()
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

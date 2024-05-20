local gp = require "gp"
local map = vim.keymap.set
local modes = { "n", "i", "v", "x" }
local opts = { noremap = true, silent = true }
gp.setup({
  openai_api_key = {'cat', vim.fn.expand('~/.gp.key')},
  state_dir = vim.fn.expand("$HOME/.leovim.d"):gsub("/$", "") .. "/gp/persisted",
  chat_dir = vim.fn.expand("$HOME/.leovim.d"):gsub("/$", "") .. "/gp/chats",
  chat_shortcut_respond = { modes = modes, shortcut = "<M-i><M-s>" },
  chat_shortcut_delete = { modes = modes, shortcut = "<M-i><M-d>" },
  chat_shortcut_stop = { modes = modes, shortcut = "<M-i><M-q>" },
  chat_shortcut_new = { modes = modes, shortcut = "<M-i><M-n>" },
  agents = { { name = "ChatGPT4" }, { name = "CodeGPT4" } }
})
vim.api.nvim_create_autocmd({ "User" }, {
  pattern = { "GpDone" },
  callback = function(event)
    print("event fired:\n", vim.inspect(event))
  end,
})
map(modes, "<M-i><M-t>", [[<Cmd>GpChatToggle tabnew<Cr>]], opts)
map(modes, "<M-i><M-p>", [[<Cmd>GpChatToggleSmartPosition<Cr>]], opts)

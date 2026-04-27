-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false
vim.opt.clipboard = "unnamedplus"

vim.g.clipboard = {
  name = "wl-clipboard",
  copy = {
    ["+"] = { "wl-copy", "--type", "text/plain" },
    ["*"] = { "wl-copy", "--primary", "--type", "text/plain" },
  },
  paste = {
    ["+"] = { "wl-paste", "--no-newline" },
    ["*"] = { "wl-paste", "--no-newline", "--primary" },
  },
  cache_enabled = 1,
}

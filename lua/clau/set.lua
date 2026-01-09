-- Visual and editor settings

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Cursor settings (make it small, not fat)
-- Thin cursor in insert mode, block in normal mode
local function set_cursor(shape)
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_echo({{esc .. "[" .. shape .. " q"}}, false, {})
end

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function() set_cursor("6") end, -- Steady bar (thin)
})

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function() set_cursor("1") end, -- Blinking block
})

-- Indentation (4 spaces)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Colors
vim.opt.termguicolors = true

-- Scrolling
vim.opt.scrolloff = 8


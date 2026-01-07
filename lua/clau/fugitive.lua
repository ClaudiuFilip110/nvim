-- Fugitive (Git) keymaps
vim.keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git status" })
vim.keymap.set("n", "<leader>gaa", "<cmd>Git add -A<cr>", { desc = "Git add all" })
vim.keymap.set("n", "<leader>gp", "<cmd>Git push<cr>", { desc = "Git push" })

vim.keymap.set("n", "<leader>gc", function()
  vim.ui.input({ prompt = "Commit message: " }, function(msg)
    if not msg or msg == "" then return end
    vim.cmd("Git commit -m " .. vim.fn.shellescape(msg))
  end)
end, { desc = "Git commit with message" })


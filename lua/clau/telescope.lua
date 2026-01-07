-- Telescope keymaps
vim.keymap.set("n", "<leader>pf", "<cmd>Telescope find_files<cr>", { desc = "Telescope find files" })
vim.keymap.set("n", "<C-p>", "<cmd>Telescope git_files<cr>", { desc = "Find git files" })
vim.keymap.set("n", "<leader>ps", "<cmd>Telescope live_grep<cr>", { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>ph", "<cmd>Telescope help_tags<cr>", { desc = "Telescope help tags" })


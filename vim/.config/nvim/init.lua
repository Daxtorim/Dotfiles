-- vim.g.do_not_install_vim_plugins = true
vim.cmd("source ~/.vimrc")

--#: General settings                       {{{
---@diagnostic disable-next-line: param-type-mismatch
vim.opt.fillchars:append({ foldopen = "▼", foldclose = "▶", foldsep = "│" })
vim.opt.listchars:append({ lead = "." })

vim.opt.laststatus = 3                -- use a single global status line instead of one for each window
vim.opt.inccommand = "split"          -- show results of substitute commands in separate split as they are typed
vim.opt.signcolumn = "auto:1-3"       -- size the signcolumn dynamically between 1 and 3 chars wide

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Hightlight selection on yank",
	group = vim.api.nvim_create_augroup("highlight_yank", {}),
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
	end,
})
--}}}

-- vim:fdm=marker:fdl=0:

-- ================ Sourcing .vimrc ========================
local vimrc = debug.getinfo(1).source:match("[^@]+/") .. "vimrc.original"
vim.cmd("source " .. vimrc)

-- ================ Neovim settings ============== {{{
---@diagnostic disable-next-line: param-type-mismatch
vim.opt.fillchars:append({ foldopen = "▼", foldclose = "▶", foldsep = "│" })
vim.opt.listchars:append({ lead = "." })

vim.opt.laststatus = 3
vim.opt.inccommand = "split"
vim.opt.signcolumn = "auto:1-3"

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", {}),
	desc = "Hightlight selection on yank",
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
	end,
})
--}}}

-- =============== LunarVim Settings ============= {{{
lvim.colorscheme = "gruvbox"

lvim.format_on_save = false
lvim.lint_on_save = true
lvim.reload_config_on_save = false

local B = lvim.builtin

B.gitsigns.opts.signcolumn = false
B.gitsigns.opts.numhl = true

B.nvimtree.setup.filters.dotfiles = false
B.nvimtree.setup.renderer.indent_markers.enable = true
B.nvimtree.setup.renderer.group_empty = true

B.treesitter.auto_install = true
B.treesitter.rainbow = {
	enable = true,
	query = {
		"rainbow-parens",
		html = "rainbow-tags",
		latex = "rainbow-blocks",
	},
}

B.which_key.setup.plugins.presets = { g = true, z = true, windows = true }

require("user.indent-blankline")
require("user.null-ls")
require("user.telescope")
--}}}

-- =============== Plugins ======================= {{{
lvim.plugins = {
	{ "Daxtorim/vim-auto-indent-settings" },
	{ "tpope/vim-surround" },
	{ "ellisonleao/gruvbox.nvim" },
	{ "HiPhish/nvim-ts-rainbow2" },
	{ "Pocco81/auto-save.nvim", opts = {} },
	{ "j-hui/fidget.nvim", opts = {} },
	{ "norcalli/nvim-colorizer.lua", opts = {} },
	{ -- smooth scrolling
		"karb94/neoscroll.nvim",
		opts = {
			easing_function = "sine",
			pre_hook = function()
				vim.opt.eventignore:append({
					"WinScrolled",
					"CursorMoved",
				})
			end,
			post_hook = function()
				vim.opt.eventignore:remove({
					"WinScrolled",
					"CursorMoved",
				})
			end,
		},
	},
}
--}}}

-- vim:fdm=marker:fdl=0:

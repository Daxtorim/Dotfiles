vim.g.do_not_install_vim_plugins = true
vim.cmd("source ~/.config/nvim/init.lua")

--#: LunarVim Settings                      {{{
lvim.colorscheme = "gruvbox"

lvim.format_on_save = false
lvim.lint_on_save = true
lvim.reload_config_on_save = false
--}}}

--#: Core Plugin Settings                   {{{
local B = lvim.builtin
B.gitsigns.opts.signcolumn = false
B.gitsigns.opts.numhl = true

B.nvimtree.setup.filters.dotfiles = false
B.nvimtree.setup.renderer.indent_markers.enable = true
B.nvimtree.setup.renderer.group_empty = true

B.treesitter.auto_install = true

B.which_key.setup.plugins.presets = { g = true, z = true, windows = true }

require("user.indent-blankline")
require("user.null-ls")
require("user.telescope")
--}}}

--#: Plugins                                {{{
lvim.plugins = {
	{ "tpope/vim-sleuth"},
	{ "tpope/vim-surround" },
	{ "ellisonleao/gruvbox.nvim" },
	{ "HiPhish/rainbow-delimiters.nvim" },
	{ "Pocco81/auto-save.nvim", opts = {debounce_delay = 5000} },
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

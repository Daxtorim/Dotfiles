-- ================ Sourcing .vimrc ========================

vim.cmd('source ${HOME}/.config/lvim/vimrc.original')

-- ================= General Settings ======================

-- !!! Colorscheme is set by plugin !!!

-- Neovim specific listchars characters, disable by default
vim.opt.listchars:append({lead = "."})
vim.opt.list = false

lvim.format_on_save = false
lvim.lint_on_save = true

-- ================ Plugins ================================

-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.plugins = {
	{
	-- !!! Colorscheme !!!
	"marko-cerovac/material.nvim",
	config = function()
		vim.g.material_style = "deep oceanic"
		require('material').setup({
			borders = true,
			italics = { comments = true },
			})
		vim.cmd('colorscheme material')
	end
	},
	{
	"Pocco81/AutoSave.nvim",
	event = "BufRead",
	config = function()
		require("autosave").setup({
			enabled = true,
			execution_message = "AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"),
			events = {"InsertLeave", "TextChanged"},
			write_all_buffers = false,
			on_off_commands = false,
			clean_command_line_interval = 0,
			debounce_delay = 135,
		})
	end
	},
	{
	"lukas-reineke/indent-blankline.nvim",
	event = "BufWinEnter",
	config = function()
		-- vim.cmd [[highlight IndentBlanklineIndent1 guibg=#1f1f1f guifg=#383838 gui=nocombine]]
		-- vim.cmd [[highlight IndentBlanklineIndent2 guibg=#1a1a1a guifg=#383838 gui=nocombine]]
		require('indent_blankline').setup({
			enabled = true,
			space_char_blankline = " ",
			-- char = "",
			-- char_highlight_list = {
			-- 	"IndentBlanklineIndent1",
			-- 	"IndentBlanklineIndent2",
			-- },
			-- space_char_highlight_list = {
			-- 	"IndentBlanklineIndent1",
			-- 	"IndentBlanklineIndent2",
			-- },
			show_end_of_line = true,
			show_trailing_blankline_indent = false,
			use_treesitter = true,
			max_indent_increase = 1,
			filetype_exclude = { "help", "terminal", "dashboard", "NvimTree" },
			buftype_exclude = { "terminal" },
		})
	end
	},
	{
	-- Paint background of #RRGGBB colors in the actual color
	"norcalli/nvim-colorizer.lua",
	event = "BufWinEnter",
	config = function ()
		require('colorizer').setup()
	end
	},
	{
	-- automatically find indent settings from file content
	"Daxtorim/vim-auto-indent-settings",
	event = "BufWinEnter",
	}
}

-- Install certain parsers for treesitter by default
lvim.builtin.treesitter.ensure_installed = "maintained"
lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

lvim.builtin.dashboard.active = true

lvim.builtin.terminal.active = true

lvim.builtin.nvimtree.side = "left"
lvim.builtin.nvimtree.show_icons.git = 0
lvim.builtin.nvimtree.hide_dotfiles = 0

-- ================ Sourcing .vimrc ========================

vim.cmd('source ${HOME}/.config/lvim/vimrc.original')

-- ================= General Settings ======================

-- !!! Colorscheme is set by plugin !!!

-- Add Neovim specific listchars characters
vim.opt.listchars:append({lead = "."})

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
			execution_message = "AutoSave: saved at " .. vim.fn.strftime("%Hh%Mm%Ss"),
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
	config = function()
		require('colorizer').setup()
	end
	},
	{
	"blackCauldron7/surround.nvim",
	config = function()
		require("surround").setup({mappings_style = "sandwich"})
	end
	},
	{
	"p00f/nvim-ts-rainbow",
	event = "BufWinEnter",
	config = function()
		require("nvim-treesitter.configs").setup({
			rainbow = {
				enable = true,
				-- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
				extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
				max_file_lines = nil, -- Do not enable for files with more than n lines, int
				colors = {
					"#b16286",
					"#0aaaaa",
					"#a89984",
					"#d79921",
					"#689d6a",
					"#d65d0e",
					"#458588"
				}, -- table of hex strings
				-- termcolors = {} -- table of colour name strings
			}
		})
	end

	},
	{
	-- automatically find indent settings from file content
	"Daxtorim/vim-auto-indent-settings"
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

local components = require("lvim.core.lualine.components")
lvim.builtin.lualine.sections.lualine_x = {
	components.lsp,
	components.filetype,
}
lvim.builtin.lualine.sections.lualine_y = {
	components.encoding,
	{"fileformat", icons_enabled = false},
	components.spaces,
	components.location,
}

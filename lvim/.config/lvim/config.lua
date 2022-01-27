-- ================ Sourcing .vimrc ========================

vim.cmd("source ${HOME}/.config/lvim/vimrc.original")

-- ================ Neovim settings ========================

-- Add Neovim specific listchars characters
vim.opt.listchars:append({ lead = "." })

-- ================ LunarVim Settings ======================

lvim.format_on_save = false
lvim.lint_on_save = true

-- Install certain parsers for treesitter by default
lvim.builtin.treesitter.ensure_installed = "maintained"
lvim.builtin.treesitter.highlight.enabled = true
lvim.builtin.dashboard.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.side = "left"
lvim.builtin.nvimtree.show_icons.git = 0
lvim.builtin.nvimtree.setup.hide_dotfiles = 0

local components = require("lvim.core.lualine.components")
lvim.builtin.lualine.options = {
	icons_enabled = true,
	theme = "auto",
	component_separators = { left = "", right = "" },
	section_separators = { left = "", right = "" },
	disabled_filetypes = {},
	always_divide_middle = true,
}
lvim.builtin.lualine.sections = {
	lualine_a = { "mode", "branch" },
	lualine_b = { components.diff, "diagnostics" },
	lualine_c = { components.lsp },
	lualine_x = { components.spaces },
	lualine_y = { "encoding", "fileformat", "filetype" },
	lualine_z = { "location", "progress" },
}

-- ================ LSP Settings ===========================

local null_ls = require("null-ls")
local fo = null_ls.builtins.formatting
local di = null_ls.builtins.diagnostics
local ca = null_ls.builtins.code_actions
null_ls.setup({
	sources = {
		-- python
		fo.black.with({ extra_args = { "--fast" } }),
		di.flake8.with({ extra_args = { "--ignore", "E302,E501,W503" } }),
		-- JS
		fo.prettier,
		di.eslint_d,
		ca.eslint_d,
		-- lua
		fo.stylua,
		-- shell
		fo.shfmt.with({ extra_args = { "-i=0", "-ci", "-bn", "-fn", "-sr" } }),
		di.shellcheck,
		ca.shellcheck,
		-- other
		ca.gitsigns,
	},
})

-- ================ Plugins ================================

-- After changing plugin config exit and reopen LunarVim, Run :PackerSync :PackerCompile
lvim.plugins = {
	{
		-- Colorscheme
		"marko-cerovac/material.nvim",
		config = function()
			vim.g.material_style = "deep oceanic"
			require("material").setup({
				borders = true,
				italics = { comments = true },
			})
		end,
	},
	{
		-- Colorscheme
		"EdenEast/nightfox.nvim",
		config = function()
			local nightfox = require("nightfox")
			nightfox.setup({
				fox = "nightfox", -- Which fox style should be applied
				transparent = false, -- Disable setting the background color
				alt_nc = true, -- Non current window bg to alt color see `hl-NormalNC`
				terminal_colors = true, -- Configure the colors used when opening :terminal
				styles = {
					comments = "italic", -- Style that is applied to comments: see `highlight-args` for options
					functions = "NONE", -- Style that is applied to functions: see `highlight-args` for options
					keywords = "NONE", -- Style that is applied to keywords: see `highlight-args` for options
					strings = "NONE", -- Style that is applied to strings: see `highlight-args` for options
					variables = "NONE", -- Style that is applied to variables: see `highlight-args` for options
				},
				inverse = {
					match_paren = false, -- Enable/Disable inverse highlighting for match parens
					visual = false, -- Enable/Disable inverse highlighting for visual selection
					search = true, -- Enable/Disable inverse highlights for search highlights
				},
			})
			nightfox.load()
		end,
	},
	{
		"Pocco81/AutoSave.nvim",
		config = function()
			require("autosave").setup({
				enabled = false,
				execution_message = "AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"),
				events = { "InsertLeave", "TextChanged" },
				write_all_buffers = false,
				on_off_commands = true,
				clean_command_line_interval = 0,
				debounce_delay = 135,
			})
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "BufWinEnter",
		config = function()
			-- vim.cmd("highlight IndentBlanklineIndent1 guibg=#1f1f1f guifg=#383838 gui=nocombine")
			-- vim.cmd("highlight IndentBlanklineIndent2 guibg=#1a1a1a guifg=#383838 gui=nocombine")
			require("indent_blankline").setup({
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
				max_indent_increase = 2,
				filetype_exclude = { "help", "terminal", "dashboard", "NvimTree", "lspinfo", "lsp-installer" },
				buftype_exclude = { "terminal" },
			})
		end,
	},
	{
		-- Paint background of #RRGGBB colors in the actual color
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	},
	{
		"blackCauldron7/surround.nvim",
		config = function()
			require("surround").setup({
				mappings_style = "surround",
				space_on_alias = true,
			})
		end,
	},
	{
		"p00f/nvim-ts-rainbow",
		event = "BufRead",
		config = function()
			require("nvim-treesitter.configs").setup({
				rainbow = {
					enable = true,
					-- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
					extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
					max_file_lines = nil, -- Do not enable for files with more than n lines, int
					colors = { "#b16286", "#0aaaaa", "#d79921", "#689d6a", "#d65d0e", "#a89984", "#458588" }, -- table of hex strings
					-- termcolors = {} -- table of colour name strings
				},
			})
		end,
	},
	{
		-- automatically find indent settings from file content
		"Daxtorim/vim-auto-indent-settings",
	},
}

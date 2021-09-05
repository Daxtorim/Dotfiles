-- ================ Sourcing .vimrc ========================

vim.cmd('source ${HOME}/.config/lvim/vimrc.original')

-- ================= General Settings ======================

-- !!! Colorscheme is set by plugin !!!

-- Neovim specific listchars characters
vim.opt.listchars:append({lead="."})

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
				italics = { comments = true }
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
	event = "BufRead",
	config = function()
		require('indent_blankline').setup({
			enabled = true,
			show_end_of_line = true,
			space_char_blankline = " ",
			use_treesitter = true,
			show_trailing_blankline_indent= false,
			filetype_exclude = { "help", "terminal", "dashboard", "NvimTree" },
			buftype_exclude = { "terminal" },
		})
	end
	},
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


-- ================= Formatters and Linters ================

lvim.lang.python.formatters          = { { exe = "black" } }
lvim.lang.python.linters             = { { exe = "flake8" } }
lvim.lang.javascript.formatters      = { { exe = "prettier" } }
lvim.lang.javascript.linters         = { { exe = "eslint_d" } }
lvim.lang.typescript.formatters      = lvim.lang.javascript.formatters
lvim.lang.typescriptreact.formatters = lvim.lang.typescript.formatters
lvim.lang.typescript.linters         = lvim.lang.javascript.linters
lvim.lang.typescriptreact.linters    = lvim.lang.typescript.linters

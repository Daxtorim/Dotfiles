-- ================ Sourcing .vimrc ========================
vim.cmd('source ${HOME}/.config/lvim/vimrc.original')


-- ================ Plugins ================================

-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.plugins = {
	{
	--Colorscheme
	"marko-cerovac/material.nvim",
	config = function()
		vim.g.material_style = "deep oceanic"
		vim.g.material_contrast = "true"
		vim.g.material_italic_comments = "true"
		require('material').set()
	end
	},
	{
	"Pocco81/AutoSave.nvim",
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


-- ================= General Settings ======================

-- Colorscheme
lvim.colorscheme = "material"

lvim.format_on_save = false
lvim.lint_on_save = true


-- ================= Formatters and Linters ================

lvim.lang.python.formatters          = { { exe = "black" } }
lvim.lang.python.linters             = { { exe = "flake8" } }
lvim.lang.javascript.formatters      = { { exe = "prettier" } }
lvim.lang.javascript.linters         = { { exe = "eslint_d" } }
lvim.lang.typescript.formatters      = lvim.lang.javascript.formatters
lvim.lang.typescriptreact.formatters = lvim.lang.typescript.formatters
lvim.lang.typescript.linters         = lvim.lang.javascript.linters
lvim.lang.typescriptreact.linters    = lvim.lang.typescript.linters

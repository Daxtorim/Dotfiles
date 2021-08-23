-- ================ Sourcing .vimrc ========================
vim.cmd('source ${HOME}/.config/lvim/vimrc.original')


-- ================ Plugins ================================

-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.plugins = {
	{
	--Colorscheme
	"marko-cerovac/material.nvim",
	config=function()
		vim.g.material_style="darker"
		vim.g.material_italic_comments="true"
	end,
	},
}

-- Install certain parsers for treesitter by default
lvim.builtin.treesitter.ensure_installed = "maintained"
lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true
lvim.builtin.nvimtree.hide_dotfiles = 0

-- ================= General Settings ======================

lvim.format_on_save = false
lvim.lint_on_save = true
lvim.colorscheme = 'material'

-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.dashboard.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.side = "left"
lvim.builtin.nvimtree.show_icons.git = 0


-- ================= Formatters and Linters ================

lvim.lang.python.formatters          = { { exe = "black" } }
lvim.lang.python.linters             = { { exe = "flake8" } }
lvim.lang.javascript.formatters      = { { exe = "prettier" } }
lvim.lang.javascript.linters         = { { exe = "eslint_d" } }
lvim.lang.typescript.formatters      = lvim.lang.javascript.formatters
lvim.lang.typescriptreact.formatters = lvim.lang.typescript.formatters
lvim.lang.typescript.linters         = lvim.lang.javascript.linters
lvim.lang.typescriptreact.linters    = lvim.lang.typescript.linters

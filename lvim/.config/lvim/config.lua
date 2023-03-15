-- ================ Sourcing .vimrc ========================

local vimrc = debug.getinfo(1).source:match("[^@]+/") .. "vimrc.original"
vim.cmd("source " .. vimrc)

-- ================ Neovim settings ========================

-- Add Neovim specific listchars characters
vim.opt.listchars:append({ lead = "." })
vim.opt.fillchars:append({ foldopen = "▼", foldclose = "▶", foldsep = "│" })

vim.opt.inccommand = "split"


-- workaround to get folding and syntax highlighting with treesitter to work
vim.api.nvim_create_autocmd({ "BufRead" }, {
	group = vim.api.nvim_create_augroup("TS_FOLD_WORKAROUND", {}),
	callback = function()
		vim.opt.foldmethod = "expr"
		vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
	end,
})

-- ================ LunarVim Settings ======================
-- {{{
vim.g.everforest_background = 'hard'
lvim.colorscheme = "everforest"

lvim.format_on_save = false
lvim.lint_on_save = true
lvim.reload_config_on_save = false

local B = lvim.builtin

B.gitsigns.opts.signcolumn = false
B.gitsigns.opts.numhl = true

B.nvimtree.setup.filters.dotfiles = false
B.nvimtree.setup.renderer.indent_markers.enable = true

B.terminal.active = false

B.indentlines.active = true
B.indentlines.options = {
	enabled = true,
	space_char_blankline = " ",
	show_end_of_line = true,
	show_trailing_blankline_indent = false,
	use_treesitter = true,
	max_indent_increase = 2,
	filetype_exclude = {
		"help",
		"terminal",
		"dashboard",
		"NvimTree",
		"packer",
		"lspinfo",
		"lsp-installer",
		"Outline",
	},
	buftype_exclude = { "terminal", "nofile" },
}

local ok_indent, _ = pcall(require, "indent_blankline")
if ok_indent then
	-- Refresh after folding
	for _, cmd in pairs({ "A", "a", "C", "c", "M", "m", "O", "o", "R", "r" }) do
		vim.api.nvim_set_keymap("n", "z" .. cmd, "z" .. cmd .. "<cmd>IndentBlanklineRefresh<CR>", { noremap = true })
	end
end
-- }}}

-- ================ LSP Settings ===========================
-- {{{
local ok_null, null_ls = pcall(require, "null-ls")
if ok_null then
	local f = null_ls.builtins.formatting
	local d = null_ls.builtins.diagnostics
	local a = null_ls.builtins.code_actions
	---@diagnostic disable-next-line: redundant-parameter
	null_ls.setup({
		sources = {
			-- python
			f.black.with({ extra_args = { "--fast" } }),
			f.isort,
			d.flake8.with({ extra_args = { "--ignore", "E302,E501,W503" } }),
			-- JS
			f.prettier.with({ disabled_filetypes = { "json" } }),
			d.eslint_d,
			a.eslint_d,
			--json
			f.jq,
			-- lua
			f.stylua,
			-- shell
			f.shfmt.with({ extra_args = { "-i=0", "-ci", "-fn", "-sr" } }),
			d.shellcheck,
			a.shellcheck,
		},
	})
else
	print("Cannot load null-ls configuration!")
	print(null_ls)
end
-- }}}

-- ================ Plugins ================================
-- {{{
-- After changing plugin config exit and reopen LunarVim, Run :PackerSync :PackerCompile
lvim.plugins = {
	{ "sainnhe/everforest" },
	{ "Daxtorim/vim-auto-indent-settings" },
	{ "tpope/vim-surround" },
	{ "ellisonleao/gruvbox.nvim" },
	{ "elkowar/yuck.vim" },
	{
		"j-hui/fidget.nvim",
		config = function()
			require("fidget").setup({})
		end,
	},
	{
		-- smooth scrolling
		"karb94/neoscroll.nvim",
		config = function()
			require("neoscroll").setup({
				-- All these keys will be mapped to their corresponding default scrolling animation
				mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
				hide_cursor = true, -- Hide cursor while scrolling
				stop_eof = false, -- Stop at <EOF> when scrolling downwards
				respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
				cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
				easing_function = "sine", -- Default easing function
				pre_hook = nil, -- Function to run before the scrolling animation starts
				post_hook = nil, -- Function to run after the scrolling animation ends
				performance_mode = false, -- Disable "Performance Mode" on all buffers.
			})
		end,
	},
	{
		"Pocco81/auto-save.nvim",
		config = function()
			require("auto-save").setup()
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
		-- Paint pairs of brackets in different colors
		"HiPhish/nvim-ts-rainbow2",
		event = "BufRead",
		config = function()
			require("nvim-treesitter.configs").setup({
				rainbow = {
					enable = true,
					query = {
						"rainbow-parens",
						html = "rainbow-tags",
						latex = "rainbow-blocks",
					},
				},
			})
		end,
	},
}
-- }}}

-- vim:fdm=marker:fdl=0:

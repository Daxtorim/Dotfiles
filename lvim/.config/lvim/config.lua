-- ================ Sourcing .vimrc ========================

local vimrc = debug.getinfo(1).source:match("[^@]+/") .. "vimrc.original"
vim.cmd("source " .. vimrc)

-- ================ Neovim settings ========================

-- Add Neovim specific listchars characters
vim.opt.listchars:append({ lead = "." })
vim.opt.fillchars:append({ foldopen = "▼", foldclose = "▶", foldsep = "│" })

vim.opt.inccommand = "split"

if vim.version().minor >= 9 then
	vim.opt.splitkeep = "sreen"
end

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
local B = lvim.builtin
lvim.format_on_save = false
lvim.lint_on_save = true
lvim.colorscheme = "terafox"
lvim.reload_config_on_save = false

B.gitsigns.opts.signcolumn = true
B.gitsigns.opts.numhl = false

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
	null_ls.setup({
		sources = {
			-- python
			f.black.with({ extra_args = { "--fast" } }),
			f.isort,
			d.flake8.with({ extra_args = { "--ignore", "E302,E501,W503" } }),
			-- JS
			f.prettier,
			d.eslint_d,
			a.eslint_d,
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
	{ "Daxtorim/vim-auto-indent-settings" },
	{ "tpope/vim-surround" },
	{ "ellisonleao/gruvbox.nvim" },
	{ "elkowar/yuck.vim" },
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
		-- Colorscheme
		"EdenEast/nightfox.nvim",
		config = function()
			require("nightfox").setup({
				options = {
					transparent = false, -- Disable setting the background color
					dim_inactive = true, -- Non current window bg to alt color see `hl-NormalNC`
					terminal_colors = true, -- Configure the colors used when opening :terminal
					styles = {
						-- Style that is applied to category: see `highlight-args` for options
						comments = "italic",
						functions = "NONE",
						keywords = "bold",
						strings = "italic",
						variables = "NONE",
					},
					inverse = {
						-- Enable/Disable inverse highlighting for category
						match_paren = false,
						visual = false,
						search = true,
					},
				},
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
		"p00f/nvim-ts-rainbow",
		event = "BufRead",
		config = function()
			require("nvim-treesitter.configs").setup({
				rainbow = {
					enable = true,
					extended_mode = true, -- Also highlight non-bracket delimiters like html tags
					max_file_lines = nil, -- Do not enable for files with more than n lines
					colors = { "#b16286", "#0aaaaa", "#d79921", "#689d6a", "#d65d0e", "#a89984", "#458588" },
				},
			})
		end,
	},
}
-- }}}

-- ================ Display settings =======================
-- {{{
-- Blinking BAR in insert mode, blinking BLOCK elsewhere (GUI only)
vim.opt.guifont = "monospace:h11"
vim.opt.guicursor =
	"n-v-c:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkwait100-blinkoff400-blinkon600-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"
-- }}}

-- vim:fdm=marker:fdl=0:

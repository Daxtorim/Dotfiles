local B = lvim.builtin
-- ================ Sourcing .vimrc ========================

vim.cmd("source ${HOME}/.config/lvim/vimrc.original")

-- ================ Neovim settings ========================

-- Add Neovim specific listchars characters
vim.opt.listchars:append({ lead = "." })
vim.opt.inccommand = "split"

-- ================ LunarVim Settings ======================
-- {{{
lvim.format_on_save = false
lvim.lint_on_save = true

lvim.colorscheme = "nightfox"

B.gitsigns.opts.signcolumn = false
B.gitsigns.opts.numhl = true

B.nvimtree.side = "left"
B.nvimtree.show_icons.git = 0
B.nvimtree.setup.hide_dotfiles = 0

B.notify.active = true

B.treesitter.ensure_installed = "maintained"
B.treesitter.highlight.enabled = true
-- }}}

-- ================ Toggleterm =============================
-- {{{
B.terminal.active = true
B.terminal.direction = "horizontal"
B.terminal.size = 10
B.terminal.close_on_exit = true

-- {{{ on_exit(), on_stdout(), on_stderr()
local function on_exit(term, _, exit_code, _)
	if term:is_open() then
		return
	end
	local out = { text = "Success!", level = "info" }
	if exit_code ~= 0 then
		out = { text = "Failure!", level = "error" }
	end
	vim.notify("Job exited: " .. out.text, out.level, { title = term.name })
end

local function on_stdout(term, _, data, _)
	if term:is_open() then
		return
	end
	local str = data[1]
	-- ─╸[✅]-[ 1.3s]-[ 15:32]
	if str:match("─╸%[[✅❌].*.*") then
		local out = { text = "Success!", level = "info" }
		if str:match("─╸%[❌") then
			out = { text = "Failure!", level = "error" }
		end
		vim.notify("Job finished: " .. out.text, out.level, { title = term.name })
	end
end
-- }}}

B.terminal.on_exit = on_exit
B.terminal.on_stdout = on_stdout

B.terminal.term_count = 1001

function _G._VIMRC_TOGGLETERM_EXECUTE_FILE()
	local win = vim.api.nvim_get_current_win()
	local cursorposition = vim.api.nvim_win_get_cursor(0)

	vim.cmd(B.terminal.term_count .. 'TermExec cmd="%:p"')

	vim.api.nvim_win_set_cursor(win, cursorposition)
	vim.api.nvim_set_current_win(win)
end

B.which_key.mappings["r"] = {
	name = "Terminals",
	["1"] = { "<cmd>lua require('toggleterm').toggle(1)<CR>", "Terminal 1" },
	["2"] = { "<cmd>lua require('toggleterm').toggle(2)<CR>", "Terminal 2" },
	["3"] = { "<cmd>lua require('toggleterm').toggle(3)<CR>", "Terminal 3" },
	r = { "<cmd>lua _G._VIMRC_TOGGLETERM_EXECUTE_FILE()<CR>", "Run current file" },
	t = {
		"<cmd>lua require('toggleterm').toggle(" .. B.terminal.term_count .. ")<CR><cmd>stopinsert<CR>",
		"Show last run",
	},
}
B.which_key.mappings["t"] = { "<cmd>lua require('toggleterm').toggle(1)<CR>", "Terminal 1" }
-- }}}

-- ================ Lualine ================================
-- {{{
local components = require("lvim.core.lualine.components")
B.lualine.options = {
	icons_enabled = true,
	theme = "material",
	component_separators = { left = "", right = "" },
	section_separators = { left = "", right = "" },
	disabled_filetypes = {},
	always_divide_middle = true,
	-- globalstatus = true,
}
B.lualine.sections = {
	lualine_a = { "mode" },
	lualine_b = { "branch", "diff", "diagnostics" },
	lualine_c = { components.lsp },
	lualine_x = { components.spaces },
	lualine_y = { "encoding", "fileformat", "filetype" },
	lualine_z = { "location", "progress" },
}
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
			require("indent_blankline").setup({
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
			})
			-- Refresh after folding
			for _, cmd in pairs({ "A", "a", "C", "c", "M", "m", "O", "o", "R", "r" }) do
				vim.api.nvim_set_keymap(
					"n",
					"z" .. cmd,
					"z" .. cmd .. "<cmd>IndentBlanklineRefresh<CR>",
					{ noremap = true }
				)
			end
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
					-- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
					extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
					max_file_lines = nil, -- Do not enable for files with more than n lines, int
					colors = { "#b16286", "#0aaaaa", "#d79921", "#689d6a", "#d65d0e", "#a89984", "#458588" }, -- table of hex strings
				},
			})
		end,
	},
	{
		"luukvbaal/stabilize.nvim",
		config = function()
			require("stabilize").setup()
		end,
	},
	{
		"simrat39/symbols-outline.nvim",
		event = "BufWinEnter",
		setup = function()
			vim.g.symbols_outline = {
				highlight_hovered_item = true,
				show_guides = true,
				auto_preview = false,
				position = "right",
				relative_width = false,
				width = 50,
				show_symbol_details = true,
				keymaps = {
					close = { "<ESC>", "q" },
					goto_location = "<CR>",
					focus_location = "o",
					hover_symbol = "K",
					toggle_preview = "<C-space>",
					rename_symbol = "r",
					code_actions = "a",
				},
			}
			vim.cmd("autocmd! FileType Outline setlocal nolist")
			vim.api.nvim_set_keymap("n", "<leader>S", "<CMD>SymbolsOutline<CR>", { noremap = true })
		end,
	},
}
-- }}}

-- vim:fdm=marker:fdl=0:

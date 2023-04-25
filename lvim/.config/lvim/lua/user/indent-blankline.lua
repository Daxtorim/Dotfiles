lvim.builtin.indentlines.active = true
lvim.builtin.indentlines.options = {
	enabled = true,
	space_char_blankline = " ",
	show_end_of_line = true,
	show_trailing_blankline_indent = false,
	use_treesitter = true,
	max_indent_increase = 2,
}

-- Refresh indent markers after folding
local ok_indent, _ = pcall(require, "indent_blankline")
if ok_indent then
	local z_actions = {
		A = "Toggle folds recursively at cursor",
		a = "Toggle fold at cursor",
		C = "Close folds recursively at cursor",
		c = "Close fold at cursor",
		e = "Sreen to the left of cursor",
		H = "Half screen to the left",
		h = "Scroll screen left",
		L = "Half screen to the right",
		l = "Scroll screen right",
		M = "Close all folds",
		m = "Fold more",
		O = "Open folds recursively at cursor",
		o = "Open fold at cursor",
		R = "Open all folds",
		r = "Fold less",
		s = "Screen to the right of cursor",
		v = "Show cursor line",
		X = "Re-apply foldlevel",
		x = "Update folds",
	}
	for key, desc in pairs(z_actions) do
		vim.api.nvim_set_keymap(
			"n",
			"z" .. key,
			"z" .. key .. "<cmd>IndentBlanklineRefresh<CR>",
			{ noremap = true, desc = desc }
		)
	end
end

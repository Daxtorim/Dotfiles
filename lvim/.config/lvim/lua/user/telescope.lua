lvim.builtin.which_key.mappings["?"] = { require("telescope.builtin").oldfiles, "Find recently opened files" }
lvim.builtin.which_key.mappings[" "] = { require("telescope.builtin").buffers, "Find existing buffers" }
lvim.builtin.which_key.mappings["/"] = {
	function()
		require("telescope.builtin").current_buffer_fuzzy_find({ previewer = false })
	end,
	"Fuzzy search",
}

lvim.builtin.telescope.defaults = {
	border = true,
	borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
	layout_strategy = "horizontal",
	layout_config = {
		width = 0.8,
		height = 0.7,
		horizontal = {
			prompt_position = "bottom",
		},
	},
}

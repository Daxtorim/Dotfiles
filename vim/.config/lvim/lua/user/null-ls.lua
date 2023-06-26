local ok_null, null_ls = pcall(require, "null-ls")
if ok_null then
	local f = null_ls.builtins.formatting
	local d = null_ls.builtins.diagnostics
	local a = null_ls.builtins.code_actions
	---@diagnostic disable-next-line: redundant-parameter
	null_ls.setup({
		sources = {
			-- spellchecker
			-- d.cspell,
			-- a.cspell,
			-- python
			f.black.with({ extra_args = { "--fast" } }),
			f.isort,
			d.flake8.with({ extra_args = { "--ignore", "E302,E501,W503" } }),
			-- javascript
			f.prettier.with({ disabled_filetypes = { "json" } }),
			--json
			f.jq,
			-- lua
			f.stylua,
			-- shell
			f.shfmt.with({ extra_args = { "-i=0", "-ci", "-sr", "-bn" } }),
			-- d.shellcheck, -- diagnostics provided by bash-language-server (using shellcheck behind the scenes)
			a.shellcheck,
		},
	})
else
	print("Cannot load null-ls configuration!")
	print(null_ls)
end

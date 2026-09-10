return {
	"nvim-mini/mini.completion",
	dependencies = {
		"nvim-mini/mini.icons",
		-- "nvim-mini/mini.snippets",
	},
	config = function()
		require("mini.completion").setup({
			-- Whether to show extra completion items when there is only one match. Can be
			-- `false` (always show), `true` (only show if there are extra items) or
			-- `"auto"` (only show if there are extra items and they don't have the same
			-- label).
			-- show_single = "auto",
			lsp_completion = {
				source_func = "omnifunc",
			},
		})
	end,
}

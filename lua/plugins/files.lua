return {
    'nvim-tree/nvim-tree.lua',
	dependencies = {
		{ "nvim-tree/nvim-web-devicons" }, -- or zbirenbaum/copilot.lua
	},
    config = function()
      require('nvim-tree').setup {
        view = {
          width = 30,
          side = 'left',
        },
        filters = {
          dotfiles = false,
        },
      }

	  vim.keymap.set('n', '<Leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
    end,
}

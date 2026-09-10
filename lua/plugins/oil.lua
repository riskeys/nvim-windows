local oil = {
  'stevearc/oil.nvim',
  opts = {},
  dependencies = {
    { "echasnovski/mini.icons", opts = {} }
  },
  config = function()
    local oil = require("oil")
    oil.setup({
      columns = { "icon" },
      keymaps = {
        ["<C-h>"] = false,
        ["<C-j>"] = false,
        ["<C-k>"] = false,
        ["<C-l>"] = false,
      },
      view_options = {
        show_hidden = true,
      }
    })

    vim.keymap.set("n", "<Leader>op", "<CMD>Oil<CR>", { desc = "Oil: Open parent dir" })
    vim.keymap.set("n", "<Leader>ot", require("oil").toggle_float, { desc = "Oil: Toggle float" })
  end,
  lazy = false
}
return oil

local mini_icons = require("mini.icons")
mini_icons.setup()

local oil = require("oil")
oil.setup({
    view_options = {
        show_hidden = true,
    }
})

local tree = require("nvim-tree")
tree.setup()


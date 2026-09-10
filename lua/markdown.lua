local markview = require("markview")

markview.setup({
    -- Your configuration options here
    -- For example:
    -- option1 = value1,
    -- option2 = value2,
    preview = {
        filetypes = { "markdown", "codecompanion" }, -- Specify the filetypes for which the preview should be enabled
        ignore_buftypes = {},
    }
})

vim.keymap.set("n", ",,", ":Markview toggle<CR>", { noremap = true, silent = true })

local fzf = require("fzf-lua")
fzf.setup({'fzf-vim'})
fzf.setup({
    winopts = {
        preview = {
            hidden = false
        }
    },
    keymap = {
        builtin = {
            -- true,
            ["<C-j>"] = "preview-down",
            ["<C-k>"] = "preview-up",
            ["<C-d>"] = "preview-half-page-down",
            ["<C-u>"] = "preview-half-page-up",
        },
        fzf = {
            true,
            ["ctrl-j"] = "preview-down",
            ["ctrl-k"] = "preview-up",
            ["ctrl-d"] = "preview-half-page-down",
            ["ctrl-u"] = "preview-half-page-up",
        },
    },
})
fzf.register_ui_select()


print("init.lua")

require("options")
local functions = require("functions")
local gh = functions.gh

vim.pack.add({
    gh("nvim-lua/plenary.nvim"),
    gh("nvim-mini/mini.icons"),
    gh("nvim-tree/nvim-web-devicons"),
    gh("nvim-treesitter/nvim-treesitter"),
    gh("stevearc/oil.nvim"),
    gh("OXY2DEV/markview.nvim"),
    gh("tpope/vim-fugitive"),
    gh("github/copilot.vim"),
    gh("stevearc/conform.nvim"),
    gh("catppuccin/nvim"),
    gh("tpope/vim-fugitive"),
    gh("ibhagwan/fzf-lua"),
    gh("nvim-tree/nvim-tree.lua"),
    gh("tpope/vim-dadbod"),
    gh("kristijanhusak/vim-dadbod-ui"),
    gh("kristijanhusak/vim-dadbod-completion"),
    gh("lewis6991/gitsigns.nvim"),
    gh("folke/which-key.nvim"),
    gh("riskeys/discipline.nvim"),
    gh("nvim-mini/mini.test"),
    gh("NicholasMata/sqlserver.nvim"),
})
vim.pack.add({ gh("saghen/blink.lib"), gh("saghen/blink.cmp") })
vim.pack.add({ {
    src = "https://www.github.com/olimorris/codecompanion.nvim",
    version = vim.version.range("^19.0.0")
} })

require("markdown")
require("files")
require("keymap")
require("lsp")
require("search")
require("artifi")
require("autoformat")
require("git")
require("sqlserver").setup({
    keymap_prefix = "<leader>d",
    results = {
        max_cell_width = 300,
    },
})
require("mini.test").setup()

require("statusline")
require("colorscheme")

local dc = require("discipline")
dc.setup({
    local_scratch_subdir = "/personal",
    local_reminder_subdir = "/personal",
    local_daily_subdir = "/daily",
})
require("abbrev")



local ns = vim.api.nvim_create_namespace("test_hl")
vim.api.nvim_set_hl(0, "MyRed", {
    -- fg = "red",
    -- bg = "blue",
    conceal = true,
    italic = true
})

vim.api.nvim_set_hl(0, "ConsoleLog", {
    fg = "red",
    bg = "yellow",
    -- conceal = true,
    italic = true
})

vim.api.nvim_set_hl(0, "CCComment", {
    fg = "yellow",
    bg = "red",
    -- conceal = true,
    -- italic = true
})

vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
    callback = function()
        local buf = vim.api.nvim_get_current_buf()

        -- vim.api.nvim_buf_set_extmark(buf, ns, 1, 0, {
        --     line_hl_group = "MyRed",
        --     virt_lines = { { { "Nice?", "MyRed" } } },
        --     virt_lines_above = false,
        --     virt_text = { { "Hello?", "MyRed" } },
        --     virt_text_pos = "right_align",
        --     -- end_row = 2,
        --     -- end_col = 2,
        --     -- hl_group = "MyRed",
        -- })
        --
        -- vim.api.nvim_buf_set_extmark(buf, ns, 2, 0, {
        --     line_hl_group = "MyRed",
        --     virt_lines = { { { " ", "Normal" }, { "Nice", "ConsoleLog" } } },
        --     virt_lines_above = true,
        --     virt_text = { { "Hello?", "MyRed" } },
        --     virt_text_pos = "right_align",
        --     -- end_row = 2,
        --     -- end_col = 2,
        --     -- hl_group = "MyRed",
        -- })

        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        for line_num, line in ipairs(lines) do
            if vim.o.ft == "javascript" or vim.o.ft == "typescript" or vim.o.ft == "text" then
                local console_log = line:match("console%.log")
                if console_log then
                    vim.api.nvim_buf_set_extmark(buf, ns, line_num - 1, 0, {
                        virt_lines = { { { "use console.info or delete!", "ConsoleLog" } } },
                        virt_lines_above = true,
                    })
                end
            end

            local comment = line:match("%s*//")
            if comment then
                if vim.o.ft == "javascript" or vim.o.ft == "typescript" or vim.o.ft == "text" then
                    vim.api.nvim_buf_set_extmark(buf, ns, line_num - 1, 0, {
                        line_hl_group = "CCComment",
                        virt_text = { { "Comment detected", "CCComment" } },
                        virt_text_pos = "eol",
                        -- virt_lines = { { { "", "Normal" } }, { { "use console.info or delete!", "ConsoleLog" } } },
                        -- virt_lines_above = true,
                    })
                end
            end
        end
    end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    end,
})

-- local cuz = require("discipline")
-- cuz.setup()

local code_companion = require("codecompanion")

code_companion.setup({
    interactions = {
        cli = {
            agent = "claude_code",
            agents = {
                claude_code = {
                    cmd = "claude",
                    args = {},
                    description = "Claude Code CLI",
                    provider = "terminal",
                },
            },
        },
    },
    adapters = {
        acp = {
            claude_code = function()
                return require("codecompanion.adapters").extend("claude_code", {
                    env = {
                        CLAUDE_CODE_OAUTH_TOKEN = os.getenv("CLAUDE_CODE_OAUTH_TOKEN"),
                        -- CLAUDE_CODE_OAUTH_TOKEN = "",
                    },
                })
            end,
        },
    },
})

vim.keymap.set("n", "<leader>ac", function()
    code_companion.open_chat()
end, { desc = "Open Code Companion Chat" })

vim.keymap.set("n", "<leader>aa", function()
    code_companion.cli({ prompt = true })
end, { desc = "Open Code Companion Actions" })

vim.keymap.set("n", "<leader>at", function()
    code_companion.cli()
end, { desc = "Open Code Companion CLI" })

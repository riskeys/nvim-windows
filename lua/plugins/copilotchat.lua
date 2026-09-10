return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
    { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
  },
  -- build = "make tiktoken", -- Only on MacOS or Linux
  opts = {
    mappings = {
      complete = {
        detail = 'Use @<Tab> or /<Tab> for options.',
        insert ='<S-Tab>',
      }
    }
  },
  config = function()
    vim.api.nvim_set_keymap("n", "cp", ":CopilotChatToggle<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "co", ":CopilotChat<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "cm", ":CopilotChatModel<CR>", { noremap = true, silent = true })
  end,
  -- See Commands section for default commands if you want to lazy load on them
}

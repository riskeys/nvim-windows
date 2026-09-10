--- This is a custom statusline function for Neovim that dynamically adjusts its content based on the window width.

-- Create a global wrapper function so Vim's expression evaluator can see it
local statuses = {
    "frog in boiling water",
    "8-5 serving no purpose",
    "the information/action ratio",
}
local index = 1
local function get_status_text()
    return statuses[index]
end

local function git_branch()
    local head = vim.b.gitsigns_head
    if head and head ~= "" then
        return " " .. head .. " "
    end
    return ""
end

_G.custom_git_branch = git_branch

-- local lsp_clients = {}
local lsp_clients_text = ""

local retrieve_lsp_clients = function()
    local text = ""
    local clients = vim.lsp.get_clients()
    for _, client in ipairs(clients) do
        local client_name = client.name
        if client.name == "GitHub Copilot" then
            client_name = "copilot"
        end

        text = text .. client_name .. " "
    end

    lsp_clients_text = text
end

local function my_statusline()
    -- winwidth(0) gets the width of the current window
    local width = vim.fn.winwidth(0)
    local components = {}

    -- local branch_name = get_branch_name()

    local first_section = "%f %m %r %h %w %#WarningMsg# %{%v:lua.custom_git_branch()%} %= "
    local last_section =
        "%#Normal# " ..
        lsp_clients_text ..
        "| %{&fileencoding?&fileencoding:&encoding} %y | %l,%v | mode:%{mode()} | %#WarningMsg# buf:%n %#Normal# | %P"
    local middle_section = ""

    if width > 140 then
        middle_section = "%#Title#" .. get_status_text() .. "%="

        first_section = "%-40(" .. first_section .. "%)%= "
        last_section = "%200(" .. last_section .. "%)"
    end

    table.insert(components, first_section)
    table.insert(components, middle_section)
    table.insert(components, last_section)

    return table.concat(components)
end

_G.custom_statusline = my_statusline

-- Set the statusline option using the expression evaluation prefix (%!)
vim.opt.statusline = "%!v:lua.custom_statusline()"

vim.keymap.set('n', '<Leader>ss', function()
    if vim.fn.winwidth(0) <= 140 then return end

    index = index % #statuses + 1
    vim.cmd("redrawstatus!")
end, { noremap = true, silent = true, desc = "Statusline: Cycle Status caption :)" })

vim.keymap.set('n', '<Leader>sl', function()
    retrieve_lsp_clients()
    vim.cmd("redrawstatus!")
end, { noremap = true, silent = true, desc = "Statusline: LSP" })

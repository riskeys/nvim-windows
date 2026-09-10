local M = {}

local LOCAL_SCRATCH_DIR = vim.fn.expand("$HOME") .. "/scratch"

local function get_scratch_daily_path()
    local today = os.date("%Y-%m-%d")
    return LOCAL_SCRATCH_DIR .. "/daily/scratch_" .. today .. ".md"
end

local function get_scratch_path()
    return LOCAL_SCRATCH_DIR .. "/xtr/scratch.md"
end

local function get_reminder_path()
    return LOCAL_SCRATCH_DIR .. "/xtr/reminder.md"
end

--- @type integer|nil
M.buf_daily = nil
--- @type integer|nil
M.buf_reminder = nil
--- @type integer|nil
M.buf_scratch = nil

M.get_scratch_daily_buf = function()
    if M.buf_daily == nil or not vim.api.nvim_buf_is_valid(M.buf_daily) then
        M.buf_daily = vim.fn.bufadd(get_scratch_daily_path())
    end
    return M.buf_daily
end

M.get_scratch_buf = function()
    if M.buf_scratch == nil or not vim.api.nvim_buf_is_valid(M.buf_scratch) then
        M.buf_scratch = vim.fn.bufadd(get_scratch_path())
        -- vim.api.nvim_buf_set_lines(M.buf_scratch, 0, -1, false, { "# Scratch Notes", "", "## Notes", "" })
    end
    return M.buf_scratch
end

--- @return integer
M.get_reminder_buf = function()
    if M.buf_reminder == nil or not vim.api.nvim_buf_is_valid(M.buf_reminder) then
        M.buf_reminder = vim.fn.bufadd(get_reminder_path())
    end

    return M.buf_reminder
end

return M

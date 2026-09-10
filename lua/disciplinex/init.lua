local journal = require("discipline.scratch")
local local_scratch = require("discipline.local_scratch")

local M = {}

local BANDUNG_CITY_ID = "fc221309746013ac554571fbd180e1c8"
local SCHEDULE_DIR = vim.fn.expand("$HOME") .. "/praytell"
local FLOAT_WIDTH = 60
local FLOAT_WIN_BTM_HEIGHT = 15
local FLOAT_WIN_TOP_HEIGHT = 30

--- @type integer|nil
M.window_id = nil
--- @type integer|nil
M.window_top_id = nil
--- @type integer|nil
M.window_id_scratch = nil
--- @type integer|nil
M.last_active_window_id = nil
--- @type integer|nil
M.previous_window_id = nil
--- @type integer|nil
M.previous_window_id_scratch = nil
--- @type integer|nil
M.buf_scratch = nil
--- @type integer|nil
M.buf = nil
--- @type integer|nil
M.buf_reminder = nil
--- @type integer|nil
M.buf_notes = nil
--- @type integer|nil
M.last_win_top_buf = nil
--- @type integer|nil
M.last_win_btm_buf = nil
-- M.notes_path = "test.md"
--- @type string|nil
M.notes_path = "notes/main.md"
M.get_scratch_path = function()
    local today = os.date("%Y-%m-%d")
    -- Windows homepath/scratch
    return vim.fn.expand("$HOME") .. "/scratch/daily/scratch_" .. today .. ".md"
    -- return "/scratch/scratch_" .. today .. ".md"
end
M.get_reminder_path = function()
    -- Windows homepath/scratch
    return vim.fn.expand("$HOME") .. "/scratch/reminder.md"
    -- return "/scratch/scratch_" .. today .. ".md"
end

--- @param url string
--- @return string
local function http_get(url)
    local result = vim.system({ "curl", "-s", url }):wait()
    if result.code ~= 0 then
        return ""
    end
    return result.stdout or ""
end

--- @param year integer
--- @param month integer
--- @return string
local function schedule_dir(year, month)
    return string.format("%s/%d/%02d", SCHEDULE_DIR, year, month)
end

--- @param year integer
--- @param month integer
--- @param day string
--- @return string
local function schedule_file(year, month, day)
    return schedule_dir(year, month) .. "/" .. day .. ".json"
end

--- @param today_table osdate
local function fetch_schedules(today_table)
    local year = today_table.year
    local month = today_table.month
    local date_query = string.format("%d-%02d", year, month)
    local url = "https://api.myquran.com/v3/sholat/jadwal/" .. BANDUNG_CITY_ID .. "/" .. date_query

    local ok, json_res = pcall(vim.json.decode, http_get(url))
    if not ok or not json_res.data or not json_res.data.jadwal then
        vim.notify("Failed to fetch prayer schedule.", vim.log.levels.ERROR)
        return
    end

    vim.fn.mkdir(schedule_dir(year, month), "p")
    for day, entry in pairs(json_res.data.jadwal) do
        vim.fn.writefile({ vim.json.encode(entry) }, schedule_file(year, month, day))
    end
end

--- @return string[]
local function get_today_prayer_schedule()
    local today_table = os.date("*t")
    local today = os.date("%Y-%m-%d")
    local file_name = schedule_file(today_table.year, today_table.month, today)

    local ok, lines = pcall(vim.fn.readfile, file_name)
    if not ok then
        fetch_schedules(today_table)
        ok, lines = pcall(vim.fn.readfile, file_name)
    end
    if not ok then
        return { "Error: Failed to read schedule." }
    end

    local jadwal = vim.json.decode(table.concat(lines, "\n"))
    return {
        "jadwal",
        jadwal.tanggal,
        "",
        "---",
        "",
        "subuh: " .. jadwal.subuh,
        "dhuhur: " .. jadwal.dzuhur,
        "ashar: " .. jadwal.ashar,
        "maghrib: " .. jadwal.maghrib,
        "isya: " .. jadwal.isya,
    }
end

--- @return table
local function float_win_btm_opts()
    local width = FLOAT_WIDTH
    local row = vim.o.lines - (FLOAT_WIN_BTM_HEIGHT + 4)

    return {
        anchor = "NE",
        border = "rounded",
        relative = "editor",
        width = width,
        height = FLOAT_WIN_BTM_HEIGHT,
        row = row,
        col = vim.o.columns,
        style = "minimal",
    }
end

--- @return table
local function float_win_top_opts()
    local width = FLOAT_WIDTH

    return {
        anchor = "NE",
        border = "rounded",
        relative = "editor",
        width = width,
        height = FLOAT_WIN_TOP_HEIGHT,
        row = 0,
        col = vim.o.columns,
        style = "minimal",
    }
end

--- Closes the floating window if it is currently showing `expected_buf`.
--- @param expected_buf integer
--- @return boolean closed true if the window was showing expected_buf and got closed
local function close_float_if_showing(expected_buf)
    if M.window_id and vim.api.nvim_win_is_valid(M.window_id) then
        if vim.api.nvim_win_get_buf(M.window_id) == expected_buf then
            vim.api.nvim_win_close(M.window_id, false)
            M.window_id = nil
            return true
        end
        return false
    end

    if M.window_id then
        -- window_id was set but no longer refers to a valid window
        M.window_id = nil
    end
    return false
end

--- Closes the floating window if it is currently showing `expected_buf`.
--- @param expected_buf integer
--- @return boolean closed true if the window was showing expected_buf and got closed
local function close_float_top_if_showing(expected_buf)
    if M.window_top_id and vim.api.nvim_win_is_valid(M.window_top_id) then
        if vim.api.nvim_win_get_buf(M.window_top_id) == expected_buf then
            vim.api.nvim_win_close(M.window_top_id, false)
            M.window_top_id = nil
            return true
        end
        return false
    end

    if M.window_top_id then
        -- window_id was set but no longer refers to a valid window
        M.window_top_id = nil
    end
    return false
end

--- Shows `buf` in the shared floating window, creating the window if needed.
--- @param buf integer|nil
local function show_in_float(buf)
    if buf == nil then
        vim.notify("No buffer provided to show in floating window.", vim.log.levels.WARN)
        return
    end
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
    vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

    M.previous_window_id = vim.api.nvim_get_current_win()

    if M.window_id == nil or not vim.api.nvim_win_is_valid(M.window_id) then
        M.window_id = vim.api.nvim_open_win(buf, true, float_win_btm_opts())
    else
        vim.api.nvim_win_set_buf(M.window_id, buf)
    end

    M.last_win_btm_buf = buf
end
---
--- Shows `buf` in the shared floating window, creating the window if needed.
--- @param buf integer|nil
local function show_in_float_win_top(buf)
    if buf == nil then
        vim.notify("No buffer provided to show in floating window.", vim.log.levels.WARN)
        return
    end

    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
    vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

    M.previous_window_id = vim.api.nvim_get_current_win()

    if M.window_top_id == nil or not vim.api.nvim_win_is_valid(M.window_top_id) then
        M.window_top_id = vim.api.nvim_open_win(buf, true, float_win_top_opts())
    else
        vim.api.nvim_win_set_buf(M.window_top_id, buf)
    end

    M.last_win_top_buf = buf
end

--- Closes the floating window if it is currently showing `expected_buf`.
--- @return boolean closed true if the window was showing expected_buf and got closed
local function toggle_float_btm()
    if M.window_id and vim.api.nvim_win_is_valid(M.window_id) then
        vim.api.nvim_win_close(M.window_id, false)
        M.window_id = nil
        return true
    else
        show_in_float(M.last_win_btm_buf)
        return false
    end
end

--- Closes the floating window if it is currently showing `expected_buf`.
--- @return boolean closed true if the window was showing expected_buf and got closed
local function toggle_float_top()
    if M.window_top_id and vim.api.nvim_win_is_valid(M.window_top_id) then
        vim.api.nvim_win_close(M.window_top_id, false)
        M.window_top_id = nil
        return true
    else
        show_in_float_win_top(M.last_win_top_buf)
        return false
    end
end


--- Shows `buf` in the shared floating window, creating the window if needed.
--- @param buf integer
--- @param is_scratch boolean|nil
local function show_in_float_scratch(buf, is_scratch)
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
    vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

    M.previous_window_id = vim.api.nvim_get_current_win()

    if M.window_id_scratch == nil or not vim.api.nvim_win_is_valid(M.window_id_scratch) then
        M.window_id_scratch = vim.api.nvim_open_win(buf, true, float_win_btm_opts(is_scratch))
    else
        vim.api.nvim_win_set_buf(M.window_id_scratch, buf)
    end
end

M.toggle_notes_window = function()
    if M.buf_notes and close_float_if_showing(M.buf_notes) then
        return
    end

    if M.notes_path == nil or M.notes_path == "" then
        vim.ui.input({ prompt = "Enter notes path: " }, function(input)
            if input and input ~= "" then
                M.notes_path = input
                vim.notify("Notes path set to: " .. M.notes_path, vim.log.levels.INFO)
                M.toggle_notes_window() -- Retry opening the notes window after setting the path
            else
                vim.notify("Notes path is not set.", vim.log.levels.WARN)
            end
        end)

        if M.notes_path == nil or M.notes_path == "" then
            vim.notify("Notes path is not set. Please set it using :CuzNotesPath <path>", vim.log.levels.WARN)
            return
        end
    end

    if M.notes_path == nil or M.notes_path == "" then
        vim.ui.input({ prompt = "Enter notes path: " }, function(input)
            if input and input ~= "" then
                M.notes_path = input
                vim.notify("Notes path set to: " .. M.notes_path, vim.log.levels.INFO)
                M.toggle_notes_window() -- Retry opening the notes window after setting the path
            else
                vim.notify("Notes path is not set. Please set it using :CuzNotesPath <path>", vim.log.levels.WARN)
            end
        end)
    end

    if M.buf_notes == nil or not vim.api.nvim_buf_is_valid(M.buf_notes) or M.buf_notes ~= vim.fn.bufnr(M.notes_path) then
        -- bufadd() returns an *unloaded* buffer for a not-yet-open file, unlike
        -- nvim_create_buf() which is loaded (but empty) from the start; that
        -- distinction is what lets the bufloaded()/bufload() check below work.
        M.buf_notes = vim.fn.bufadd(M.notes_path)
        vim.bo[M.buf_notes].buflisted = true
    end
    if vim.fn.bufloaded(M.buf_notes) == 0 then
        vim.fn.bufload(M.buf_notes)
    end

    show_in_float(M.buf_notes)
end

M.get_praytell_buf = function()
    if M.buf == nil or not vim.api.nvim_buf_is_valid(M.buf) then
        M.buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, get_today_prayer_schedule())
    end

    vim.api.nvim_set_option_value("modifiable", false, { buf = M.buf })
    return M.buf
end

M.toggle_schedule_window = function()
    if M.buf and close_float_if_showing(M.buf) then
        return
    end

    if M.buf == nil or not vim.api.nvim_buf_is_valid(M.buf) then
        M.buf = vim.api.nvim_create_buf(false, true)
    end

    show_in_float(M.buf)
    vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, get_today_prayer_schedule())
    vim.api.nvim_set_option_value("modifiable", false, { buf = M.buf })
end

-- M.toggle_reminder_window = function()
-- 	if M.buf_reminder and close_float_if_showing(M.buf) then
-- 		return
-- 	end
--
-- 	if M.buf_reminder == nil or not vim.api.nvim_buf_is_valid(M.buf_reminder) or M.buf_reminder ~= vim.fn.bufnr(M.get_reminder_path()) then
-- 		M.buf_reminder = vim.api.nvim_create_buf(false, true)
-- 	end
--
-- 	show_in_float(M.buf_reminder)
-- 	local ok, _ = pcall(vim.fn.readfile, M.get_reminder_path())
-- 	if not ok then
-- 		vim.fn.writefile({ "# Remind yourself" }, M.get_reminder_path())
-- 		ok, _ = pcall(vim.fn.readfile, M.get_reminder_path())
-- 	end
--
-- 	if not ok then
-- 		vim.notify("Failed to create reminder file at " .. M.get_reminder_path(), vim.log.levels.ERROR)
-- 		return
-- 	end
--
-- 	-- vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, get_today_prayer_schedule())
-- 	vim.api.nvim_set_option_value("modifiable", false, { buf = M.buf })
-- end

M.toggle_reminder_window = function()
    if M.buf_reminder == nil or not vim.api.nvim_buf_is_valid(M.buf_reminder) then
        M.buf_reminder = vim.api.nvim_create_buf(false, true)
    end

    if M.buf_reminder == nil or not vim.api.nvim_buf_is_valid(M.buf_reminder) or M.buf_reminder ~= vim.fn.bufnr(M.get_reminder_path()) then
        -- bufadd() returns an *unloaded* buffer for a not-yet-open file, unlike
        -- nvim_create_buf() which is loaded (but empty) from the start; that
        -- distinction is what lets the bufloaded()/bufload() check below work.
        local ok, _ = pcall(vim.fn.readfile, M.get_reminder_path())
        if not ok then
            vim.fn.writefile({ "# Reminder" }, M.get_reminder_path())
            ok, _ = pcall(vim.fn.readfile, M.get_reminder_path())
        end

        if not ok then
            vim.notify("Failed to create reminder file at " .. M.get_reminder_path(), vim.log.levels.ERROR)
            return
        end

        M.buf_reminder = vim.fn.bufadd(M.get_reminder_path())
        vim.bo[M.buf_reminder].buflisted = true
    end

    if vim.fn.bufloaded(M.buf_reminder) == 0 then
        vim.fn.bufload(M.buf_reminder)
    end
    vim.api.nvim_set_option_value("modifiable", true, { buf = M.buf_reminder })

    show_in_float(M.buf_reminder)
end

M.go_to_window = function()
    if M.window_id and vim.api.nvim_win_is_valid(M.window_id) then
        if vim.api.nvim_get_current_win() == M.window_id then
            vim.api.nvim_set_current_win(M.previous_window_id)
            return
        end
        M.previous_window_id = vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_win(M.window_id)
    else
        vim.notify("No valid floating window to go to.", vim.log.levels.WARN)
    end
end

M.open_scratch_buffer = function()
    if M.buf_scratch == nil or not vim.api.nvim_buf_is_valid(M.buf_scratch) then
        M.buf_scratch = vim.api.nvim_create_buf(false, true)
    end

    if M.buf_scratch == nil or not vim.api.nvim_buf_is_valid(M.buf_scratch) or M.buf_scratch ~= vim.fn.bufnr(M.get_scratch_path()) then
        -- bufadd() returns an *unloaded* buffer for a not-yet-open file, unlike
        -- nvim_create_buf() which is loaded (but empty) from the start; that
        -- distinction is what lets the bufloaded()/bufload() check below work.
        local ok, _ = pcall(vim.fn.readfile, M.get_scratch_path())
        if not ok then
            vim.fn.writefile({ "# Scratch File - " .. os.date("%Y-%m-%d") }, M.get_scratch_path())
            ok, _ = pcall(vim.fn.readfile, M.get_scratch_path())
        end

        if not ok then
            vim.notify("Failed to create scratch file at " .. M.get_scratch_path(), vim.log.levels.ERROR)
            return
        end

        M.buf_scratch = vim.fn.bufadd(M.get_scratch_path())
        vim.bo[M.buf_scratch].buflisted = true
    end

    if vim.fn.bufloaded(M.buf_scratch) == 0 then
        vim.fn.bufload(M.buf_scratch)
    end
    vim.api.nvim_set_option_value("modifiable", true, { buf = M.buf_scratch })

    show_in_float_scratch(M.buf_scratch, true)
end

M.close_window = function()
    if M.window_id and vim.api.nvim_win_is_valid(M.window_id) then
        vim.api.nvim_win_close(M.window_id, false)
        M.window_id = nil
    else
        vim.notify("No valid floating window to close.", vim.log.levels.WARN)
    end
end

M.close_window_top = function()
    if M.window_top_id and vim.api.nvim_win_is_valid(M.window_top_id) then
        vim.api.nvim_win_close(M.window_top_id, false)
        M.window_id_scratch = nil
    else
        vim.notify("No valid floating window to close.", vim.log.levels.WARN)
    end
end

M.open_scratches = function()
    -- tabnew and then open oil nvim in M.get_scratch_path() directory
    local oil = require("oil")
    if not oil then
        vim.notify("Oil.nvim is not installed. Please install it to use this feature.", vim.log.levels.ERROR)
        return
    end

    vim.cmd("tabnew")
    vim.cmd("Oil " .. vim.fn.expand("$HOME/scratch"))
end

M.open_reminder_top = function()
    local buf_reminder = journal.get_reminder_buf()
    show_in_float_win_top(buf_reminder)
end

M.open_reminder_btm = function()
    local buf_reminder = journal.get_reminder_buf()
    show_in_float(buf_reminder)
end

M.open_daily_btm = function()
    local buf_daily = journal.get_scratch_daily_buf()
    show_in_float(buf_daily)
end

M.open_daily_local_btm = function()
    local buf_daily = local_scratch.get_scratch_daily_buf()
    show_in_float(buf_daily)
end

M.open_random_buffer_test = function()
    show_in_float(0)
    show_in_float_win_top(0)
end

M.open_scratch_btm = function()
    local buf = journal.get_scratch_buf()
    show_in_float(buf)
end

M.open_scratch_top = function()
    local buf = journal.get_scratch_buf()
    show_in_float_win_top(buf)
end

M.open_scratch_daily = function()
    local buf = journal.get_scratch_daily_buf()
    show_in_float_win_top(buf)
end

M.open_praytell = function()
    local buf_praytell = M.get_praytell_buf()
    show_in_float(buf_praytell)
end

M.open_local_reminder = function()
    local buf_reminder = local_scratch.get_reminder_buf()
    show_in_float(buf_reminder)
end

M.open_local_scratch_top = function()
    local buf_scratch = local_scratch.get_scratch_buf()
    if not close_float_top_if_showing(buf_scratch) then
        show_in_float_win_top(buf_scratch)
    end
end

function switch_window()
    if M.window_id and vim.api.nvim_win_is_valid(M.window_id) then
        vim.api.nvim_set_current_win(M.window_id)
    elseif M.window_top_id and vim.api.nvim_win_is_valid(M.window_top_id) then
        vim.api.nvim_set_current_win(M.window_top_id)
    else
        vim.notify("No valid floating window to switch to.", vim.log.levels.WARN)
    end
end

--- @param config table|nil
M.setup = function(config)
    vim.api.nvim_create_user_command("CuzNotesPath", function(opts)
        M.notes_path = opts.args
    end, { nargs = 1, complete = "file", desc = "Set note path" })

    --- @param opts vim.api.keyset.create_user_command.command_args
    local function discipline(opts)
        if not opts.args or opts.args == "" then
            vim.notify("Argument required!", vim.log.levels.WARN)
            return
        end

        if opts.args == "scratch_daily" then
            M.open_daily_btm()
            return
        end

        if opts.args == "local_scratch_daily" then
            M.open_daily_local_btm()
            return
        end

        if opts.args == "local_scratch" then
            M.open_local_scratch_top()
            return
        end

        if opts.args == "scratch" then
            M.open_scratch_top()
            return
        end

        if opts.args == "scratch_btm" then
            M.open_scratch_btm()
            return
        end

        if opts.args == "reminder" then
            M.open_reminder_btm()
            return
        end

        if opts.args == "praytell" then
            M.open_praytell()
            return
        end

        if opts.args == "local_reminder" then
            M.open_local_reminder()
            return
        end

        if opts.args == "git" then
            -- Quick status check via Lua
            journal.open_git()
            return
        end

        vim.notify("Command unknown!", vim.log.levels.WARN)
    end

    local function discipline_complete(arg_lead, cmd_line, cursor_pos)
        local commands = {
            "git",
            "local_reminder",
            "local_scratch",
            "local_scratch_daily",
            "scratch_daily",
            "scratch",
            "scratch_btm",
            "reminder",
            "praytell",
        }
        local matches = {}
        for _, cmd in ipairs(commands) do
            if vim.startswith(cmd, arg_lead) then
                table.insert(matches, cmd)
            end
        end
        return matches
    end

    vim.api.nvim_create_user_command("Discipline", discipline,
        { nargs = 1, complete = discipline_complete, desc = "Set note path" })
    vim.api.nvim_create_user_command("DC", discipline,
        { nargs = 1, complete = discipline_complete, desc = "Set note path" })

    if config ~= nil then
        M.notes_path = config.notes_path or M.notes_path
    end

    vim.keymap.set("n", "<BS>", M.toggle_schedule_window, { desc = "Toggle prayer schedule floating window" })
    vim.keymap.set("n", "\\n", ":CuzNotesPath ", { desc = "Set notes path" })

    vim.keymap.set("n", "\\lr", M.open_local_reminder, { desc = "Discipline: (Local) Reminder" })
    vim.keymap.set("n", "\\ls", M.open_local_scratch_top, { desc = "Discipline: (Local) Scratch" })
    vim.keymap.set("n", "\\ld", M.open_daily_local_btm, { desc = "Discipline: (Local) Scratch daily" })
    vim.keymap.set("n", "\\ll", M.toggle_schedule_window, { desc = "Discipline: Praytell" })

    vim.keymap.set("n", "\\dr", M.open_reminder_btm, { desc = "Discipline: Reminder" })
    vim.keymap.set("n", "\\ds", M.open_scratch_top, { desc = "Discipline: Scratch" })
    vim.keymap.set("n", "\\dd", M.open_scratch_daily, { desc = "Discipline: Scratch daily" })

    vim.keymap.set("n", "\\\\b", toggle_float_btm, { desc = "Close floating window" })
    vim.keymap.set("n", "\\\\t", toggle_float_top, { desc = "Close floating window" })

    vim.keymap.set("n", "\\x", M.close_window, { desc = "Close floating window" })
    vim.keymap.set("n", "\\q", M.close_window_top, { desc = "Close floating window" })
    vim.keymap.set("n", "\\g", journal.open_git, { desc = "Close floating window" })

    local function is_scratch_note(path)
        local scratch_dir = vim.fn.expand("$HOME/scratch")

        return vim.startswith(
            vim.fn.fnamemodify(path, ":p"),
            vim.fn.fnamemodify(scratch_dir, ":p")
        )
    end

    vim.api.nvim_create_autocmd('SwapExists', {
        callback = function(args)
            print("SwapExists autocmd triggered for file: " .. args.file)
            -- vim.v.swapchoice = "o"
            if is_scratch_note(args.file) then
                vim.v.swapchoice = "o"
            end
        end,
    })
end


return M

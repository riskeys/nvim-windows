local M = {}

local BANDUNG_CITY_ID = "fc221309746013ac554571fbd180e1c8"
local SCHEDULE_DIR = vim.fn.expand("$HOME") .. "/scratch/jad"
local FLOAT_WIDTH = 40
local FLOAT_WIDTH_SCRATCH = 70
local FLOAT_HEIGHT = 15

--- @type integer|nil
M.window_id = nil
--- @type integer|nil
M.window_id_scratch = nil
--- @type integer|nil
M.previous_window_id = nil
--- @type integer|nil
M.previous_window_id_scratch = nil
--- @type integer|nil
M.buf_scratch = nil
--- @type integer|nil
M.buf = nil
--- @type integer|nil
M.buf_notes = nil
M.notes_path = "test.md"
M.get_scratch_path = function()
    local today = os.date("%Y-%m-%d")
    -- Windows homepath/scratch
    return vim.fn.expand("$HOME") .. "/scratch/daily/scratch_" .. today .. ".md"
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
--- @param scratch boolean|nil
local function float_win_opts(scratch)
    local width = FLOAT_WIDTH
    local row = vim.o.lines - (FLOAT_HEIGHT + 4)
    if scratch then
        width = FLOAT_WIDTH_SCRATCH
        row = 0
    end

    return {
        anchor = "NE",
        border = "rounded",
        relative = "editor",
        width = width,
        height = FLOAT_HEIGHT,
        row = row,
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

--- Shows `buf` in the shared floating window, creating the window if needed.
--- @param buf integer
local function show_in_float(buf)
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
    vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

    M.previous_window_id = vim.api.nvim_get_current_win()

    if M.window_id == nil then
        M.window_id = vim.api.nvim_open_win(buf, true, float_win_opts())
    else
        vim.api.nvim_win_set_buf(M.window_id, buf)
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
        M.window_id_scratch = vim.api.nvim_open_win(buf, true, float_win_opts(is_scratch))
    else
        vim.api.nvim_win_set_buf(M.window_id_scratch, buf)
    end
end

M.toggle_notes_window = function()
    if M.buf_notes and close_float_if_showing(M.buf_notes) then
        return
    end

    if M.notes_path == nil or M.notes_path == "" then
        vim.notify("Notes path is not set. Please set it using :CuzNotesPath <path>", vim.log.levels.WARN)
        return
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
    if M.window_id_scratch and vim.api.nvim_win_is_valid(M.window_id_scratch) then
        vim.api.nvim_win_close(M.window_id_scratch, false)
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

--- @param config table|nil
M.setup = function(config)
    vim.api.nvim_create_user_command("CuzNotesPath", function(opts)
        M.notes_path = opts.args
    end, { nargs = 1, complete = "file", desc = "Set note path" })
    if config ~= nil then
        M.notes_path = config.notes_path or M.notes_path
    end

    vim.keymap.set("n", "<BS>", M.toggle_schedule_window, { desc = "Toggle prayer schedule floating window" })
    vim.keymap.set("n", "\\\\", M.toggle_notes_window, { desc = "Toggle notes floating window" })
    vim.keymap.set("n", "\\s", M.open_scratch_buffer, { desc = "Toggle notes floating window" })
    vim.keymap.set("n", "\\n", ":CuzNotesPath ", { desc = "Set notes path" })
    vim.keymap.set("n", "\\o", M.go_to_window, { desc = "Go to floating window" })
    vim.keymap.set("n", "\\x", M.close_window, { desc = "Close floating window" })
    vim.keymap.set("n", "\\c", M.close_window_top, { desc = "Close floating window" })
    vim.keymap.set("n", "\\f", M.open_scratches, { desc = "Close floating window" })

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

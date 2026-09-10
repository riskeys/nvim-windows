local bandung_id = "fc221309746013ac554571fbd180e1c8"
local get_text_from_curl = function(url)
    -- local handle = io.popen("curl -s " .. url .. " | jq >> " .. vim.fn.getcwd() .. "/resposne.json")
    local handle = io.popen("curl -s " .. url .. " | jq")
    print("curl -s " .. url .. " | jq >> " .. vim.fn.getcwd() .. "/resposne.json")
    if handle then
        local result = handle:read("*a")
        handle:close()
        return result
    end

    return ""
end

local today_table = os.date("*t")
local today = today_table.year .. string.format("%02d", today_table.month) .. string.format("%02d", today_table.day)
local today_month = string.format("%02d", today_table.month)
local date_query = today_table.year ..
    "-" .. string.format("%02d", today_table.month)

local file, error = io.open("/jad/" .. today .. ".json", "w")
local x = {}
if not file then
    -- print(get_text_from_curl("https://api.myquran.com/v3/sholat/kabkota/eda80a3d5b344bc40f3bc04f65b7a357"))
    x = vim.json.decode(get_text_from_curl("https://api.myquran.com/v3/sholat/jadwal/" .. bandung_id .. "/" .. date_query))
    for key, value in pairs(x) do
        if key == "data" then
            for k, v in pairs(value) do
                -- print(k, v)
                if (k == "jadwal") then
                    for kk, vv in pairs(v) do
                        vim.fn.writefile(vim.json.encode(vv),
                            "jad/" .. today_table.year .. "/" .. "10" .. "/" .. kk .. ".json")
                    end
                end
            end
        end
    end
else
    file:write("Hello, World!\n")
    file:close()
end

-- local fi = vim.fn.readfile("jad/2026/09/2026-09-01.json")
-- local jadwal_harian = vim.json.decode(table.concat(fi, "\n"))

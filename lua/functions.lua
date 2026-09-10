---@class Functions
local M = {}

---@param repo string
M.gh = function(repo)
    return "https://github.com/" .. repo
end

---@param ... string
M.github = function(...)
    local repos = { ... }
    local res = {}
    for _, repo in ipairs(repos) do
        if type(repo) == "string" then
            table.insert(res, "https://github.com/" .. repo)
        end
    end
    return res
end

return M

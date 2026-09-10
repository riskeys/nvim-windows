local vimgrep_jump = function()
    local input = vim.fn.input("Enter search term (vimgrep): ")
    vim.cmd("vimgrep /" .. input .. "/gj %")
    if #vim.fn.getqflist() > 0 then
        if #vim.fn.getqflist() == 1 then
            vim.cmd("cfirst")
        else
            vim.cmd("copen")
        end
    else
        print("No matches found")
    end
end

local vimgrep_jump_fuzzy = function()
    local input = vim.fn.input("Enter search term (vimgrep/fuzzy): ")
    vim.cmd("vimgrep /" .. input .. "/gjf %")
    if #vim.fn.getqflist() > 0 then
        if #vim.fn.getqflist() == 1 then
            vim.cmd("cfirst")
        else
            vim.cmd("copen")
        end
    else
        print("No matches found")
    end
end


local vimgrep_word_in_filetype = function()
    local word = vim.fn.expand("<cword>")
    local filetype = vim.bo.filetype
    -- vim.cmd("vimgrep /\\C" .. word .. "/gj **/*." .. filetype)
    vim.cmd("vimgrep /" .. word .. "/gj **/*." .. filetype)
    if #vim.fn.getqflist() > 0 then
        if #vim.fn.getqflist() == 1 then
            vim.cmd("cfirst")
        else
            vim.cmd("copen")
        end
    else
        print("No matches found")
    end
end

local vimgrep_word_in_current_file = function()
    local word = vim.fn.expand("<cword>")
    vim.cmd("lvimgrep /\\C" .. word .. "/gj %")
    if #vim.fn.getloclist(0) > 0 then
        if #vim.fn.getloclist(0) == 1 then
            vim.cmd("lfirst")
        else
            vim.cmd("lopen")
        end
    else
        print("No matches found")
    end
end

vim.keymap.set("n", "[x", "<cmd>ccl<CR>", { desc = "Close quickfix list" })
vim.keymap.set("n", "]x", "<cmd>lcl<CR>", { desc = "Close location list" })

vim.keymap.set("n", ",gj", vimgrep_jump, { desc = "Vimgrep (jump)" })
vim.keymap.set("n", ",gf", vimgrep_jump_fuzzy, { desc = "Vimgrep (jump + fuzzy)" })
vim.keymap.set("n", ",gq", vimgrep_word_in_filetype, { desc = "Vimgrep this word (quickfix)" })
vim.keymap.set("n", ",gl", vimgrep_word_in_current_file, { desc = "Vimgrep this word (location list)" })

-- vim.keymap.set("n", ",g,", function()
-- 	local word = vim.fn.expand("<cword>")
-- 	local filetype = vim.bo.filetype
-- 	vim.cmd("grep " .. word .. " --type " .. filetype)
-- 	if #vim.fn.getqflist() > 0 then
-- 		if #vim.fn.getqflist() == 1 then
-- 			vim.cmd("cfirst")
-- 		else
-- 			vim.cmd("copen")
-- 		end
-- 	else
-- 		print("No matches found")
-- 	end
-- end, { desc = "Grep for the word under the cursor" })

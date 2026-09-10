-- terminal
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")

-- change directory
vim.keymap.set("n", "<Leader>cv", function()
    print("dir: nvim")
    vim.cmd("cd $HOME/AppData/Local/nvim")
end, { desc = "dir: nvim" })
vim.keymap.set("n", "<Leader>crs", function()
    print("dir: rwssc - sitecore custom")
    vim.cmd("cd D:/rws/1/rwsentosa-revamp-sitecore/src/Feature/SitecoreCustomizations/website")
end, { desc = "dir: rwssc - sitecore custom" })
vim.keymap.set("n", "<Leader>cra", function()
    print("dir: rwssc - audit report")
    vim.cmd("cd D:/rws/1/rwsentosa-revamp-sitecore/src/Feature/AuditReport/website")
end, { desc = "dir: rwssc - audit report" })
vim.keymap.set("n", "<Leader>crd", function()
    print("dir: rwssc - audit report")
    vim.cmd("cd D:/repos/dotnet/RWS.DataHousekeeper")
end, { desc = "dir: rwssc - audit report" })

-- directory (oil)
vim.keymap.set("n", "<Leader>op", "<CMD>Oil<CR>", { noremap = true, desc = "Oil: Open parent dir" })
vim.keymap.set("n", "<Leader>ot", require("oil").toggle_float, { noremap = true, desc = "Oil: Toggle float" })

-- nvim tree
vim.keymap.set("n", "<Leader>e", "<cmd>NvimTreeToggle<CR>", { noremap = true, desc = "Nvim tree", silent = true })

-- fzf
-- vim.keymap.set("n", "g]", function() require("fzf-lua").tags({ query = vim.fn.expand("<cword>") }) end, { desc = "FzfLua tags" })
-- vim.keymap.set("n", "g[", function() require("fzf-lua").btags({ query = vim.fn.expand("<cword>") }) end, { desc = "FzfLua btags" })

vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<CR>", { silent = true })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua grep<CR>", { silent = true, desc = "FzfLua grep" })
vim.keymap.set("n", "<leader>fc", "<cmd>FzfLua grep_curbuf<CR>", { silent = true, desc = "FzfLua grep current buffer" })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<CR>", { silent = true, desc = "FzfLua buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua help<CR>", { silent = true, desc = "FzfLua help" })

require("keymap_vimgrep")

-- start: Vimgrep
-- local vimgrep_jump = function()
-- 	local input = vim.fn.input("Enter search term (vimgrep): ")
-- 	vim.cmd("vimgrep /" .. input .. "/gj %")
-- 	if #vim.fn.getqflist() > 0 then
-- 		if #vim.fn.getqflist() == 1 then
-- 			vim.cmd("cfirst")
-- 		else
-- 			vim.cmd("copen")
-- 		end
-- 	else
-- 		print("No matches found")
-- 	end
-- end
--
-- local vimgrep_jump_fuzzy = function()
-- 	local input = vim.fn.input("Enter search term (vimgrep/fuzzy): ")
-- 	vim.cmd("vimgrep /" .. input .. "/gjf %")
-- 	if #vim.fn.getqflist() > 0 then
-- 		if #vim.fn.getqflist() == 1 then
-- 			vim.cmd("cfirst")
-- 		else
-- 			vim.cmd("copen")
-- 		end
-- 	else
-- 		print("No matches found")
-- 	end
-- end
--
-- local vimgrep_word_in_filetype = function()
-- 	local word = vim.fn.input("Enter search term (vimgrep): ")
-- 	local filetype = vim.bo.filetype
-- 	-- vim.cmd("vimgrep /\\C" .. word .. "/gj **/*." .. filetype)
-- 	vim.cmd("vimgrep /" .. word .. "/gj **/*." .. filetype)
-- 	if #vim.fn.getqflist() > 0 then
-- 		if #vim.fn.getqflist() == 1 then
-- 			vim.cmd("cfirst")
-- 		else
-- 			vim.cmd("copen")
-- 		end
-- 	else
-- 		print("No matches found")
-- 	end
-- end
--
-- local vimgrep_this_word_in_filetype = function()
-- 	local word = vim.fn.expand("<cword>")
-- 	local filetype = vim.bo.filetype
-- 	-- vim.cmd("vimgrep /\\C" .. word .. "/gj **/*." .. filetype)
-- 	vim.cmd("vimgrep /" .. word .. "/gj **/*." .. filetype)
-- 	if #vim.fn.getqflist() > 0 then
-- 		if #vim.fn.getqflist() == 1 then
-- 			vim.cmd("cfirst")
-- 		else
-- 			vim.cmd("copen")
-- 		end
-- 	else
-- 		print("No matches found")
-- 	end
-- end
--
-- local vimgrep_word_in_current_file = function()
-- 	local word = vim.fn.expand("<cword>")
-- 	local filetype = vim.bo.filetype
-- 	vim.cmd("lvimgrep /\\C" .. word .. "/gj %")
-- 	if #vim.fn.getloclist(0) > 0 then
-- 		if #vim.fn.getloclist(0) == 1 then
-- 			vim.cmd("lfirst")
-- 		else
-- 			vim.cmd("lopen")
-- 		end
-- 	else
-- 		print("No matches found")
-- 	end
-- end
--
-- vim.keymap.set("n", "[x", "<cmd>ccl<CR>", { desc = "Close quickfix list" })
-- vim.keymap.set("n", "]x", "<cmd>lcl<CR>", { desc = "Close location list" })
--
-- vim.keymap.set("n", ",gj", vimgrep_jump, { desc = "Vimgrep (jump)" })
-- vim.keymap.set("n", ",gf", vimgrep_jump_fuzzy, { desc = "Vimgrep (jump + fuzzy)" })
-- vim.keymap.set("n", ",gq", vimgrep_word_in_filetype, { desc = "Vimgrep this word (quickfix)" })
-- vim.keymap.set("n", ",gl", vimgrep_word_in_current_file, { desc = "Vimgrep this word (location list)" })


-- end: Vimgrep

-- start: grep
--
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

-- end: grep

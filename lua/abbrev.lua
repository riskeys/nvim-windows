-- vim.cmd("inoreabbrev <expr> ,u system('uuidgen')->trim()->tolower()")
-- 2026-09-04

vim.cmd("iabbrev <expr> ,d strftime('%Y-%m-%d')")
vim.cmd("iabbrev <expr> ,t strftime('%Y-%m-%dT%TZ')")

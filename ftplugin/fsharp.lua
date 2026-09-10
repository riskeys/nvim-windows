vim.cmd("autocmd BufNewFile,BufRead *.fs,*.fsx,*.fsi set filetype=fsharp")
vim.cmd([[ autocmd FileType fsharp setlocal commentstring=//\ %s ]])


return {
    cmd = { "deno", "lsp" },
    single_file_support = false,
    root_markers = { "deno.json", "deno.jsonc" },
    workspace_required = true,
    -- root_dir = function(bufnr, on_dir)
    --     -- print(vim.fn.getcwd(0, 0))
    --     local dirs = vim.fs.find(
    --     -- { "deno.json", "deno.jsonc" },
    --         { "package.json", "package.jsonc" },
    --         { upward = false, path = util.dirname(vim.api.nvim_buf_get_name(bufnr)), stop = cwd }
    --     )
    --     for _, dir in ipairs(dirs) do
    --         if dir then
    --             -- print(dir)
    --             on_dir(dir)
    --             break
    --         end
    --     end
    -- end,
    init_options = {
        lint = true,
        unstable = true,
    },
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
}

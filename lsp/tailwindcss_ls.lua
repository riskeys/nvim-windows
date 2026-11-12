return {
    cmd = { "tailwindcss-language-server", "--stdio" },
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "html", "css" },
    root_dir = function(bufnr, on_dir)
        local root = vim.fs.root(bufnr, {
            "tailwind.config.js",
            "tailwind.config.ts",
            "deno.json",
            "postcss.config.js",
            "package.json",
            ".git",
        })

        if root then
            on_dir(root)
        end
    end,
    settings = {
        tailwindCSS = {
            classAttributes = { "class", "className", "data-classes" },
            classFunctions = { "clsx", "cn", "cva" },
            experimental = {
                classRegex = {
                    "class(Name)?\\s*=\\s*['\"]([^'\"]*)['\"]",
                }
            }
        }
    }
}

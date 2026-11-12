return {
    cmd = {
        "typescript-language-server",
        "--stdio",
    },

    single_file_support = false,
    root_markers = { "package.json", "package.jsonc" },
    workspace_required = true,

    filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
    },

    init_options = {
        plugins = {
            {
                name = "@vue/typescript-plugin",
                location = [[C:\Program Files\nodejs\node_modules\@vue\language-server]],
                languages = { "javascript", "typescript", "vue" },
            },
        },
    },
}

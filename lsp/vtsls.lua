return {
    cmd = { "vtsls", "--stdio" },

    init_options = {
        hostInfo = "neovim",
    },

    filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
    },

    settings = {
        vtsls = {
            tsserver = {
                globalPlugins = {
                    {
                        name = "@vue/typescript-plugin",
                        location = [[C:\Program Files\nodejs\node_modules\@vue\language-server]],
                        -- location = "",
                        languages = { "vue" },
                        configNamespace = "typescript",
                        enableForWorkspaceTypeScriptVersions = true,
                    },
                },
            },
        },
    },
}

return {
	"mfussenegger/nvim-jdtls",
    "neovim/nvim-lspconfig",
	{ "williamboman/mason.nvim", config = true },
    dependencies = {
        { "williamboman/mason.nvim", config = true },
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        "j-hui/fidget.nvim",
    },
    config = function()
        require("mason").setup({
            PATH = "prepend"
        })
    end
}

return {
    cmd = { "vue-language-server", "--stdio" },
    filetypes = { "vue" },
    root_markers = { "package.json" },

    on_init = function(client)
        local retries = 0

        local function typescript_handler(_, result, context)
            local ts_client =
                vim.lsp.get_clients({
                    bufnr = context.bufnr,
                    name = "vtsls",
                })[1]

            if not ts_client then
                if retries < 10 then
                    retries = retries + 1
                    vim.defer_fn(function()
                        typescript_handler(_, result, context)
                    end, 100)
                else
                    vim.notify(
                        "Could not find vtsls for vue_ls request forwarding",
                        vim.log.levels.ERROR
                    )
                end
                return
            end

            local params = result[1]
            local id, command, payload = unpack(params)

            ts_client:exec_cmd({
                title = "vue_request_forward",
                command = "typescript.tsserverRequest",
                arguments = {
                    command,
                    payload,
                },
            }, { bufnr = context.bufnr }, function(_, response)
                local response_data = {
                    { id, response and response.body },
                }

                client:notify("tsserver/response", response_data)
            end)
        end

        client.handlers["tsserver/request"] = typescript_handler
    end,
}

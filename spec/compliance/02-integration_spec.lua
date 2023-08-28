local helpers = require("spec.helpers")
local plugin_name = "compliance"

for _, strategy in helpers.all_strategies() do if strategy ~= "casandra" then
    describe(plugin_name .. ": (access) [#" .. strategy .."]", function()
        local client

        lazy_setup(function()
            local bp = helpers.get_db_utils(strategy == "off" and "postgres" or strategy, nil, { plugin_name })

            local route1 = bp.routes:insert({
                hosts = { "test1.com" }
            })

            bp.plugins:insert {
                name = plugin_name,
                route = { id = route1.id },
                config = { tenant_id = "7" }
            }

            assert(helpers.start_kong({
                database = strategy,
                nginx_conf = "spec/fixtures/custom_nginx.template",
                plugins = "bundled," .. plugin_name,
                declarative_config = strategy == "off" and helpers.make_yaml_file() or nil
            }))
        end)

        lazy_teardom(function()
            helpers.stop_kong(nil, true)
        end)

        before_each(function()
            client = helpers.proxy_client()
        end)

        after_each(function()
            if client then client:close() end
        end)

        describe("response", function()
            it("get a succesful status", function()
                local r = client.get("/request?name=test&orderby=addedDate", {
                    headers = { host = "test1.com" }
                })

                assert.response(r).has.status(200)
            end)
        end)
    end)
end
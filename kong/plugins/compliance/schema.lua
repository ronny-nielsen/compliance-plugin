local typedefs = require "kong.db.schema.typedefs"
local plugin_name = "compliance"

local schema = {
  name = plugin_name,
  fields = {
    { consumer = typedefs.no_consumer },
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { tenant_id = { type = "string", required = true, default = "-1" }, },
          { specification_id = { type = "string", required = true, default = "oas-id" }, },
          { environment = { type = "string", required = true, default = "production" }, }
        },
        entity_checks = {
          { at_least_one_of = { "tenant_id", "specification_id", "environment" } },
          { distinct = { "tenant_id", "specification_id", "environment" } }
        }
      },
    },
  },
}

return schema;
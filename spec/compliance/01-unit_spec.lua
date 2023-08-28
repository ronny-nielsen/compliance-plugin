local plugin_name = "compliance"

local validate do
    local validate_entity = require("spec.helpers").validate_pluging_config_schema
    local plugin_schema = require("kong.plugins" .. plugin_name .. ".schema") 

    function validate(data)
        return validate_entity(data, plugin_schema)
    end
end

describe(plugin_name .. ": (schema)", function()
    it("assign tenant id", function()
        local ok, err = validate({
            tenant_id = "7"
        })

        assert.is_nil(err)
        assert.is_truthy(ok)
    end)
end)
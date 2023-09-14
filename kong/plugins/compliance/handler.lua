local ltn12 = require("ltn12")
local http = require("socket.http")
local json = require("json")
local bearerToken = ""
local responseBody = ""

local Compliance = {
    VERSION = "1.0.2",
    PRIORITY = 1400
}

function generateToken(conf)
    local tenantId = conf["tenant_id"]
    local requestBody = '{ "aud": "gateway.apiway.net", "iss": "gateway.apiway.net", "tenantIdClaim": ' .. tenantId .. ' }'
    local body = {}

    local res, code, headers, status = http.request {
        method = "POST",
        url = "https://mock.api.apiway.net/v1/token",
        source = ltn12.source.string(requestBody),
        headers = {
            ["content-type"] = "application/json",
            ["content-length"] = string.len(requestBody)
        },
        sink = ltn12.sink.table(body)
    }

    local response = table.concat(body)
    local decode = json.decode(response)
    local token = decode["value"]
    bearerToken = "Bearer " .. token

    kong.log.debug("extracted valid token from response")

    return response;
end

function sendRequest(conf){
  kong.log.debug("Sending request to compliance")
  local headers = kong.request.get_headers()
  local fullpath = kong.request.get_path_with_query()
  local method = kong.request.get_method()
  local path = kong.request.get_path()
  local requestBody = kong.response.get_body()
  local querystring = string.gsub(fullpath, path, "")

  headers["host"] = nil
  headers["Authorization"] = bearerToken
  headers["x-compliance-specification-id"] = conf["specification-id"]
  headers["x-compliance-http-path"] = path
  headers["x-compliance-http-method"] = method
  headers["x-compliance-flow-type"] = "consumer"
  headers["x-compliance-environment"] = conf["environment"]

  for k,v in pairs[headers] do
    kong.log.debug(k, ": ", v)
  end

  local body = {}

  local res, code, responseHeaders, status = http.request {
    method = "POST",
    url = "https://compliance.api.apiway.net/v1",
    source = ltn12.source.string(requestBody),
    headers = headers,
    sink = ltn12.sink.table(body)
  }

  local response = table.concat(body)
  kong.log.debug(res)
  kong.log.debug(code)
  local decode = json.decode(response)

  if decode ~= nil then
    for k,v in pairs[decode] do
      kong.log.debug(k, ": ", v)
    end
  end

  return response
}

function sendResponse(conf){
  kong.log.debug("Sending response to compliance")
  local headers = kong.request.get_headers()
  local path = kong.request.get_path()
  local method = kong.request.get_method()
  local status = kong.response.get_status()
  local requestBody = responseBody

  headers["Authorization"] = bearerToken
  headers["x-compliance-specification-id"] = conf["specification-id"]
  headers["x-compliance-http-path"] = path
  headers["x-compliance-http-method"] = method
  headers["x-compliance-http-status"] = status
  headers["x-compliance-flow-type"] = "producer"
  headers["x-compliance-environment"] = conf["environment"]

  for k,v in pairs[headers] do
    kong.log.debug(k, ": ", v)
  end

  local body = {}

  local res, code, responseHeaders, status = http.request {
    method = "POST",
    url = "https://compliance.api.apiway.net/v1",
    source = ltn12.source.string(requestBody),
    headers = headers,
    sink = ltn12.sink.table(body)
  }

  local response = table.concat(body)
  kong.log.debug(res)
  kong.log.debug(code)
  local decode = json.decode(response)

  if decode ~= nil then
    for k,v in pairs[decode] do
      kong.log.debug(k, ": ", v)
    end
  end

  return response
}

function Compliance:init_worker()
    -- Implement logic for the init_worker phase here (http/stream)
    kong.log("init_worker")
end

function Compliance:preread()
    -- Implement logic for the preread phase here (stream)
    kong.log("preread")
end

function Compliance:certificate(config)
    -- Implement logic for the certificate phase here (http/stream)
    kong.log("certificate")
end

function Compliance:rewrite(config)
    -- Implement logic for the rewrite phase here (http)
    kong.log("rewrite")
end

function Compliance:access(config)
    -- Implement logic for the access phase here (http)
    kong.log("access")
    generateToken(config)
    sendRequest(config)
end
function Compliance:ws_handshake(config)
    -- Implement logic for the WebSocket handshake here
    kong.log("ws_handshake")
  end
  
  function CustomHandler:header_filter(config)
    -- Implement logic for the header_filter phase here (http)
    kong.log("header_filter")
  end
  
  function Compliance:ws_client_frame(config)
    -- Implement logic for WebSocket client messages here
    kong.log("ws_client_frame")
  end
  
  function Compliance:ws_upstream_frame(config)
    -- Implement logic for WebSocket upstream messages here
    kong.log("ws_upstream_frame")
  end
  
  function Compliance:body_filter(config)
    -- Implement logic for the body_filter phase here (http)
    kong.log("body_filter")
    responseBody = kong.response.get_raw_body()
    kong.log.debug(responseBody)
  end
  
  function Compliance:log(config)
    -- Implement logic for the log phase here (http/stream)
    kong.log("log")
    sendResponse(config)
  end
  
  function Compliance:ws_close(config)
    -- Implement logic for WebSocket post-connection here
    kong.log("ws_close")
  end

  return Compliance
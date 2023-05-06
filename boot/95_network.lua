local fs = require("filesystem")
require "file"

local network_path = "/etc/network/"
local file_name = "interface"

local ip = "10.0.0.10"

local config = {
    ip = ip
}

if not fs.exists(network_path) then
    local result, reason = fs.makeDirectory(network_path)
    if not result then
        print("Error mkdir: " .. reason)
    end
end

write_config(network_path .. file_name, "network", config)

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

local real, reason = fs.realPath(network_path .. file_name)
if real then
    local file
    if fs.realPath(real) then
        file = io.open(real, "w")
    end

    if file then
        write_config(file, "network", config)
        file:close()
    end
else
    print("Error: " .. reason) 
end
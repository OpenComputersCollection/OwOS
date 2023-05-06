local fs = require("filesystem")

local network_path = "/etc/network/"
local file_name = "interface"

local interface = "eth0"
local ip = "10.0.0.10"

local config = {
    interface = interface,
    ip = ip
}

local function config_writer(file)
    file:write("network = {\n")

    for key, value in pairs(config) do
        file:write(key .. "=" .. "\"" .. value .. "\"" .. ",\n")
    end

    file:write("}")
end

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
        config_writer(file)
        file:close()
    end
else
    print("Error: " .. reason) 
end
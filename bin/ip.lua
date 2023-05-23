local filesystem = require("filesystem")
local cw = require "file"

local network_config = "/etc/network/interface"

local table = cw.read_config(network_config)

for k, v in pairs(table) do
    print(k, ":", v)
end
    
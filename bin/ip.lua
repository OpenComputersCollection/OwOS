local filesystem = require("filesystem")

local network_config = "/etc/network/interface"
local configEnv = {} -- Create a variable in which it will be stored

-- Here we are loading the file with the path, the mode "t" (Only text chunks.) and out variable in which we will load the config
local f, err = loadfile(network_config, "t", configEnv) -- load the file
if f then
    f() -- run the chunk
    -- now configEnv should now contain our data
    for k, v in pairs(configEnv.network) do
        print(k, ":", v)
    end
else
    error(err)
end

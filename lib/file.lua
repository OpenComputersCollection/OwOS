local filesystem = require("filesystem")

local M = {}

function M.read_config(path)
    local table = {} -- Create a variable in which it will be stored
    -- Here we are loading the file with the path, the mode "t" (Only text chunks.) and out variable in which we will load the config
    
    local file = assert(io.open(path, "a"))
    file:write("")
    file:close()
    
    file = assert(io.open(path, "rb"))

    if not file then return {} end

    local content = file:read("*all")

    file:close()

    local key = ""
    local value = ""

    for line in string.gmatch(content, "([^,\n]+)") do
        for v in string.gmatch(line, "([^=^]+)") do
            if key == "" then
                key = v
            else
                value = v
            end
        end
        table[key] = value

        key = "" 
        value = ""
    end

    return table
end

function M.read_config_key(path, wantedKey)
    local file = assert(io.open(path, "a"))
    file:write("")
    file:close()
    
    file = assert(io.open(path, "rb"))

    if not file then return {} end

    local content = file:read("*all")

    file:close()

    local key = ""
    local value = ""

    for line in string.gmatch(content, "([^,\n]+)") do
        for v in string.gmatch(line, "([^=^]+)") do
            if key == "" then
                key = v
            else
                value = v
            end
        end

        if key == wantedKey then
            return value
        end

        key = "" 
        value = ""
    end

    return nil
end

-- config_writer
-- path: the path to write to
-- config: the config module
function M.write_config(path, config)
    -- Checking if file exists
    local real, reason = filesystem.realPath(path)
    if real then
        local file
        if filesystem.realPath(real) then
            -- Open file
            file = io.open(real, "w")
        end
        if file then
            
            -- Go through all config fields
            for key, value in pairs(config) do
                file:write(key .. "=" ..  value .. ",\n")
            end

            file:close()
        end
    else
        print("Error: " .. reason)
    end
end

return M
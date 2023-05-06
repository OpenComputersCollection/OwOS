function read_config(path)
    local file = {} -- Create a variable in which it will be stored
    -- Here we are loading the file with the path, the mode "t" (Only text chunks.) and out variable in which we will load the config
    local f,err = loadfile(path, "t", file) -- load the file
    if f then
       f() -- run the chunk
       -- now file should now contain our data
       return file -- table
    else
       return err
    end
end

-- config_writer
-- file: the file to write in
-- name: name of the whole module
-- config: the config module
function write_config(file, name, config)
    -- Write start of config 
    file:write(name .. " = {\n")

    -- Go through all config fields
    for key, value in pairs(config) do
        file:write(key .. "=" .. "\"" .. value .. "\"" .. ",\n")
    end

    -- End the config
    file:write("}\n")
end

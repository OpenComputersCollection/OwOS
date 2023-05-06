local fs = require("filesystem")
local component = require("component")
local thread = require("thread")
local event  = require "event"

require "file"

local network_path = "/etc/network/"
local file_name = "interface"
local port = 11
local port_extern = 10
local message_word = "getIp"
local timeout = 10

local config = {
    gateway = nil,
    ip = nil
}

if not fs.exists(network_path) then
    local result, reason = fs.makeDirectory(network_path)
    if not result then
        print("Error mkdir: " .. reason)
    end
end

component.modem.open(port)

local t = thread.create(function() 

    while not config.ip do
        component.modem.broadcast(port_extern, message_word)

        local _, _, id, _, _, message = event.pull(timeout, "modem_message")

        if message then
            config.ip = message
            config.gateway = id
        end
    end

end):detach()

if t then
    t:join()

    write_config(network_path .. file_name, "network", config) 
else 
    error("Get ip thread died abruptly")
end

component.modem.close(port)

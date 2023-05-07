local fs = require("filesystem")
local component = require("component")
local thread = require("thread")
local event = require "event"
local cw = require("file")

local network_path = "/etc/network/"
local file_name = "interface"
local port = 10
local message_word = "getIp"
local timeout = 10
local protocol_response = "DHCP_RESPONSE"
local protocol_request = "DHCP_REQUEST"

local config = {
    gateway = nil,
    ip = nil
}

function start()
    if not fs.exists(network_path) then
        local result, reason = fs.makeDirectory(network_path)
        if not result then
            print("Error mkdir: " .. reason)
        end
    end

    component.modem.open(port)

    local t = thread.create(function()

        while not config.ip do
            component.modem.broadcast(port, protocol_request, message_word)

            local function filterDHCPResponse(type, dest, origin, port, _, protocol)
                -- check if the request is an arp request and if it is on the right port and if it is directed to this device
                if type ~= "modem_message" or port ~= 10 or protocol ~= protocol_response then
                    return false
                end
                return true
            end

            local _, _, id, _, _, protocol, message = event.pullFiltered(filterDHCPResponse)
            
            if message then
                config.ip = message
                config.gateway = id
            end

        end

        cw.write_config(network_path .. file_name, config)
    end):detach()
end

function stop()
    component.modem.close(port)
end

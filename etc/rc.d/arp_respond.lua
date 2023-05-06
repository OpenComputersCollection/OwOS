local component = require("component")
local thread = require("thread")
require "file"

local function filterARP(type, dest, origin, port, _, protocol, ip_address)
    if type ~= "modem_message" or port ~= 1 or protocol ~= "ARP_DISCOVER" then
        return false
    end
    return true
end

function start()
    thread.create(function()
        if component.isAvailable("modem") then
            while true do
                local type, dest, origin, port, distance, protocol, ip_address = event.pullFiltered(filterARP)
                -- check if the arp request is directed to this device
                if ip_address == loadfile("/etc/network/interface")["network"]["ip"] then
                    component.modem.send(origin, 1, "ARP_RESPOND", ip_address)
                end
            end
        end
    end)
end

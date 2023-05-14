local component = require("component")
local thread = require("thread")
local event = require("event")
local file = require("file")

local function filterARP(type, dest, origin, port, _, protocol, ip_address)
    -- check if the request is an arp request and if it is on the right port and if it is directed to this device
    if type ~= "modem_message" or port ~= 1 or protocol ~= "ARP_DISCOVER" or ip_address ~= file.read_config_key("/etc/network/interface", "ip") then
        return false
    end
    return true
end

function start()
    thread.create(function()
        if component.isAvailable("modem") then
            component.modem.open(1)
            while true do
                local type, dest, origin, port, distance, protocol, ip_address = event.pullFiltered(filterARP)
                component.modem.send(origin, 1, "ARP_RESPOND", ip_address)
            end
        end
    end)
end

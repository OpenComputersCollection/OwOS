local component = require("component")
local event = require("event")
local file = require("file")

local arp_path = "/etc/network/"
local arp_cache = "arp.cache"

local function filterARP(type, dest, origin, port, _, protocol, ip_address)
    if type ~= "modem_message" or port ~= 1 or protocol ~= "ARP_RESPOND" then
        return false
    end
    return true
end

function discover(destinationIP)
    -- protocol, destination device ip
    if component.isAvailable("modem") and component.modem.isOpen(1) then
        component.modem.broadcast(1, "ARP_DISCOVER", destinationIP)
        local type, dest, origin, port, distance, protocol, ip_address = event.pullFiltered(1, filterARP)

        local config_load = file.read_config(arp_path .. arp_cache)
        config_load[destinationIP] = origin
        file.write_config(arp_path .. arp_cache, config_load)
    end
end
local component = require("component")
local filesystem = require("filesystem")
local event = require("event")
local thread = require("thread")
local file = require("file")

local config_file = "/etc/network/iptable"
local config_interface_file = "/etc/network/interface"
local base_ip = "10.0.0."
local ip_start = 10
local message_word = "getIp"
local port = 10
local protocol_response = "DHCP_RESPONSE"
local protocol_request = "DHCP_REQUEST"

local router_config = {
    ip = base_ip .. "1"
}

local router_thread

function start()
    if not filesystem.exists("/etc/network/") then
        local result, reason = filesystem.makeDirectory("/etc/network/")
        if not result then
            print("Error mkdir: " .. reason)
        end
    end

    file.write_config(config_interface_file, router_config)

    local ipTabel = file.read_config(config_file)

    router_thread = thread.create(function()

        -- Open port 10 for DHCP
        component.modem.open(port)

        while true do

            local function filterDHCPRequest(type, dest, origin, port, _, protocol, message)
                -- check if the request is an arp request and if it is on the right port and if it is directed to this device
                if type ~= "modem_message" or port ~= 10 or protocol ~= protocol_request or message ~= message_word then
                    return false
                end
                return true
            end

            -- listen for DHCP ip request
            -- There is a timeout so if the thread gets killed it will stop and not freeze
            _, _, id, _, _, protocol, message = event.pullFiltered(filterDHCPRequest)
            local setIp = nil

            -- Fuck you LUA
            local lengthNum = 0
            for k, v in pairs(ipTabel) do -- for every key in the table with a corresponding non-nil value 
                -- search if id alredy registred
                if v == id then
                    setIp = k
                end

                lengthNum = lengthNum + 1
            end

            if not setIp then
                -- Set the last number of the ip
                setIp = base_ip .. ip_start + lengthNum
                -- remember ip and id of computer
                ipTabel[setIp] = id
                -- update config file
                file.write_config(config_file, ipTabel)
            end

            -- wait for Computer to switch to puller
            os.sleep(1)
            -- send ip to computer
            component.modem.send(id, port, protocol_response, setIp)

        end
    end):detach()
end

function stop()
    if dhcp_thread then
        thread.kill(router_thread)
    end

    component.modem.close(port)
end


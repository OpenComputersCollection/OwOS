local component = require("component")
local event = require("event")
local thread = require("thread")


local base_ip = "10.0.0."
local ip_start = 10
local message_word = "getIp"
local port = 10
local port_extern = 11


function start()
    local t = thread.create(function()
        local ipTabel = {}

        -- Open port 10 for DHCP
        component.modem.open(port)
    
        while component.modem.isOpen(port) do
            -- listen for DHCP ip request
            -- There is a timeout so if the thread gets killed it will stop and not freeze
            _, _, id, _, _, message = event.pull(port,"modem_message")

            if message == message_word then
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
                end
          
                -- wait for Computer to switch to puller
                os.sleep(1)
                -- send ip to computer
                component.modem.send(id, port_extern, setIp)
            end
        end
      end):detach()
end

function stop()
    component.modem.close(port)
end


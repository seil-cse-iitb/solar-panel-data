-- file: setup.lua
local module = {}

failCounter = 0
module.apDetected = false

local function wifi_wait_ip()  
  if wifi.sta.getip()== nil then
    print("IP unavailable, Waiting...")
  else
    tmr.stop(1)
    print("\n====================================")
    print("ESP8266 mode is: " .. wifi.getmode())
    print("MAC address is: " .. wifi.ap.getmac())
    print("IP is "..wifi.sta.getip())
    print("====================================")
    server.start()
  end
end

local function wifi_start(list_aps)  
    print("Inside wifi start function")
    print("Access Points is there")
    i=0
    while i <= 2 do
        i = i + 1
        for key, value in pairs(list_aps) do
            --print(key .. " : " .. config.SSID[key])
            --print(config.SSID[key])
            if key and config.SSID[key] then
                apDetected = true
                print("found the interested AP")
                print(config.SSID[key])
                break
            end
        end
        tmr.delay(2500000)
    end

    if not apDetected then
        uart_rw.start()  
        print("Unable to find the access point")
        uart_rw.uart_write('$CF000$')
        --dataToSend = "$" .. "00000" .. "$"
        --dataToSend = "$" .. uart_rw.currentSequenceString .. "$"
        --print("Data to be sent" .. dataToSend)
        --uart_rw.uart_write(dataToSend)
        uart_rw.uart_read() 
    else
        uart_rw.uart_write('$CT000$')        
        if list_aps then
            for key,value in pairs(list_aps) do
                if config.SSID and config.SSID[key] then
                    wifi.setmode(wifi.STATION);
                    --wifi.sta.setip({ip=config.IP,netmask=config.NETMASK,gateway=config.GATEWAY})
                    wifi.sta.config(key,config.SSID[key])
                    wifi.sta.connect()
                    print("Connecting to " .. key .. " ...")
                    --config.SSID = nil  -- can save memory
                    tmr.alarm(1, 2500, 1, wifi_wait_ip)
                end
            end
        else
            print("Error getting AP list")
        end
    end
end

function module.start()  
  print("Configuring Wifi ...")
  wifi.setmode(wifi.STATION);   -- Sets nodemcu to station mode
  wifi.sta.getap(wifi_start)    -- Scans all the access points and returns its list
end

return module 


-- file: setup.lua
local module = {}

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
      tmr.unregister(2)
    app.start()
  end
end

local function wifi_start(list_aps)  
    if list_aps then
        for key,value in pairs(list_aps) do
            if config.SSID and config.SSID[key] then
                wifi.setmode(wifi.STATIONAP)
                wifi.sta.config(key,config.SSID[key])
                local cfg={}
     print("configuring as station") 
     cfg.ssid="test";
     cfg.pwd="12345678"
     wifi.ap.config(cfg)
     cfg={}
     cfg.ip="192.168.4.1";
     cfg.netmask="255.255.255.0";
     cfg.gateway="192.168.4.1";
     wifi.ap.setip(cfg);
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

function module.start()  
  print("Configuring Wifi ...")
  wifi.setmode(wifi.STATIONAP)
  wifi.sta.getap(wifi_start)
   tmr.alarm(2, 10000,tmr.ALARM_AUTO, function()
 wifi.setmode(wifi.STATIONAP);
 wifi.sta.getap(wifi_start)
 end)
 tmr.start(2)
end

return module  

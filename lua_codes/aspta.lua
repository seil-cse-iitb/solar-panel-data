 local module = {}
 local comm
flag=0
abc="000000"
SEQNO=""
local function get_data()

--print("ESP8266 Client")

         -- tmr.alarm(2, 100, 1, function() 
            uart.on("data","\r",
              function(data)
              --  print("receive from uart:", data)
                abc=data
                flag=1
                m:publish("location1/" .. "east2/".."msg",abc,2,0)
                if data=="quit\r" then
                  uart.on("data") -- unregister callback function
                end
            end, 0)

 if(flag==1) then
      --   cl:send(abc)
      --   m:publish("nodemcu/" .. "peer1/".."msg",abc,2,0)
          --  print("msg send")
         end
         flag=0

         --[[
            uart.on("data",44, 
                    function(data)
                        print("Received from Arduino:", data)
                       abc = data
                       flag=1
                     end, 0)
      ]]--
   --       end)



--[[
     tmr.alarm(3, 2000, 1, function() 
            uart.on("data", "\f",
              function(data)
                print("receive from char:", data)
                abc=data
                flag=1
                if data=="quit\f" then
                  uart.on("data") -- unregister callback function
                end
            end, 0)

 if(flag==1) then
      --   cl:send(abc)
        --  m:publish("nodemcu/" .. "peer1",abc,2,0)
            print("ackmsg")
         end
         flag=0

        
            uart.on("data",44, 
                    function(data)
                        print("Received from Arduino:", data)
                       abc = data
                       flag=1
                     end, 0)
     
          end) ]]--

end
 
 local function star()
 
 --print("Ready to start soft ap AND station")

     local str=wifi.ap.getmac();
     local ssidTemp=string.format("%s%s%s",string.sub(str,10,11),string.sub(str,13,14),string.sub(str,16,17));
 -- print("ssid_TEmp"..ssidTemp)
     
     
     
   --  wifi.sta.config("SEIL","deadlock123")
   --  wifi.sta.connect()
     
     local cnt = 0
     gpio.mode(0,gpio.OUTPUT);
     tmr.alarm(0, 5000, 1, function() 
         if (wifi.sta.getip() == nil) and (cnt < 50) then 
           --  print("\n\nTrying Connect to Router, Waiting...")
             cnt = cnt + 1 
                 if cnt%2==1 then gpio.write(0,gpio.LOW);
                  else gpio.write(0,gpio.HIGH); end
         else 
             tmr.stop(0);
             tmr.stop(4);
           --  print("\n\n\nSoft AP started")
            -- print("Heep:(bytes)"..node.heap());
            -- print("MAC:"..wifi.ap.getmac().."\r\nIP:"..wifi.ap.getip());
             if (cnt < 50) then-- print("Conected to Router\r\nMAC:"..wifi.sta.getmac().."\r\nIP:"..wifi.sta.getip())
                       --code of tcp server
                     --   print("Server IP Address:",wifi.ap.getip())

                                sv = net.createServer(net.TCP) 
                               -- print(sv)
                              -- print("\n\n\n\n\n\nThis is svsvsvsvsv         ")
                                sv:listen(88, function(conn)
                               
                                    conn:on("receive", function(conn, receivedData) 
                                    print("Received Data: " .. receivedData)
                                    -- print(type(conn))
                                     comm=conn
                              
                                         m:publish("nodemcu/" .. "peer2/msg",receivedData,0,0)         
                                    end) 
                                    conn:on("sent", function(conn) 
                                      collectgarbage()
                                    end)
                                end)
                                                        
                                                        
                        --end code tcp server
                      --  app.start()
                 else --print("Conected to Router Timeout")
             end
             gpio.write(0,gpio.LOW);
             cnt = nil;cfg=nil;str=nil;ssidTemp=nil;
             collectgarbage()
         end 
     end)
end

local function send_ping()  
   -- m:publish(config.ENDPOINT .. "ping","id=" .. config.ID,0,0)
   --  print("nnnnnnn" .. " lasttempo")  
       -- uart.write(0,string.byte("ram"))
       if wifi.sta.status() ~= 5 or wifi.sta.getip() == nil then 
 --print ("Wifi down restaring boom boom!")

   tmr.unregister(6)
 setup.start()


 end
        get_data()

          if(flag==1) then
      --   cl:send(abc)
         -- m:publish("nodemcu/" .. "peer1/".."msg",abc,2,0)
        --    print("msg send")
         end
         flag=0
    
 --    print("las t" .. " after")
end

-- Sends my id to the broker for registration
local function register_myself()  
    m:subscribe("location1/east2/ack",0,function(conn)
    --   print("Successfully subscribed to data endpoint")
    end)
    --m:subscribe("nodemcu/peer2/ack",0,function(conn)
    --    print("Successfully subscribed to data endpoint")
    --end)
end

local function mqtt_start()  
    m = mqtt.Client(node.chipid(), 120)
    -- register message callback beforehand
    m:on("message", function(conn, topic, data) 
      if data ~= nil then
     --   print(topic .. ": " .. data)
             objProp = {}
             index = 1
            
        
             for value in string.gmatch(data,'([^%s]+)') do 
            objProp [index] = value
         --       print("to the test "..index.." "..objProp[index])
            index = index + 1
            end
         --   print("index"..index)
         --   print("to the test "..objProp[1])
        
            PEERID = objProp[1];
            SEQNO = objProp[2];

           -- print(PEERID.." "..SEQNO)
            --if(PEERID=="P1") then
       --     print (uart.getconfig(0))
       --     print("HELLO WORLD\n\n\n\n")
                -- uart.write(0,string.byte(SEQNO,1),string.byte(SEQNO,2),string.byte(SEQNO,3),string.byte(SEQNO,4),string.byte(SEQNO,5))
           --  uart.write(0,string.char(53))--,string.char(48),string.char(48),string.char(48),string.char(53))
              uart.write(0,"$"..SEQNO.."$")
                 --end
           -- if(PEERID=="P2") then
       --     print (uart.getconfig(0))
       --     print("HELLO WORLD\n\n\n\n")
                -- uart.write(0,string.byte(SEQNO,1),string.byte(SEQNO,2),string.byte(SEQNO,3),string.byte(SEQNO,4),string.byte(SEQNO,5))
           --  uart.write(0,string.char(53))--,string.char(48),string.char(48),string.char(48),string.char(53))
              --   print("\nssssssssssssssssss"..SEQNO)
                --  comm:send(SEQNO)
               --end
        -- do something, we have received a message
      end
    end)
-- when offline
m:on("offline", function(client)
    --m:stop()
    node.restart()
   --- print("MQTT: connection failed with reason 0000000000000000000000000000000000000000000000000000")
    
end)

    
    -- Connect to broker
    test=m:connect(config.HOST, 1883, 0, 0, function(con) 
        if(test == true) then
         tmr.unregister(1)
         end
        
        
        register_myself()
        -- And then pings each 1000 milliseconds
        tmr.stop(6)
      --  print("sending tempointh")
        --tmr.delay(100) 
   --     print("timer")
        
    tmr.alarm(6, 5000, 1, send_ping)
        send_ping()
        --print("Going to Deep Sleep mode")
        -- Deep sleep code 
		--tmr.delay(500000)
		--node.dsleep(0)         
    end) 
    -- tmr.alarm(4, 5000, 1, function()
    
    --print("Going for star.****************************************************************************************")
    star()
--end)
end



function module.start()  
--print("starting star")
 uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
  tmr.alarm(1, 3000, 1, function() 
 mqtt_start()
end)

end

return module

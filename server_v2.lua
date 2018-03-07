
local module = {}

local line = ""		-- Variable which stores current line read from the file
local dataAtLine = 0	-- Tracks which line is reading
local solarFileSize = 0
local dataFile = ""

module.dd = ""
module.hh = ""
module.mm = ""
module.timeStamp = ""
-- Callback function
-- Line to be added : HTTP/1.1 200 OK
-- Content-Length: 150
-- http://IPADDRESS/solarData.txt?timestamp=97834083049

function receiver(sck, data)
	-- body
	-- Holds the name of the file which has to be returned on each call
    targetFile = string.sub(data,string.find(data,"GET /")
              +5,string.find(data,"HTTP/")-2)
    
    if ((targetFile ~= "") or (targetFile ~= "delete?") or (targetFile ~= "id?")) then
        uart_rw.start()
        dataFile = string.sub(targetFile, 0,13)
        module.timeStamp = string.sub(targetFile, 15, 20)
        --print("Timestamp is " .. module.timeStamp)
        module.dd = string.sub(module.timeStamp, 1, 2)
        module.hh = string.sub(module.timeStamp, 3, 4)
        module.mm = string.sub(module.timeStamp, 5, 6)
        --print("Date: " .. module.dd)
        --print("Hour: " .. module.hh)
        --print("Minute: " .. module.mm)
        
    else
        dataFile = targetFile
    end

    --print("Data file is " .. dataFile)
              
	print(data)

	-- Callback function on each click.
	local function send(localSocket)
		-- body
        -- Opens the particular file.
        
            if dataFile == "solarData.txt" then
                --txtFile = file.open("solarData.txt", "r")
                file.open("solarData.txt", "r")
            elseif  dataFile  == "delete?" then
                -- Delete the file
                file.remove("solarData.txt")
                --fileData = file.list()
                --    for k, v in pairs(fileData) do 
                --        if k == "solarData.txt" then
                --        print("name: " .. k .. ", size: " .. v)
                --        end
                --    end
                file.open("first_page.htm", "r")
            elseif dataFile == "id?" then
                file.open("id.txt")
                --txtFile = file.open("first_page.htm", "r")
                --file.open("first_page.htm", "r")
            else 
                file.open("first_page.htm", "r")
            end
        
        if dataAtLine == 0 then
            localSocket:send("HTTP/1.1 200 OK\n")
            if dataFile == "solarData.txt" then
                localSocket:send("Content-Length: ")
                localSocket:send(solarFileSize)
                localSocket:send("\n")
                uart_rw.start() 
                uart_rw.uart_write('$00SOF$')
            end
            localSocket:send("\n")
            --localSocket:send("\n")
        end
        file.seek("set", dataAtLine)
        line = file.read('\n')
        if line then
            if string.len(line) > 0 then
                dataAtLine = dataAtLine + string.len(line)
             end
        else
            if dataFile == "solarData.txt" then
                uart_rw.start() 
                uart_rw.uart_read()
                --tmr.delay(50000)
                if(uart_rw.rtcTs ~= module.timeStamp) then
                    uart_rw.start() 
                    --print("Received Timestamp is " .. tostring(123456))
                    --print("RTC      Timestamp is " .. uart_rw.rtcTs)
                    --uart_rw.uart_write('$H00'.. module.hh .. '$' .. '$D00'.. module.dd .. '$' .. '$M00'.. module.mm .. '$')
                    --tmr.delay(10000)
                    --uart_rw.uart_write('$D00'.. module.dd .. '$')
                    --tmr.delay(10000)
                    --uart_rw.uart_write('$M00'.. module.mm .. '$')
                    --tmr.delay(10000)
                end
                uart_rw.start()
                --uart_rw.uart_write('$000CF$')
                uart_rw.uart_write("$T" .. module.dd .. module.hh .. module.mm .. "$")
                tmr.delay(100000)
                uart_rw.uart_unregister()
                --tmr.delay(500000)
            end
            --print("End of the File")
            dataAtLine = 0
            
        end
        file.close()
        
	    if line then
			localSocket:send(line)
            --print("----Sending " .. line .. " ----")
		else
	        localSocket:close()
           
            if dataFile == "solarData.txt" then
                
                --uart_rw.start()
                --uart_rw.uart_write('$H0001$')
                --$D0020$$M0001$')
                --uart_rw.uart_write('$0H0'.. module.hh .. '$')
                --tmr.delay(500000)
                --uart_rw.uart_write('$0D0'.. module.dd .. '$') 
                --tmr.delay(500000)
                --uart_rw.uart_write('$0M0'.. module.mm .. '$')
                --tmr.delay(500000)
                --uart_rw.uart_write('$00EOF$')
                --tmr.delay(100000)
            end
			line = ""
		end
	end
    
	sck:on("sent", send)

	send(sck)
end

function disconnection(sck, data)
    print("Disconnected from the HTTP")
    esp.restart()
end

function module.start()
	print("Staring Web Server")
	srv = net.createServer(net.TCP) -- Can we give timeout here.

    fileData = file.list()
    for k, v in pairs(fileData) do 
        if k == "solarData.txt" then
            solarFileSize = v
            --print("name: " .. k .. ", size: " .. solarFileSize)
            --print(type(v))
            
        end
    end
    
	srv:listen(80, function(conn)
	    conn:on("receive", receiver)
        conn:on("disconnection", disconnection)
	end)

    --srv:on("recieve", function(sck, c) print(c) end) 
end

return module  

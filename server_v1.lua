
local module = {}

local line = ""		-- Variable which stores current line read from the file
local dataAtLine = 0	-- Tracks which line is reading
local solarFileSize = 0
local dataFile = ""
module.dd = ""
module.hh = ""
module.mm = ""
-- Callback function
-- Line to be added : HTTP/1.1 200 OK
-- Content-Length: 150
-- http://IPADDRESS/solarData.txt?timestamp=97834083049

function receiver(sck, data)
	-- body
	-- Holds the name of the file which has to be returned on each call
    targetFile = string.sub(data,string.find(data,"GET /")
              +5,string.find(data,"HTTP/")-2)
    
    if ((targetFile ~= "") or (targetFile ~= "delete?")) then
        dataFile = string.sub(targetFile, 0,13)
        timeStamp = string.sub(targetFile, 15, 20)
        print("Timestamp is ")
        module.dd = string.sub(timeStamp, 1, 2)
        module.hh = string.sub(timeStamp, 3, 4)
        module.mm = string.sub(timeStamp, 5, 6)
        print("Date: " .. module.dd)
        print("Hour: " .. module.hh)
        print("Minute: " .. module.mm)
    else
        dataFile = targetFile
    end

    print("Data file is " .. dataFile)
              
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
        else
            --txtFile = file.open("first_page.htm", "r")
            file.open("first_page.htm", "r")
        end
        
        if dataAtLine == 0 then
            localSocket:send("HTTP/1.1 200 OK\n")
            localSocket:send("Content-Length: ")
            localSocket:send(solarFileSize)
            localSocket:send("\n")
            localSocket:send("\n")
            localSocket:send("\n")
        end
        file.seek("set", dataAtLine)
        line = file.read('\n')
        if line then
            if string.len(line) > 0 then
                dataAtLine = dataAtLine + string.len(line)
             end
        else
            print("End of the File")
            dataAtLine = 0
        end
        file.close()
        
	    if line then
			localSocket:send(line)
		else
	        localSocket:close()
			line = ""
		end
	end
    
	sck:on("sent", send)

	send(sck)
end


function module.start()
	print("Staring Web Server")
	srv = net.createServer(net.TCP)

    fileData = file.list()
    for k, v in pairs(fileData) do 
        if k == "solarData.txt" then
            solarFileSize = v
            print("name: " .. k .. ", size: " .. solarFileSize)
            print(type(v))
            
        end
    end
	srv:listen(80, function(conn)
	    conn:on("receive", receiver)
	end)
end

return module  



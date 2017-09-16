
local module = {}

local line = ""		-- Variable which stores current line read from the file
local dataAtLine = 0	-- Tracks which line is reading

-- Callback function
function receiver(sck, data)
	-- body
	-- Holds the name of the file which has to be returned on each call
    targetFile = string.sub(data,string.find(data,"GET /")
              +5,string.find(data,"HTTP/")-2)
   	print("target file is " .. targetFile)
              
	print(data)

	-- Callback function on each click.
	local function send(localSocket)
		-- body
        -- Opens the particular file.
        if targetFile == "solarData.txt" then
            --txtFile = file.open("solarData.txt", "r")
            file.open("solarData.txt", "r")
        else
            --txtFile = file.open("first_page.htm", "r")
            file.open("first_page.htm", "r")
        end

        -- 
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

	srv:listen(80, function(conn)
	    conn:on("receive", receiver)
	end)
end

return module  

-- code to read/write frpm/to UART

local module = {}  

module.currentSequenceString = "00000"
module.fileSize = ""

function module.uart_read()
	-- body
	uart.on("data", '\n',
		function(data)
			--print("Data from the UART is " .. data .. " with type of " .. type(data))
            -- Stores the current sequence number and sends it via UART on wake up
            module.currentSequenceString = string.sub(data, 0, 5)
            currentSequence = tonumber(currentSequenceString)
            print("Sequence number is ")
            print(module.currentSequenceString)
            --print("with Data type " .. type(currentSequence))
            --currentSequence = string.char(string.byte(data, 0, 1, 2, 3, 4))
			--print("The sequence number is " .. currentSequence)
            if data=="quit" then
                
                print("Unsubscribing to the UART")
                uart.on("data")
            else 
                print("Not a valid string")    
            end

			if file.open("solarData.txt", "a+") then
                fileData = file.list()
                for k, v in pairs(fileData) do 
                    if k == "solarData.txt" then
                    print("name: " .. k .. ", size: " .. v)
                    print(type(v))
                    module.fileSize = v
                    end
                end
            
                print("Writing to the file")
				file.write(data)
				file.close()
			end
            remaining, used, total = file.fsinfo()
	    end,
	0)
end

function module.uart_write(serialData)
	uart.write(0, serialData)
end

function module.start()
	print("Receiving data from the UART")

	uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
    --uart_read()
end

return module  

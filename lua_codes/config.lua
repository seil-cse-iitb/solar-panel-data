-- file : config.lua
local module = {}

module.SSID = {}  
module.SSID["RPi_AP_001"] = "Raspberry"
--module.SSID["SEIL"] = "deadlock123"

module.HOST = "192.168.42.1"
--module.HOST = "10.196.20.44"  
module.PORT = 1883
module.ID = node.chipid()

module.ENDPOINT = "location1/east2/"
return module

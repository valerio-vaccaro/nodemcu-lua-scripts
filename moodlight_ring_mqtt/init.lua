-- Based on code from Sebastian Hodapp
-- https://github.com/sebastianhodapp/ESPbootloader
-- https://github.com/carlsa/ESPbootloader

-- Change ssid and password of AP in configuration mode
ssid = "ESP8266_"..node.chipid()
psw  = "espconfig"

if pcall(function ()
	dofile("config.lc")
end) then
	print("Connecting to WIFI...")

	wifi.setmode(wifi.STATION)
	wifi.sta.config(ssid,password)
	wifi.sta.connect()

	tmr.alarm(1, 1000, 1, function()
		if wifi.sta.getip() == nil then
			print("IP unavaiable, waiting.")
		else
			tmr.stop(1)
			print("Connected, IP is "..wifi.sta.getip())
			dofile("run_program.lua")
		end
	end)
else
	print("Enter configuration mode")
	dofile("run_config.lua")
end

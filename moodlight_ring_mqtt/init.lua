-- Based on code from Sebastian Hodapp
-- https://github.com/sebastianhodapp/ESPbootloader
-- https://github.com/carlsa/ESPbootloader

-- Change ssid and password of AP in configuration mode
ssid = "ESP8266_"..node.chipid()
psw  = "espconfig"

BRIGHT     = 0.99
ON         = BRIGHT * 255
BUTTON_PIN = 3       -- GPIO0
LED_PIN    = 4       -- GPIO2
PIXELS     = 16
TIME_ALARM = 25      -- 0.025 second, 40 Hz
TIME_SLOW  = 500000  -- 0.500 second,  2 Hz

RED   = string.char( 0, ON,  0)
GREEN = string.char(ON,  0,  0)
BLUE  = string.char( 0,  0, ON)
WHITE = string.char(ON, ON, ON)
BLACK = string.char( 0,  0,  0)

ws2812.writergb(LED_PIN, WHITE:rep(PIXELS))

if pcall(function ()
	dofile("config.lc")
end) then
	print("Connecting to WIFI...")

	wifi.setmode(wifi.STATION)
	wifi.sta.config(ssid,password)
	wifi.sta.connect()

	tmr.alarm(1, 1000, 1, function()
		if wifi.sta.getip() == nil then
            ws2812.writergb(LED_PIN, RED:rep(PIXELS))
			print("IP unavaiable, waiting.")
		else
			tmr.stop(1)
            ws2812.writergb(LED_PIN, GREEN:rep(PIXELS))
			print("Connected, IP is "..wifi.sta.getip())
			dofile("run_program.lua")
		end
	end)
else
    ws2812.writergb(LED_PIN, BLUE:rep(PIXELS))
	print("Enter configuration mode")
	dofile("run_config.lua")
end

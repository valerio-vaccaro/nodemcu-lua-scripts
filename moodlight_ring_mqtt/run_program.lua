-- Copyright (c) 2015 by Geekscape Pty. Ltd.  Licence LGPL V3.
--
-- http://www.esp8266.com/viewtopic.php?f=21&t=1143

BRIGHT     = 0.99
ON         = BRIGHT * 255
BUTTON_PIN = 3       -- GPIO0
LED_PIN    = 4       -- GPIO2
PIXELS     = 16
TIME_ALARM = 25      -- 0.025 second, 40 Hz
TIME_SLOW  = 500000  -- 0.500 second,  2 Hz

RED        = string.char( 0, ON,  0)
GREEN      = string.char(ON,  0,  0)
BLUE       = string.char( 0,  0, ON)
WHITE      = string.char(ON, ON, ON)
BLACK      = string.char( 0,  0,  0)

MQTT_user      = "guest"
MQTT_password  = "guest"
MQTT_ip        = "wpc.uk.to"
MQTT_port      = 1883

m = mqtt.Client("ESP8266_"..node.chipid(), 120, MQTT_user, MQTT_password)
m:lwt("/iot/T/esp8266/I/"..node.chipid().."/D/neopixel_moodlight/F/json", '{"d":{ "id"="'..node.chipid()..'", "status":"disconnected"}', 0, 0)

m:on("offline", function(con)
    print ("offline")
    tmr.start(5)
end)

-- on publish message receive event
m:on("message", function(conn, topic, data)
    print(topic .. ":" )
    if data ~= nil then
        print(data)
        ws2812.writergb(LED_PIN, data)
    end
end)

function connectionCheck()
    m:connect(MQTT_ip, MQTT_port, 0, function(conn)
        print("Connected to MQTT")
        m:subscribe("/iot/T/esp8266/I/"..node.chipid().."/C/neopixel_moodlight/F/hex",0, function(conn)
            m:subscribe("test",0, function(conn)
                m:publish("/iot/T/esp8266/I/"..node.chipid().."/D/neopixel_moodlight/F/json",'{"d":{ "id"="'..node.chipid()..'", "status":"connected"}',0,0, function(conn)
                    tmr.stop(5)
                end)
            end)
        end)
    end)
end

tmr.alarm(5,5000,1,connectionCheck)


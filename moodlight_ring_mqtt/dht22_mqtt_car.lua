WIFISSID={"GS1Lab", "MilkyWay_2"}
WIFIPASS={"11111222223333444455556666","11111222223333444455556666"}
MQTTIP={"10.0.1.64","192.168.1.100"}
MQTTPORT={1884,1884}

wifi.setmode(wifi.STATION)
--wifi.sta.config("GS1Lab","11111222223333444455556666")
wifi.sta.config(WIFISSID[1], WIFIPASS[1])
print(wifi.sta.getip())

m = mqtt.Client("esp8266_lua_dht22_car", 120, "guest", "guest")
--m:lwt("/lwt", "disconnected", 0, 0)

-- Variables
tempc=0
sf = 0
humi="XX"
temp="XX"
fare="XX"
bimb=1
PIN = 4 -- data pin DHT22, GPIO2
toggleWIFI=0


m:on("offline", function(con)
print ("Checking MQTT server")
connectionCheck()
print(node.heap())
end)

-- on publish message receive event
m:on("message", function(conn, topic, data)
print(topic .. ":" )
if data ~= nil then
print(data)
end
end)

function Pub_DHT22()
	if sf == 0 then
	sf = 1
	ReadDHT22()
	m:publish("/esp8266/car",'{"temperature":'..tempc..',"humidity":'..humc..'}',0,0, function(conn)
		sf = 0
		end)
	end
end


--load DHT22 module and read sensor
function ReadDHT22()
dht22 = require("dht22")
dht22.read(PIN)
t = dht22.getTemperature()
h = dht22.getHumidity()
humi=(h/10)
temp=(t/10)
tempc=temp
humc=humi
print("Humidity: "..humi.."%")
print("Temperature: "..tempc.." deg C")
-- release module
dht22 = nil
package.loaded["dht22"]=nil
end

function connectionCheck()
tmr.stop(5)
if wifi.sta.status() == 5 and wifi.sta.getip() ~= nil then
	m:connect(MQTTIP[toggleWIFI+1], MQTTPORT[toggleWIFI+1], 0, function(conn)
		print("connected")
		m:subscribe("/temp/random",0, function(conn)
			tmr.alarm(3, 30000, 1, Pub_DHT22)
		end)
	end)
else
	toggleWIFI = (toggleWIFI+1)%2
	print("toggleWIFI"..toggleWIFI.." ,WIFISSID[toggleWIFI+1]"..WIFISSID[toggleWIFI+1].." ,WIFIPASS[toggleWIFI+1]"..WIFIPASS[toggleWIFI+1])
	wifi.sta.config(WIFISSID[toggleWIFI+1], WIFIPASS[toggleWIFI+1])
	tmr.alarm(5,5000,1,connectionCheck)
	print("Retry!!")
end
end

tmr.alarm(5,5000,1,connectionCheck)

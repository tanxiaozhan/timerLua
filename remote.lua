-- 开启 Wifi 并获得 NodeMCU IP 地址
--connect to Access Point (DO save config to flash)
station_cfg={}
local home=false
if home then
    station_cfg.ssid="TRouter_4G"
    station_cfg.pwd="EinstTianchen#1974"
else
    station_cfg.ssid="UTT-HIPER_ce8be8"
    station_cfg.pwd="!jsjx2013"
end

station_cfg.save=true

ip=wifi.sta.getip()
print(ip)
if not ip then
    wifi.setmode(wifi.STATION)
    wifi.sta.config(station_cfg)
    print(wifi.sta.getip())
end

-- 开启一个 8888 的端口
-- 并通过 node.input() 调用 Lua 解释器控制 LED
--[[srv=net.createServer(net.TCP)
srv:listen(8888,function(conn)
    conn:on("receive",function(conn,payload)
    node.input("gpio.mode(0, gpio.OUTPUT)")
    node.input("gpio.write(0, gpio.LOW)")
    end)
end)

http.get("http://httpbin.org/ip", nil, function(code, data)
    if (code < 0) then
      print("HTTP request failed")
    else
      print(code, data)
    end
  end)
--]]

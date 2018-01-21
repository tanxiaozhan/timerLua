-- 开启 Wifi 并获得 NodeMCU IP 地址
--connect to Access Point (DO save config to flash)
station_cfg={}
local home=true
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
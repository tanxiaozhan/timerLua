--read alarm form file
local alarmON={0,8,0,0,1,0,9,0,0,1}
local alarmOFF={}
local af=file.open("Alarm.Dat","r")
if af then
    

end

dofile("remote.lua")
dofile("httpServer.lua")

---从文件alarm.dat读取定时时间
alarmON={}       --定时开启时间，格式：启用标志（1-启用，0-不启用），时，分，秒，重复间隔天数
alarmOFF={}      --定时关闭时间，格式：时，分，秒
local strAlarm,temp,i

--初始化定时时间
for i=1,5
do 
    alarmON[i]={}    --二维数组
    alarmON[i][1]=0
    alarmON[i][2]=0
    alarmON[i][3]=0
    alarmON[i][4]=0
    alarmON[i][5]=0

    alarmOFF[i]={}   --创建二维数组
    alarmOFF[i][1]=0
    alarmOFF[i][2]=0
    alarmOFF[i][3]=0
end

if file.open("alarm.dat","r") then
    i=0
    strAlarm=file.readline()
    while(strAlarm)
    do
       i=i+1
       --获得定时开时间，格式：ON 定时启用标志（1-启用，0-不启用） 时:分:秒 replea:间隔天数
       temp=string.match(strAlarm,"ON %d %d+:%d+:%d+")

       alarmON[i][1]=string.sub(temp,4,4)
       alarmON[i][2]=string.sub(temp,6,7)
       alarmON[i][3]=string.sub(temp,9,10)
       alarmON[i][4]=string.sub(temp,12,13)
       temp=string.match(strAlarm,"replea:%d+")
       alarmON[i][5]=string.match(temp,"%d+")

       --获得定时关闭时间，格式：OFF 时:分:秒
       temp=string.match(strAlarm,"OFF %d+:%d+:%d+")
       alarmOFF[i][1]=string.sub(temp,5,6)
       alarmOFF[i][2]=string.sub(temp,8,9)
       alarmOFF[i][3]=string.sub(temp,11,12)
       
    strAlarm=file.readline()
    end
    file.close()
end

--[[
for i=1,5
do 
    print("ON  " .. alarmON[i][1] .. " " .. alarmON[i][2] .. ":" .. alarmON[i][3] .. ":" .. alarmON[i][4] .. " " .. alarmON[i][5])
    print("OFF " .. alarmOFF[i][1] .. ":" .. alarmOFF[i][2] .. ":" .. alarmOFF[i][3])
    
end
--]]

dofile("remote.lua")
dofile("httpServer.lua")

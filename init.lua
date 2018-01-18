--从文件alarm.dat读取定时时间
local alarmON={}
local alarmOFF={}
local strAlarm,temp,n

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
    n=0
    strAlarm=file.readline()
    while(strAlarm)
    do
      print(strAlarm)
       n=n+1
       --获得定时开时间，格式：ON 定时启用标志（1-启用，0-不启用） 时:分:秒 replea:间隔天数
       temp=string.match(strAlarm,"ON %d %d+:%d+:%d+")
       alarmON[n][1]=string.sub(temp,4,5)
       alarmON[n][2]=string.sub(temp,6,8)
       alarmON[n][3]=string.sub(temp,9,11)
       alarmON[n][4]=string.sub(temp,12,14)
       temp=string.match(strAlarm,"replea:%d+")
       alarmON[n][5]=string.match(temp,"%d+")

       --获得定时关闭时间，格式：OFF 时:分:秒
       temp=string.match(strAlarm,"OFF %d+:%d+:%d+")
       alarmOFF[n][1]=string.sub(temp,5,7)
       alarmOFF[n][2]=string.sub(temp,8,10)
       alarmOFF[n][3]=string.sub(temp,11,13)
       
    strAlarm=file.readline()
    end
    file.close()
end

for i=1,5
do 
    print("ON  " .. alarmON[i][1] .. " " .. alarmON[i][2] .. ":" .. alarmON[i][3] .. ":" .. alarmON[i][4] .. " " .. alarmON[i][5])
    print("OFF " .. alarmOFF[i][1] .. ":" .. alarmOFF[i][2] .. ":" .. alarmOFF[i][3])
    
end
dofile("remote.lua")
--dofile("httpServer.lua")

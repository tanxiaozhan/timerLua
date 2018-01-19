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
--------------------------------------------------

i2c初始化设置，GPIO12、GPIO14连接到DS3231实时钟芯片

--------------------------------------------------
ESP-07 GPIO Mapping
IO index    ESP8266 pin
    0 [*]   GPIO16
    1       GPIO5
    2       GPIO4
    3       GPIO0
    4       GPIO2
    5       GPIO14
    6       GPIO12      
    7       GPIO13
    8       GPIO15
    9       GPIO3
    10      GPIO1
    11      GPIO9
    12      GPIO10

[*] D0(GPIO16) can only be used as gpio read/write. 
No support for open-drain/interrupt/pwm/i2c/ow.
--]]
ds3231=require("ds3231")
SDA, SCL = 6, 5
i2c.setup(0, SDA, SCL, i2c.SLOW) -- call i2c.setup() only once
local alarmId=1   --DS3231定时1
ds3231.setAlarm(1,ds3231.EVERYSECOND)
--ds3231.enableAlarm(alarmId)
second, minute, hour, day, date, month, year = ds3231.getTime()

-- Get current time
print(string.format("Time & Date: %s:%s:%s %s/%s/%s", hour, minute, second, date, month, year))


-- 使用后释放ds3231模块
ds3231 = nil
package.loaded["ds3231"]=nil

------------------------------------------------
--
--设置pin1(GPIO5)为外部中断输入端
--
------------------------------------------------
local pin = 1
gpio.mode(pin,gpio.INT)
local function getTimeDS3231(level)
    require("ds3231")
    second, minute, hour, day, date, month, year = ds3231.getTime()

    print(string.format("Time & Date: %s:%s:%s %s/%s/%s", hour, minute, second, date, month, year))

    ds3231.reloadAlarms()

    -- 使用后释放ds3231模块
    ds3231 = nil
    package.loaded["ds3231"]=nil
    
end
gpio.trig(pin, "down", getTimeDS3231)


--[[
for i=1,5
do 
    print("ON  " .. alarmON[i][1] .. " " .. alarmON[i][2] .. ":" .. alarmON[i][3] .. ":" .. alarmON[i][4] .. " " .. alarmON[i][5])
    print("OFF " .. alarmOFF[i][1] .. ":" .. alarmOFF[i][2] .. ":" .. alarmOFF[i][3])
    
end
--]]

dofile("remote.lua")
dofile("httpServer.lua")

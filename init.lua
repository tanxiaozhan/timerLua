---从文件alarm.dat读取定时时间
alarmON={}       --定时开启时间，格式：启用标志（1-启用，0-不启用），时，分，秒，重复间隔天数
alarmOFF={}      --定时关闭时间，格式：时，分，秒
interval={}      --间隔天数

--当前日期、时间，初始化为2018-1-1 0:0:0 星期日
second, minute, hour, day, date, month, year=0,0,0,1,1,1,18

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
    interval[i]=0

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

       alarmON[i][1]=tonumber(string.sub(temp,4,4))
       alarmON[i][2]=tonumber(string.sub(temp,6,7))
       alarmON[i][3]=tonumber(string.sub(temp,9,10))
       alarmON[i][4]=tonumber(string.sub(temp,12,13))
       temp=string.match(strAlarm,"interval:%d+")
       alarmON[i][5]=tonumber(string.match(temp,"%d+"))
       interval[i]=alarmON[i][5]
       
       --获得定时关闭时间，格式：OFF 时:分:秒
       temp=string.match(strAlarm,"OFF %d+:%d+:%d+")
       alarmOFF[i][1]=tonumber(string.sub(temp,5,6))
       alarmOFF[i][2]=tonumber(string.sub(temp,8,9))
       alarmOFF[i][3]=tonumber(string.sub(temp,11,12))
       
    strAlarm=file.readline()
    end
    file.close()
end

--设置pin2(GPIO4)为输出模式，驱动继电器
local drvPin=2
gpio.mode(drvPin, gpio.OUTPUT)

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
ds3231.setAlarm(alarmId,ds3231.EVERYSECOND)
--ds3231.enableAlarm(alarmId)
second, minute, hour, day, date, month, year = ds3231.getTime()

-- Get current time
print(string.format("Time & Date: %s:%s:%s %s/%s/%s", hour, minute, second, date, month, year+2000))


alarmId=nil
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
    local alarmId=1
    ds3231=require("ds3231")
    second, minute, hour, day, date, month, year = ds3231.getTime()

    --与5组定时时间比较
    local i
    for i=1,5 do
        --该组定时启用，则比较时间
        if alarmON[i][1]==1 then
            --根据定时时间打开继电器
            if (alarmON[i][2]==hour) and (alarmON[i][3]==minute) and (alarmON[i][4]==second) then
                --间隔天数为1，继电器通电闭合
                if interval[i]<=1 then
                    gpio.write(drvPin, gpio.HIGH)  --GPIO4输出高电平，继电器吸合
                    interval[i]=alarmON[i][5]   --重装间隔天数
                else
                    interval[i]=interval[i]-1   --间隔天数减1
                end
            end

            --根据定时时间关闭继电器
            if (alarmOFF[i][1]==hour) and (alarmOFF[i][2]==minute) and (alarmOFF[i][3]==second) then
                    gpio.write(drvPin,gpio.LOW)  --GPIO4输出低电平，继电器关闭
            end    
        end
    end
    
    --print(string.format("Date & Time: %s-%s-%s %s:%s:%s", year+2000,month,date,hour, minute, second))

    ds3231.reloadAlarms(alarmId)
    
    alarmId,i=nil,nil
    -- 使用后释放ds3231模块
    ds3231 = nil
    package.loaded["ds3231"]=nil
    
end

--设置下降沿中断及中断处理函数
gpio.trig(pin, "down", getTimeDS3231)

--wifi设置
dofile("wifi.lua")
--启用http服务
dofile("httpServer.lua")

srv = net.createServer(net.TCP)

--生成定时设置页面
function setAlarm()
    local tempHtml={}
    tempHtml[1]="<!DOCTYPE html><html>" ..
    "<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />" ..
    "<body>" ..
    "<center>定时时间设置<br><br>" ..
    "<form name='f1' method='post' action=''>"
    tempHtml[2]=
    "<table width='60%' border='0' align='center'>" ..
    "<tr><td width='30%' rowspan='2'>定时<input name='t1' type='text' size='2'>　" ..
    "<input type='checkbox' name='chb'>启用</td>" ..
    "<td width='79%'>ON: " ..
    "<input name='t2' type='text' size='2'>:" ..
    "<input name='t3' type='text' size='2'>:" ..
    "<input name='t4' type='text' size='2'>　每<input name='t5' type='text' size='2'>天</td></tr>"
    tempHtml[3]="<tr><td>OFF:<input name='t6' type='text' size='2'>:" ..
    "<input name='t7' type='text' size='2'>:" ..
    "<input name='t8' type='text' size='2'></td></tr>"
    tempHtml[4]="<tr><td colspan='2' align='center'>" ..
    "<input type='submit' name='bt' value='提交'></td></tr>" ..
    "</table></form>"
    return tempHtml
end

--生成主页页面
function indexHtml()
    local tempHtml={}
    tempHtml[1]="<!DOCTYPE html><html>" ..
        "<meta http-equiv='Content-Type' content='text/html; charset=utf-8' /><body>" ..
        "当前时间：<br>" ..
        "定时1：<br>" ..
        "定时2：<br>" ..
        "定时3：<br>" ..
        "定时4：<br>" ..
        "定时5：<br>" 
     tempHtml[2]="<a href='setAlarm.html'>定时设置</a><br>" ..
        "<form name='form1' method='post' action=''>" ..
        "<input type='hidden' name='hiddenField'>" ..
        "<input type='submit' name='button'value='校 时'>" ..
        "</form></body></html>"
    return tempHtml
end


function receiver(sck, data)

  -- if you're sending back HTML over HTTP you'll want something like this instead
  local response = {"HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\nContent-Type: text/html\r\n\r\n"}

  print(data)

  local  htmlFile=string.match(data,"GET /setAlarm.html")
  if htmlFile then
        response=setAlarm()
  else
        htmlFile=string.match(data,"POST /setAlarm.html")
        if htmlFile then
            print(string.match(data,"t1=%d&chb=%a+&t2=%d+&t3=%d+&t4=%d+"))
            response=indexHtml()
        else
            response=indexHtml()
        end

  end
--[[  
  local operate=string.match(data,"getData")
    if operate then
        for i=1,5
        do
           response[#response+1]="alarmON[" .. i .. "]: " .. alarmON[i][1] .. " " .. 
                                 alarmON[i][2] .. ":" .. alarmON[i][3] .. ":" .. alarmON[i][4] 
                                                      .. "  replea:" .. alarmON[i][5] .. " ---- " 
           response[#response+1]="alarmOFF[" .. i .."]:" .. alarmOFF[i][1] .. ":" .. alarmOFF[i][2] 
                                  .. ":" .. alarmOFF[i][3] .. "<br>"
        end
    else
        operate=string.match(data,"setData:%d,%d,%d%d:%d%d:%d%d,%d+")
        print("operate=")
        print(operate)
        if operate then
            local i
            i=tonumber( string.sub(operate,9,9) )
            alarmON[i][1]=string.sub(operate,11,11)
            alarmON[i][2]=string.sub(operate,13,14)
            alarmON[i][3]=string.sub(operate,16,17)
            alarmON[i][4]=string.sub(operate,19,20)
            alarmON[i][5]=string.sub(operate,22)
            
            response[#response+1]="setData success!"
        end       
    end
    
  print(strdate)
--]]
  -- sends and removes the first element from the 'response' table
  local function send(localSocket)
    if #response > 0 then
      local tempre=table.remove(response,1)
      print("#response=" .. #response .. " " .. tempre)
      localSocket:send(tempre) --table.remove(response, 1))
    else
      localSocket:close()
      response = nil
    end
  end

  -- triggers the send() function again once the first chunk of data was sent
  sck:on("sent", send)

  send(sck)
end

srv:listen(80, function(conn)
  conn:on("receive", receiver)
end)

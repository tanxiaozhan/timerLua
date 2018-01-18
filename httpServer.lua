srv = net.createServer(net.TCP)

function receiver(sck, data)
  --local response = {}

  -- if you're sending back HTML over HTTP you'll want something like this instead
  local response = {"HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\nContent-Type: text/html\r\n\r\n"}

  print(data)
  
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
  --response[#response + 1] = "e.g. content read from a file"

  -- sends and removes the first element from the 'response' table
  local function send(localSocket)
    if #response > 0 then
      localSocket:send(table.remove(response, 1))
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

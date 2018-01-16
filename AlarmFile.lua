local fc=file.open("alarm.Dat","w")
if fc then
    fc.writeline("ON 10:00:00,OFF 10:00:20,replea:1")
    fc.close()
end

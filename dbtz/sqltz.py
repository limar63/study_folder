import re

filecontent = ""
with open("/home/lehalinuksoid/Python_rofli/dbtz/input.txt",'r') as file:
    filecontent = file.read()
filecontent = filecontent.split('\n')
filecontent = filecontent[1:]
lenarray = []
for line in filecontent:
    numberless = re.match(r"(^[0-9]+	)(.*)", line)
    numberless = numberless.group(2)
    line = line.split(',')
    print(line[1])
#    lenarray.append(len(line))

#print(lenarray)
    #mail = re.match(r".*([0-9]{6}).*", numberless)
    #if mail is None:
    #    mail = "NULL"
    #else:
    #    mail = mail.group(1)
    #    numberless = numberless.replace(mail, "")
    #city = re.match(r"(,г\s.*?,|,.*г\..*?,|,.*\sг\s.*?,|,.*\sг,|^г\.?.*?,|,Г\s.*?,|,.*Г\..*?,|,.*\sГ\s.*?,|,.*\sГ,|^Г\.?.*?,)", numberless)
    #if city is None:
    #    city = "NULL"
    #else:
    #    print(city.group(1))

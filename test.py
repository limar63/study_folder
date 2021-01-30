import glob
import os
import time
import re
import getpass

user = getpass.getuser()

def exception_search(full_line):                                                                #Parsing function, that will filter original log file
    nonfiltered = full_line.split('\n')                                                         #Spliting file contents to have it as list separated by each line from file
    result = ["List of exceptions:"]                                                            #first line
    i = 0                                                                                       #index which will be used in for loop to iterate through string list
    previous_exc = []                                                                           #Will contain previous found exception to avoid printing the same one
    current_exc = []                                                                            #Will contain current exception to compare it 
    repeat = 0                                                                                  #repeating count that will be used to type how many times exception was repeated in a row
    for i in range(len(nonfiltered) - 1):                                                       #going through a range of array elements
        if "Exception:" in nonfiltered[i]:                                                      #Checking if we found an exception line
            #checking if element on top is not another exception, so, we would need to print it for context
            if (not "(Filename: <" in nonfiltered[i - 2]) and (not "(Filename: currently not" in nonfiltered[i - 2]):
                result.append(nonfiltered[i - 3])
                result.append(nonfiltered[i - 2])
                result.append(nonfiltered[i - 1])
                previous_exc = []                                                               #Zeroing previous exception remembered because after printing nonexception we need to reset it
            while (not "(Filename: <" in nonfiltered[i]) and (not "(Filename: currently not" in nonfiltered[i]):
                current_exc.append(nonfiltered[i])                                              #Filling current exception list with exception lines until we reach the last line of it
                i += 1                                                                          #incrementing index because we are using non-for incrementation to go through elements
            current_exc.append(nonfiltered[i])                                                  #adding the last line and separator for visibility
            current_exc.append("")
            if previous_exc != current_exc:                                                     #checking if exception was the same as the last one, if it is - we don't need to print it but increment the count
                result.extend(current_exc)                                                      #Not the same so we add the exception to the resulting list
                previous_exc = current_exc[:]                                                   #Putting it as the previous exception in case it will be the same later
                if repeat != 0:                                                                 #If count wasn't 0, so, we got exception repeated and we inform about it the reader
                    result.append("It was repeated " + str(repeat) + " times")
                    result.append("")
                    repeat = 0                                                                  #zeroing the counter after using it
                current_exc = []                                                                #zeroing the current exception for the next use
            else:                                                                               #exception is repeatig, so, we just summ up the count
                repeat += 1
                current_exc = []
    result = '\n'.join(result)                                                                  #Turning the list back into string with \n as separator
    return result

while True:
    print("hello")
    logpath = "C:\\Users\\" + user +"\\AppData\\LocalLow"                                           #Path where all logs are contained
    text_files = glob.glob(logpath + "/**/Playe*.log", recursive = True)                            #Making a list of Player.log/Player-prev.log named files

    for path in text_files:
        projname = re.match(r"(.+\\)(.+)(\\Player\-prev.log)", path)                                #Extracting the name of the project from the folder inside which log files are content
        if projname is None:
            projname = re.match(r"(.+\\)(.+)(\\Player.log)", path).group(2)
        else:
            projname = projname.group(2)
        #getting the last modified time of the log file
        lastmod = time.asctime(time.localtime(os.path.getmtime(path))).replace(":", "h ", 1).replace(":", "m ")
        filecontent = ""
        with open(path,'r', encoding="utf-8") as file:                                              #copying the contents of the original log file
            filecontent = file.read()
        newpath = 'C:\\Users\\' + user + '\\Desktop\\logs'
        if not os.path.isdir(newpath):                                                              #creating a directory for logs if it's not around
            os.mkdir(newpath)
        newpath = newpath + '\\'
        if not os.path.isdir(newpath + projname):                                                   #creating a directory for project if it's not around
            os.mkdir(newpath + projname)
        #getting a filepath for a log to check if it's already here
        filepath = os.path.join(newpath + projname, "full " + projname + " " + lastmod + ".log")
        if not os.path.isfile(filepath):                                                            #checking if log is not copied, if that's so, we are copying it by creating a new file
            with open(filepath,'x', encoding="utf-8") as file:
                temp = file.write(filecontent)
        filepath = filepath.replace("full ", "Exception ")
        filecontent = exception_search(filecontent)                                                 #parsing the contents of log file to get only neccesary exception lines
        if (not os.path.isfile(filepath)) and (len(filecontent) > 19):                              #checking if file is not created and there are exception which needed to be mentioned
            with open(filepath,'x', encoding="utf-8") as file:
                temp = file.write(filecontent)
    
    time.sleep(60)

#!/usr/bin/lua5.2

--database connection
mysql = require "luasql.mysql"

occurence = 478
numberMatched = 0


---function for number registration
function number_registration()
digitsRegister=session:playAndGetDigits(1, 1, 1, 6000, "#", "phrase:register_number", invalid, "\\d{1}")
print(digitsRegister)
if(digitsRegister == '1')
then

--[[
res = assert (conn:execute(string.format([[
    INSERT INTO contacts (number)
    VALUES ('%d')]]--, caller_id_number)
  --))
--]]
status,errorString = conn:execute(string.format([[INSERT INTO contacts (fromNumber) 
VALUES ('%d')]],caller_id_number))
print(status,errorString )

if(errorString == nil)
then
print("Registration successful\n")
session:playAndGetDigits(0, 1, 1, 1000, "#", "phrase:register_success", invalid, "\\d{1}")
else print("error in db\n")
end
elseif(digitsRegister == '2')
then
print("BYE BYE.\n")
digitsRegister=session:playAndGetDigits(0, 1, 1, 1000, "#", "phrase:register_failure", invalid, "\\d{1}")
--session:hangup()  ---- test
end
end

--function end

function number_check()
cur = assert(conn:execute"select fromNumber from contacts")
row = cur:fetch({}, "a")
while row do
  print(string.format("number: %s", row.fromNumber))
  -- reusing the table of results
if(row.fromNumber == caller_id_number)
then
print("Number is in database.\n")
print(string.format(" inside if else number: %s", row.fromNumber))
numberMatched = 1
else numberMatched = 0
print("number is not in database...")
end
  row = cur:fetch (row, "a")
end
return numberMatched
end
--function end

function enter_number()
mobileNumber=session:playAndGetDigits(1,10,1,15000, "#", "phrase:enter_mobile_number",invalid,"\\d{1}")
end

function welcome_lang()
local welcomePlay = 1
local langPlay = 1
local loopRestrict = 5
repeat
if(welcomePlay == 1)
then
print("playing main menu")
session:playAndGetDigits(0, 1, 1, 1000, "#", "phrase:welcome_ecosmob", invalid, "\\d{1}")
end

if(langPlay == 1)
then
print("playing language menu")
digitsLang=session:playAndGetDigits(1, 1, 1, 3000, "#", "phrase:select_language", invalid, "\\d{1}")
end

if(digitsLang == '9')
then 
print("w=1,l=1\n")
welcomePlay = 1
langPlay = 1
elseif(digitsLang == '0')
then
print("w=0,l=1\n")
welcomePlay = 0
langPlay = 1
end
loopRestrict = loopRestrict - 1
until(digitsLang == '1' or digitsLang == '2' or digitsLang == '3' or loopRestrict == 0)
--print("LANGUAGE ISSUE RESOLVED. BYE\n")
end



-----------------------------------MAIN STARTS FROM HERE-------------------------------------------------
session:answer()
session:setVariable("tts_engine","flite")
session:setVariable("tts_voice","kal")
session:setVariable("set_audio_level","write 4")

dest_number = session:getVariable("destination_number")
caller_id_number = session:getVariable("caller_id_number")
uuid=session:getVariable("uuid")

--print(dest_number)
--print(caller_id_number)

 env  = mysql.mysql()
 conn = env:connect('test','root','sahil123')
print(env,conn)
--[[local endLoop = 3
repeat 
number_check()
if(numberMatched == 0)
then
number_registration()
if(digitsRegister == '1')
then
number_check()
end
end
--endLoop =endLoop -1
until(numberMatched == 1 or digitsRegister == '2' or endLoop == 0)
welcome_lang()--]]
number_check()

if(numberMatched == 1)
then
welcome_lang()
elseif(numberMatched == 0)
then
number_registration()
number_check()
if(numberMatched == 1)
then
welcome_lang()
end
end


--lang_select()
repeat
enter_number()
until(string.len(mobileNumber) == 10)
print("mobile number updated.\n")
status,errorString = conn:execute(string.format([[INSERT INTO contacts (number, calluuid, empid, fromNumber, toNumber, remoteip) 
VALUES ('%s','%s','%d','%d','%d','10.0.2.15')]],mobileNumber,uuid,caller_id_number,caller_id_number,dest_number))
print(status,errorString)

digitsOffers=session:playAndGetDigits(1, 1, 3, 3000, "#", "phrase:latest_offers", invalid, "\\d{1}")

if(digitsOffers == '1')
then 
print("bridging call to 9812678...")
session1 = freeswitch.Session("sofia/internal/1005%10.0.2.15");
session2 = freeswitch.Session("sofia/internal/9812678%10.0.2.15");
freeswitch.bridge(session1, session2);
elseif(digitsOffers == '2')
then
print("sending call to voicemmail.")
session1 = freeswitch.Session("sofia/internal/1005%10.0.2.15");
session2 = freeswitch.Session("sofia/internal/6778%10.0.2.15");
freeswitch.bridge(session1, session2);
elseif(digitsOffers == '3')
then
print("starting the conference call.")
end

session:hangup()

-------------------------------------------MAIN ENDS HERE-----------------------------------------------

--[[session:answer()
session:setVariable("tts_engine","flite")
session:setVariable("tts_voice","kal")
session:setVariable("set_audio_level","write 4")
freeswitch.consoleLog("INFO", "THIS IS LUA IVR TEST")
digits = session:playAndGetDigits(1, 5, 3, 3000, "#", "phrase:register_number", invalid, "\\d{1}")
--min digits to capture - max digits - no of retries - delay between retries - terminator if digits are less than max. - sound file (phrase macro name) - invalid sound file - regex (optional)
freeswitch.consoleLog("INFO", "digits entered"..digits.." end\n")
session:hangup()--]]


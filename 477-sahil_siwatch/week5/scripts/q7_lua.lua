#!/usr/bin/lua5.2
mysql = require "luasql.mysql"

occurence = 0;

local env  = mysql.mysql()
local conn = env:connect('test','root','sahil123')

print(env,conn)

dest_number = session:getVariable("destination_number")
caller_id_number = session:getVariable("caller_id_number")
uuid=session:getVariable("uuid")

status,errorString = conn:execute(string.format([[INSERT INTO contactsTest (uuid, dest_no, caller_id) 
VALUES ('%s', '%d', '%d')]],uuid, dest_number, caller_id_number))
print(status,errorString )

cur = assert(conn:execute"select * from contactsTest")
row = cur:fetch({}, "a")
while row do
  print(string.format("uuid: %s, destination_number: %d, caller_id: %d", row.uuid, row.dest_no, row.caller_id))
  -- reusing the table of results

  row = cur:fetch (row, "a")
end


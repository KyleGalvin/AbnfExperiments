--[[
local socket = require "socket"
local http = require "socket.http"

local host = "http://192.168.1.168"
--print('socket ',tostring(socket))

local file = "/repl"
local url = host..":8085"..file

--url = "http://www.cs.princeton.edu/~diego/professional/luasocket/http.html"
--url = "http://httpbin.org/post"
local request_body="{var='kyletest'}"
local resp = {}
print('making request')
local myresp,myresp2,myresp3,myrespd4 = http.request{
	url=url,
	method="POST",
        headers =
        {
        --      ["Content-Type"] = "application/json",
                ["Content-Length"] = #request_body,
	--	["set-cookie"] = "var=thisismycookiedata"
        },
        source = ltn12.source.string(request_body),

	sink = ltn12.sink.table(resp)
}
print('done request')


print('response group: ',tostring(myresp),myresp2,myresp3,myresp4)
print('resp sink: '..table.concat(resp))
--]]

require "io"

local f = io.open("./testfile.txt","r")
local t = f:read("*all")

print("my test file is: ", t)
io.stderr:write("this is my error\n")

f:close()--not sure we need close when we are at the EOF...
--without the above close(),io.input() below still reads from stdin
--this makes me think that file handles automatically close themselves at EOF

local temp ,err = io.input()
print("got current input",temp,err)
t = temp:read(10)--reads from stdin
print("my closed temp handler data: ", t)


local f = io.open("./testfile.txt","r")
local t = f:read("*all")--reads from last io.open() file
print("my open temp handler data: ", t)





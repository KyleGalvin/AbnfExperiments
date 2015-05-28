local socket = require "socket"

port = 80
address = "127.0.0.1"
maxConnections = 20



function startHeaderBuilder(respCode)
	local respCodes = {
		[200]="200 OK",
	}
	return "HTTP/1.x "..respCodes[respCode].."\r\n"
end

function closeHeaderBuilder(partialHeader)
	return partialHeader .. "\r\n"
end

local exampleHeader = closeHeaderBuilder(startHeaderBuilder(200))
--[[
Transfer-Encoding: chunked
Date: Sat, 28 Nov 2009 04:36:25 GMT
Server: LiteSpeed
Connection: close
X-Powered-By: W3 Total Cache/0.8
Pragma: public
Expires: Sat, 28 Nov 2009 05:36:25 GMT
Etag: "pub1259380237;gz"
Cache-Control: max-age=3600, public
Content-Type: text/html; charset=UTF-8
Last-Modified: Sat, 28 Nov 2009 03:50:37 GMT
X-Pingback: http://net.tutsplus.com/xmlrpc.php
Content-Encoding: gzip
Vary: Accept-Encoding, Cookie, User-Agent
--]]

print('starting app')
function bindServer ()

	local server = socket.tcp()

	if not server:bind(address,port)  then
		print("could not bind to " .. address .. ":" .. port)
	else
		if not server:listen(maxConnections) then
			print("server cannot listen")
		else

			while true do
				local client = server:accept()
				if client then
					local line, err = client:receive()

					if not err then
						client:send(exampleHeader)
						client:close()
					end
				else
					print("server timed out")
				end
			end
		end
	end
	server:close()
end

bindServer()




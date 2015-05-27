require("luacurl")

print("success")
local exampleHeader = [[
HTTP/1.x 200 OK
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
]]

function test1()
	local c = curl.new()
	c:setopt(curl.OPT_WRITEFUNCTION,
		function(userparam, buffer)
			print("writing:" .. userparam .. " " ..buffer)
		end)
	c:setopt(curl.OPT_URL,"127.0.0.1")
	c:setopt(curl.OPT_HTTPHEADER,exampleHeader)
	c:setopt(curl.OPT_HTTPGET,true)	
	c:perform()
	c:close()
end

test1()

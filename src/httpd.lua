--copas API Reference:
--http://keplerproject.github.io/copas/reference.html

local socket = require "socket"
local copas = require "copas"
local utils = require "./src/utils"

function fsize (file)
	local current = file:seek()      -- get current position
	local size = file:seek("end")    -- get file size
	file:seek("set", current)        -- restore position
	return size
end

function startHeaderBuilder(respCode)
	local respCodes = {
		[200]="200 OK",
	}
	return "HTTP/1.x "..respCodes[respCode].."\r\n"
end

function closeHeaderBuilder(partialHeader)
	return partialHeader .. "\r\n"
end

function handle(socket)
	local exampleHeader = closeHeaderBuilder(startHeaderBuilder(200))
	print("handling incoming connection")
	requestData = copas.receive(socket)
	local requestPath = requestData:gsub("GET ", "")
	requestPath = requestPath:gsub("HTTP/1.1","")
	requestPath = requestPath:gsub("%s+","")
	if requestPath == "/" then
		requestPath = "./index.html"
	end
	print("requestData: " .. requestPath)
	local file,err = utils.readFile(requestPath)
	if not err then
		exampleHeader = exampleHeader .. file
		responseData = "this is my response packet"
		copas.send(socket,exampleHeader)
	else
		print(err)
	end
end

function bindServer ()
	local port = 8080
	local address = "www.retrokraken.com"
	local server = socket.bind(address,port)
	copas.addserver(server,handle)

	--copas.handler(handle)
	print("serer bound to "..address..":"..port)
	while true do
	copas.step()
	print("copas server running async, continuing with application")
	end
end

bindServer()

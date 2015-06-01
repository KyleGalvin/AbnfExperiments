--copas API Reference:
--http://keplerproject.github.io/copas/reference.html

local socket = require "socket"
local copas = require "copas"

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
	print("handling incoming connection")
	--local maxConnections = 20
	--if not server:listen(maxConnections) then
	--	print("server cannot listen")
	--else
		--while true do
		--	print("waiting for incoming client...")
		--	local client = server:accept()
		--end
	--end
	requestData = copas.receive(socket)
	print("requestData: " .. requestData)
	responseData = "this is my response packet"
	copas.send(socket,responseData)
end

function bindServer ()
	local exampleHeader = closeHeaderBuilder(startHeaderBuilder(200))
	local port = 80
	local address = "127.0.0.1"

	--local server = socket.tcp()
	local server = socket.bind(address,port)
	--server:settimeout(0)
	copas.addserver(server,handle)
	--[[copas.addthread(function()
		while true do
			--print("receiving...")
			local resp = copas.receive(skt,6)
			--print("received:",resp or "nil")
			
		end
	end)--]]

	copas.handler(handle)
	print("serer bound to "..address..":"..port)
	while true do
	copas.step()
	print("copas server running async, continuing with application")
	end
		--		if client then
		--			local line, err = client:receive()

		--			if not err then
		--				client:send(exampleHeader)
		--				client:close()
		--			end
		--		else
		--			print("server timed out")
		--		end
		--	end
		--end
	--server:close()
end

bindServer()

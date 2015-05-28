require("luacurl")

print("success")

function test1()
	local c = curl.new()
	c:setopt(curl.OPT_WRITEFUNCTION,
		function(userparam, buffer)
			print("writing:" .. " " ..buffer)
		end)
	c:setopt(curl.OPT_URL,"127.0.0.1")
	--c:setopt(curl.OPT_HTTPHEADER,exampleHeader)
	c:setopt(curl.OPT_HTTPGET,true)	
	c:perform()
	c:close()
end

test1()

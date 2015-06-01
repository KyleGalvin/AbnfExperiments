
require "luacurl"
--require "httpd"
return {
	--httpd_start_server=bindServer(),
	httpd_send_GET=function() 
		local c = curl.new()
		c:setopt(curl.OPT_WRITEFUNCTION,
			function(userparam, buffer)
				print("writing: " ..buffer)
			end)
		c:setopt(curl.OPT_URL,"127.0.0.1")
		--c:setopt(curl.OPT_HTTPHEADER,exampleHeader)
		c:setopt(curl.OPT_HTTPGET,true)	
		--c:setopt(curl.OPT_READFUNCTION,
		--	function(userparam, buffer)
		--		print("got response: " ..buffer)
		--	end)
		c:perform()
		c:close()
		print("curl call sent...")
		return true;
	end
}

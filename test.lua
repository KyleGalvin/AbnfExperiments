require "ansicolors"

print("success")
local httpd_runner = require "httpd_tests"

function testResults(k,v)
	if k and v then
		local status = ""
		local result = v()
		if result then
			status = status .. ansicolors.green .. "Success\t" .. ansicolors.reset
		else
			status = status .. ansicolors.red .. "FAIL\t" .. ansicolors.reset
		end
		local status = status .. ": " .. k 
		print(status)
	end
end

for k,v in pairs(httpd_runner) do testResults(k,v) end

local httpd_peg_runner = require "httpd_peg_tests"
for k,v in pairs(httpd_peg_runner) do testResults(k,v) end

require "ansicolors"

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

function runTestModule(module)
	for k,v in pairs(module) do testResults(k,v) end
end

print("Running all test suites...")

local abnf_runner = require "abnf"
runTestModule(abnf_runner)

local httpd_runner = require "httpd_tests"
runTestModule(httpd_runner)

local httpd_peg_runner = require "httpd_peg_tests"
runTestModule(httpd_peg_runner)

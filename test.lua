require "ansicolors"
local utils = require("utils")

function testResults(id, name, testFunc)
	if name and testFunc then
		local status = ""
		local result = testFunc()
		if result then
			status = status .. ansicolors.green .. "Success\t" .. ansicolors.reset
		else
			status = status .. ansicolors.red .. "FAIL\t" .. ansicolors.reset
		end
		local status = status .. ": " .. name 
		print(status)
	end
end

function runTestModule(moduleName)
	runTestModule(moduleName, runner)
end

function runTestModule(name)
	local module = require(name)
	if  module ~= nil then
		print( ansicolors.white .."Running Test Module: " .. ansicolors.yellow .. name .. ansicolors.reset)
		for i,v in ipairs(module) do 
			if type(v.name) == "string" and type(v.test == "function") then
				testResults(i, v.name,v.test) 
			else
				print("Bad test in module")	
			end
		end
		print()
	else
		print("Module not found:", name)
	end
end

print(ansicolors.blue .. "Running all test suites..." .. ansicolors.reset)
runTestModule("abnf_test")
runTestModule("httpd_tests")
runTestModule("httpd_peg_tests")
print(ansicolors.blue .. "...Done" .. ansicolors.reset)

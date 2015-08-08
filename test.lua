require "src/ansicolors"
local cjson = require("cjson")
local utils = require("src/utils")

local testJSON = {}

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
		if result then 
			return 1
		else
			return 0
		end
	end
end

function runTestModule(moduleName)
	runTestModule(moduleName, runner)
end

function runTestModule(name)
	testJSON[name] = {}
	local module = require("tests/"..name)
	if  module ~= nil then
		print( ansicolors.white .."Running Test Module: " .. ansicolors.yellow .. name .. ansicolors.reset)
		for i,v in ipairs(module) do 
			if type(v.name) == "string" and type(v.test == "function") then
				testJSON[name][i] = {}
				testJSON[name][i][v.name] = testResults(i, v.name,v.test)
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
runTestModule("utils")
runTestModule("abnf")
runTestModule("httpd")
print(ansicolors.blue .. "...Done" .. ansicolors.reset)
print(cjson.encode(testJSON))

utils.writeFile("../webapps/public/unitTests.json",cjson.encode(testJSON))

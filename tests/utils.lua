local utils = require "src/utils"

--nodes defined as tables in the input.
local testTable = { -- the root is not counted as a node
	["/1"]= { -- each key with a table value is a node
		["/1/1"] = 1, -- this key has a number value, so is a leaf not node
		["/1/2"] = "leaf two",
		["/1/3"] = {}, -- empty table is node, is not leaf
	},
	["/2"]= {
		["/2/1"] = 3,
		["/2/2"] = "",
		["/2/3"] = {}, -- empty table is node, is not leaf
	},
	["/3"]= {
		["/3/1"] = 5,
		["/3/2"] = "total leaf count six, total node count ?",
		["/3/3"] = {}, -- empty table is node, is not leaf
		["/3/4"] = {}, -- empty table is node, is not leaf
		["/3/5"] = {}, -- empty table is node, is not leaf
	},
}

return {
	{name = "utils.readFile.01 - Read File", test = function()
		local f = utils.readFile("./tests/utils/fsCheck.txt")
		if f then
			return true
		end
	end},
	{name = "utils.writeFile.01 - Write File", test = function()
		local file = "./tests/utils/fsCheck.txt"
		local contents1 = "this is my file contents"
		local contents2 = "this is my new file contents"
		utils.writeFile(file,contents1)
		local newContents = utils.readFile(file)
		utils.writeFile(file,contents2)
		local newContents2 = utils.readFile(file)

		--reset test
		utils.writeFile(file,contents1)

		if newContents ~= newContents2 then
			return true
		end
	end},
	{name = "utils.treeWalk.01 - Count Table Leaves", test = function()

		local leafCount = 0

		local leafCountFunc = function(tableNodeKey,tableNodeValue,treeNodeDepth)
			if type(tableNodeValue) ~= "table" then
				--leafCount in parent context is exposed in the scope of 
				--the function definition, and remains in scope during
				--the treeWalk call
				leafCount = leafCount + 1 
			end
		end

		utils.treeWalk(testTable,leafCountFunc)

		if leafCount == 6 then
			return true
		end

			
	end},
	{name = "utils.treeWalk.02 - Count Table Nodes", test = function()

		local nodeCount = 0

		local nodeCountFunc = function(tableNodeKey,tableNodeValue,treeNodeDepth)
			if type(tableNodeValue) == "table" then
				--nodeCount in parent context is exposed in the scope of 
				--the function definition, and remains in scope during
				--the treeWalk call
				nodeCount = nodeCount + 1 
			end
		end

		utils.treeWalk(testTable,nodeCountFunc)
		
		if nodeCount == 8 then
			return true
		end
	end},
	{name = "utils.treeWalk.03 - Filter Table Nodes", test = function()
		
	end},
	{name = "utils.tableSerialize.01 - Serialize table to file", test = function()
		
	end},
	{name = "utils.tableDeserialize.01 - Deserialize file to table", test = function()
		
	end},
	{name = "utils.async.01 - Fork/Copas execution to background", test = function()
		
	end},
	{name = "utils.pluto.01 - pluto persist complex lua structures", test = function()
		local pluto = require("pluto")
		local res = pluto.persist({},testTable)
		--print("results: ",res)
		--utils.writeFile("./plutoResults.txt",res)
		
	end},
} 

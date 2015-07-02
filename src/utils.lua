require "io"

local API= {}

API.readFile = function(filename)
	local f = io.open(filename,"r")
	if f then
		return f:read("*all")
	else
		return nil
	end
end

API.writeFile = function(filename,contents)
	local f = io.open(filename,"w")
	if f then
		f:write(contents)
		f:close()
	else
		print("failed to write contents to file: " .. filename)
	end
end

API.printTable = function(tbl, indent)
	local prettyPrint = function(k,v,depth)
		local space = string.rep(" ",depth)
		if type(v) == "table" then
			print(space .. k .. ":" .. "[Table]")
		else
			print(space .. k .. ":" .. v)
		end
	end
	API.treeWalk(tbl,prettyPrint)
end

--apply func to each node and leaf on tbl, recursing into subtables all the way down to maxDepth levels
--if maxDepth is undefined, we continue to the bottom of the tree
API.treeWalk = function(tbl,func,maxDepth,currentDepth)
	if not currentDepth then 
		currentDepth = 0 
	end

	if maxDepth == nil or maxDepth >= currentDepth then
		local subTables = {}
		local nodes = {}
		for k, v in pairs(tbl) do
			if type(v) =="table" then
				func(k,v,currentDepth)	
				API.treeWalk(v, func, maxDepth, currentDepth + 1)
			else
				func(k,v,currentDepth)
			end
		end
	end
end

API.map = function (func, array)
	local new_array = {}
		for i,v in ipairs(array) do
		new_array[i] = func(v)
	end
	return new_array
end

return API

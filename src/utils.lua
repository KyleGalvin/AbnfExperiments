require "io"

print = function(input) 
	if input then
		io.write(input .. "\n") 
	end
end

local API= {}

API.readFile = function(filename)
	local f = io.open(filename,"r")
	if f then
		return f:read("*all")
	else
		
		return nil,"File not found!"
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

API.printTable2 = function(tbl,maxDepth)
	local preFunc = function(k,v,d)
		if type(v) == "table" then
			print(string.rep(" ",d).. k .. ":" .. "{")
		end
	end

	local leafFunc = function(k,v,d)
		print(string.rep(" ",d) .. k .. ":" .. v)
	end

	local postFunc = function(k,v,d)
		if type(v) == "table" then
			print(string.rep(" ",d) .. "}")
		end
	end
	utils.treeWalk2(tbl,preFunc,leafFunc,postFunc,maxDepth)
end

API.printTable = function(tbl,maxDepth)
	local prettyPrint = function(k,v,depth)
		local space = string.rep(" ",depth)
		if type(v) == "table" then
			print(space .. k .. ":" .. "[Table]")
		elseif type(v) == "userdata" then
			print(space .. k .. ":" .. "[Userdata]")
		elseif type(v) == "boolean" then
			if v then
				print(space .. k .. ":" .. "True")
			else
				print(space .. k .. ":" .. "False")
			end
		else
			print(space .. k .. ":" .. v)
		end
	end
	API.treeWalk(tbl,prettyPrint,maxDepth)
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

--apply funcs to each node and leaf on tbl, recursing into subtables all the way down to maxDepth levels
--one func before recursion, one func after recursion. This allows us some before/after behaviour
--such as printing brace pairs "{}" around other output
--if maxDepth is undefined, we continue to the bottom of the tree
API.treeWalk2 = function(tbl,preFunc,leafFunc,postFunc,maxDepth,currentDepth)
	if not currentDepth then 
		currentDepth = 0 
	end

	if maxDepth == nil or maxDepth >= currentDepth then
		local subTables = {}
		local nodes = {}
		for k, v in pairs(tbl) do
			if type(v) =="table" then
				preFunc(k,v,currentDepth)	
				API.treeWalk2(v, preFunc,leafFunc,postFunc, maxDepth, currentDepth + 1)
				postFunc(k,v,currentDepth)
			else
				preFunc(k,v,currentDepth)	
				leafFunc(k,v,currentDepth)
				postFunc(k,v,currentDepth)
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

API.async = function (func)

	-- can we fork thread?

	-- if not, can we use copas?

	-- call func	

end

return API

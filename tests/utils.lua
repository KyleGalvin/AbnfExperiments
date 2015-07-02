local utils = require "src/utils"

return {
	{name = "utils.IO.01 - Read", test = function()
		local f = utils.readFile("./tests/utils/fsCheck.txt")
		if f then
			return true
		end
	end},
	{name = "utils.IO.02 - Write", test = function()
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
} 

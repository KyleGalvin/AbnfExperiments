
require "io"
require "lpeg"
local abnfTools = require "abnf"
local utils = require "utils"
return {
	{name = "abnf.normalize.01", test = function() 
		-- our normalization is a shim to allow for some minor deviations between the documented formal grammar and the input defined in the RFC definition of abnf
		-- these rules may have unintended consequences due to the lack of context, but the input won't parse without a normalization step. 
		-- The alternative is to do this input pruningby hand.
		local denormalizedString = "This is a string\n with different types \r\n of newlines \n yet it does not end \r\n with a new line"
		local expectedNormalizedString =  "This is a string\r\n with different types \r\n of newlines \r\n yet it does not end \r\n with a new line\r\n"
		local normalizedString = abnfTools.normalize(denormalizedString)

		if  normalizedString == expectedNormalizedString then
			return true
		end
	end},
	{name = 'abnf.build.01',test = function() 
		-- does the parser accept a minimal sample of the grammar? 
		-- this input is terse and very strictly formed.
		local parser = abnfTools.grammar()
		local ABNFDefinitionOfABNF  = 'rulelist = rule1 / rule2\r\n'
		local result = lpeg.match(parser,ABNFDefinitionOfABNF)

		if(type(result) == "table") then
			return true
		end 

	end},
	{name = 'abnf.build.02', test = function()
		-- extend the input string to test more elaborate parsing.
		-- the newlines and spacing had to be edited from our preferred source
		local parser = abnfTools.grammar()
		local ABNFDefinitionOfABNF  = 'rulelist  =  1*( rule / (*c-wsp c-nl) )\r\nrule  =  rulename defined-as elements c-nl\r\n; continues if next line starts\r\nrulename =  ALPHA *(ALPHA / DIGIT / "-")\r\n'
		local result = lpeg.match(parser,ABNFDefinitionOfABNF)

		if(type(result) == "table") then
			return true
		end 
	end},
	{name = 'abnf.build.03', test = function()
		--lets test the normalizer to see it fixes bad newlines in a way that matches our grammar 
		local parser = abnfTools.grammar()
		local ABNFDefinitionOfABNF  = 'rulelist  =  1*( rule / (*c-wsp c-nl) )\nrule  =  rulename defined-as elements c-nl\n ;continues if next line starts\r\n ; with white spacer\r\n rulename =  ALPHA *(ALPHA / DIGIT / "-") '
		local result = lpeg.match(parser,abnfTools.normalize(ABNFDefinitionOfABNF))

		if(type(result) == "table") then
			return true
		end 
	end},
	{name = 'abnf.build.04',test = function()
		--load an even longer string, this time from an external file. 
		local f = io.open("./abnf.abnf.half.lua","r")
		local t = f:read("*all")--reads from last io.open() file
		local parser = abnfTools.grammar()

		local normalized = abnfTools.normalize(t)
		print(normalized)
		local result = lpeg.match(parser,abnfTools.normalize(t))

		if(type(result) == "table") then
			return true
		end 

	end},
	{name = 'abnf.build.05',test = function()
		-- load our entire input grammar 
		local f = io.open("./abnf.abnf.lua","r")
		local t = f:read("*all")--reads from last io.open() file
		local parser = abnfTools.grammar()
		local result = lpeg.match(parser,abnfTools.normalize(t))

		if(type(result) == "table") then
		--	utils.printTable(result)
			return true
		end 

	end},
	-- use new abnf builder to build a clone of itself again
	{name = 'abnf.rebuild.01',test = function()
		
	end},

	-- check that the two abnf builders are identical
	{name = 'abnf.compare.01',test = function()


	end},
}

print("one")
require "io"
print("two")
local abnfTools = require "src/abnf"
print("three")
local utils = require "src/utils"
print("four")
local patternStats = function (result,debug)
	local ruleCount = 0
	local countRules = function(k,v,depth)
		if k == "rule" then
			if type(v) == "table" and v[1] and v[1]["rulename"] then
				if debug then
					print("\t\tRule: " .. v[1]["rulename"])
				end
				ruleCount = ruleCount + 1
			end
		end
	end

	utils.treeWalk(result,countRules)
	if debug then
		--utils.printTable(result)
		print("\t\tTotal Rules: ".. ruleCount )
	end
	return ruleCount
end

local testGrammar = function(filename,expectedRuleCount,debugPrint)
	local inputText = utils.readFile(filename)

	--Minor formatting: trim whitespace, windows-style newlines
	inputText = abnfTools.normalize(inputText)
	--load our LPEG parser which matches patterns written in ABNF
	local parser = abnfTools.grammar()

	--if the input text matches the parser grammar, 
	--typecast the inputText into a data structure
	local result = lpeg.match(parser,inputText)

	if(type(result) == "table") then
		productionRuleCount = patternStats(result,debugPrint)
		if productionRuleCount == expectedRuleCount then
			return true
		end
	end 
end

return {
	{name = "abnf.normalize.01", test = function() 
		--our normalization is a shim to allow for some minor deviations between the documented formal grammar and the input defined in the RFC definition of abnf
		--these rules may have unintended consequences due to the lack of context, but the input won't parse without a normalization step. 
		--The alternative is to do this input pruningby hand.
		local denormalizedString = "This is a string\n with different types \r\n of newlines \n yet it does not end \r\n with a new line"-- the first /n isnt escaped properly
		local expectedNormalizedString =  "This is a string\r\n with different types \r\n of newlines \r\n yet it does not end \r\n with a new line\r\n"
		local normalizedString = abnfTools.normalize(denormalizedString)
	--	print(normalizedString)
	--	print(expectedNormalizedString)
		if  normalizedString == expectedNormalizedString then
			return true
		end
	end},
	{name = 'abnf.parse.01',test = function() 
		--does the parser accept a minimal sample of the grammar? 
		--this input is terse and very strictly formed.
		local parser = abnfTools.grammar()
		local ABNFDefinitionOfABNF  = 'rulelist = rule1 / rule2\r\n'
		local result = lpeg.match(parser,ABNFDefinitionOfABNF)

		if(type(result) == "table") then
			return true
		end 

	end},
	{name = 'abnf.parse.02', test = function(debug)
		--extend the input string to test more elaborate parsing.
		--the newlines and spacing had to be edited from our preferred source
		return testGrammar("./tests/abnf/02.abnf",3,debug)
	end},
	{name = 'abnf.parse.03', test = function(debug)
		--lets test the normalizer to see 
		--if it fixes bad newlines in a way that matches our grammar 
		return testGrammar("./tests/abnf/03.abnf",3,debug)
	end},
	{name = 'abnf.parse.04',test = function(debug)
		--load an even longer string, this time from an external file. 
		return testGrammar("./tests/abnf/04.abnf",5,debug)
	end},
	{name = 'abnf.parse.05',test = function(debug)
		--load an even longer string, this time from an external file. 
		return testGrammar("./tests/abnf/05.abnf",21,debug)
	end},
	{name = 'abnf.parse.06',test = function(debug)
		--the contents of this file were directly cut and pasted 
		--from https://tools.ietf.org/html/rfc5234#appendix-B.1
		--which uses ABNF notation to define the semantics of ABNF notation
		return testGrammar("./src/abnf/abnf.abnf",21,debug)
	end},
	{name = 'abnf.transformToPEG.01',test = function(debug)
		local inputText = utils.readFile("./src/abnf/abnf.abnf")

		--Minor formatting: trim whitespace, windows-style newlines
		inputText = abnfTools.normalize(inputText)
		--load our LPEG parser which matches patterns written in ABNF
		local parser = abnfTools.grammar()

		--if the input text matches the parser grammar, 
		--typecast the inputText into a data structure
		local syntaxTree = lpeg.match(parser,inputText)
		local pegGrammar = abnfTools.compile(syntaxTree)
		
	end},
	-- use new abnf builder to build a clone of itself again
	{name = 'abnf.rebuild.01',test = function()
		
	end},

	-- check that the two abnf builders are identical
	{name = 'abnf.compare.01',test = function()

	end},
}

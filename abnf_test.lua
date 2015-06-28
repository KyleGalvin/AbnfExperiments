
require "io"
require "lpeg"
local abnfGrammar = require "abnf"

function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))      
    else
      print(formatting .. v)
    end
  end
end

return {
	--build abnf builder from RFC definition of abnf grammar
	['abnf.001.build.01']=function() 
		local parser = abnfGrammar()
		local ABNFDefinitionOfABNF  = 'rulelist  =  1*( rule / (*c-wsp c-nl) )\r\nrule  =  rulename defined-as elements c-nl\r\n; continues if next line starts\r\nrulename =  ALPHA *(ALPHA / DIGIT / "-")\r\n'
		local result = lpeg.match(parser,ABNFDefinitionOfABNF)

		if(type(result) == "table") then
			return true
		else
			print(result)
		end 
	end,
	['abnf.001.build.02']=function() 
		local parser = abnfGrammar()
		local ABNFDefinitionOfABNF  = 'rulelist = rule1 / rule2\r\n'
		local result = lpeg.match(parser,ABNFDefinitionOfABNF)

		if(type(result) == "table") then
			return true
		else
			return false
		end 

	end,
	-- use new abnf builder to build a clone of itself again
	['abnf.002.rebuilt']=function()
		
	end,

	-- check that the two abnf builders are identical
	['abnf.003.compare']=function()


	end,
}

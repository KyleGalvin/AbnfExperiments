utils = require "src/utils"

local windowsNewline = function(input)
	return input:gsub("([^\r])(\n)(%s*)","%1\r\n") -- all newlines are windows-style
end

local endWithNewline = function(input)
	if input[-1] ~= "\n" then -- always end with blank line
		return input .. "\r\n"
	end
end

local trimPreceedingWhitespace = function (input)
	return input:gsub("^%s*","")
end

local removeMultipleNewline = function (input)
	return input:gsub("[\r\n]+","\r\n")
end

local removeMultipleSpaces = function(input)
	return input:gsub("[ ]+"," ")
end

local removeComments = function(input)
	return input:gsub("\n;[^\n]*","\n\r\n")
end

local fixMultilineRules = function(input)
	return input:gsub("(\r\n)([^=]*)(\r\n)"," %2\r\n")
end

return {
	["grammar"] = function()
		local lpeg = require "lpeg"
		local V = lpeg.V
		local P = lpeg.P
		local R = lpeg.R
		local C = lpeg.C
		local Cg = lpeg.Cg
		local Ct = lpeg.Ct
		local Cc = lpeg.Cc
		local Cs = lpeg.Cs


		local transformations = {
			["rulelist"] 		= function(input) return {["rulelist"] = input} end, 
			["rule"] 		= function(input) return {["rule"] = input} end,
			["rulename"] 		= function(input) return {["rulename"] = input } end,
			["defined-as"] 		= function(input) return {["defined-as"] = input} end,
			["elements"] 		= function(input)
				print("new element")
				for k,v in pairs(input) do
					print("type:" .. type(input))
				end
				return {["elements"] = input} end,
			["c-wsp"] 		= function(input) return nil end,
			["c-nl"] 		= function(input) return nil end,
			["comment"] 		= function(input) return nil end,
			["alternation"] 	= function(input) 
				if input[2] then
					print("alternation")
				end
				return {["alternation"] = input} end,
			["concatenation"] 	= function(input) 
				if input[2] then
					print("concatenation")
				end
				return {["concatenation"] = input} end,
			["repetition"] 		= function(input) 
				if input[2] then
					print("repetition")
				end
				return {["repetition"] = input} end,
			["repeat"] 		= function(input) return {["repeat"] = input} end,
			["element"] 		= function(input) return {["element"] = input} end,
			["group"] 		= function(input) return {["group"] = input} end,
			["option"] 		= function(input) return {["option"] = input} end,
			["char-val"] 		= function(input) return {["char-val"] = input} end,
			["num-val"] 		= function(input) return {["num-val"] = input} end,
			["bin-val"] 		= function(input) return {["bin-val"] = input} end,
			["dec-val"] 		= function(input) return {["dec-val"] = input} end,
			["hex-val"] 		= function(input) return {["hex-val"] = input} end,
			["prose-val"] 		= function(input) return {["prose-val"] = input} end,
		}

		local productions = {
			["rulelist"] 		= Ct( ( V("rule") + ( V("c-wsp")^0 * V("c-nl") ))^1 ) ,
			["rule"] 		= Ct( V("rulename") * V("defined-as") * V("elements") * V("c-nl") ) ,
			["rulename"] 		= C( V("ALPHA") * ( V("ALPHA") + V("DIGIT") + P("-") )^0 ) ,
			["defined-as"] 		= C( V("c-wsp")^0 * ( P("=") + P("=/") ) * (V("c-wsp") )^0 ) ,
			["elements"] 		= Ct( V("alternation") * ( V("c-wsp") )^0 ) ,
			["c-wsp"] 		= C( V("WSP") + ( V("c-nl") * V("WSP") ) ) ,
			["c-nl"] 		= C( V("comment") + V("CRLF") ) ,
			["comment"] 		= C( P(";") * ( V("WSP") + V("VCHAR") )^0 * V("CRLF") ) ,
			["alternation"] 	= Ct( V("concatenation") * ( V("c-wsp")^0 * P("/") * V("c-wsp")^0 * V("concatenation") )^0 ) ,
			["concatenation"] 	= Ct( V("repetition") * ( V("c-wsp")^1 * V("repetition") )^0 ) ,
			["repetition"] 		= Ct( V("repeat")^-1 * V("element") ) ,
			["repeat"] 		= Ct( ( V("DIGIT")^0 * P("*") * V("DIGIT")^0) + V("DIGIT")^1 ) ,
			["element"] 		= Ct( V("rulename") + V("group") + V("option") + V("char-val") + V("num-val") + V("prose-val") ) ,
			["group"] 		= Ct( P("(") * V("c-wsp")^0 * V("alternation") * V("c-wsp")^0 * P(")") ) ,
			["option"] 		= Ct( P("[") * V("c-wsp")^0 * V("alternation") * V("c-wsp")^0 * P("]") ) ,
			["char-val"] 		= C( V("DQUOTE") * ( R("\32\33") + R("\35\128") )^0 * V("DQUOTE") ) ,
			["num-val"] 		= C( P("%") * ( V("bin-val") + V("dec-val") + V("hex-val") ) ) ,
			["bin-val"] 		= C( P("b") * V("BIT")^1 * ( ( P(".") * V("BIT")^1 )^1 + ( P("-") * V("BIT")^1 ) )^-1 ) ,
			["dec-val"] 		= C( P("d") * V("DIGIT")^1 * ( ( P(".") * V("BIT")^1 )^1 + ( P("-") * V("BIT")^1 ) )^-1 ) ,
			["hex-val"] 		= C( P("x") * V("HEXDIG")^1 * ( ( P(".") * V("HEXDIG")^1 )^1 + ( P("-") * V("HEXDIG")^1 ) )^-1 ) ,
			["prose-val"] 		= C( P("<") * ( R("\32\61") + R("\63\128") )^0 *  P(">")  ) ,
		}

		local coreRules = {
			--Core Rules : https://tools.ietf.org/html/rfc5234#appendix-B.1
			["ALPHA"] = R("az","AZ"),
			["BIT"] = Cg( P("01") ),
			["CHAR"] = Cg( R("\1\127") ),
			["CR"] = Cg( P("\13") ),
			["CRLF"] = Cg( P("\r\n") )/ function(input) return {["CRLF"] = input} end,
			["CTL"] = Cg( R("\0\31") + P("\127") ), 
			["DIGIT"] = Cg( R("09") ) / function (input) return{["DIGIT"] = input} end,
			["DQUOTE"] = Cg( P("\"") ),
			["HEXDIG"] = Cg( R("09","AF") ),
			["HTAB"] = Cg( P("\9") ),
			["LF"] = Cg( P("\10") ),
			["LWSP"] = Cg( ( V("WSP") + ( V("CRLF") * V("WSP") ) )^0) / function(input) return{["lwsp"] = input} end,
			["OCTET"] = Cg( R("\0\255") ),
			["SP"] = Cg( P("\32") ),
			["VCHAR"] = Cg( R("\33\126") ),
			["WSP"] = V("SP") + V("HTAB") ,
		}

		local abnfRules = {
			"rulelist";--rule to match
			["rulelist"] = true, 
			["rule"] = true, 
			["rulename"] = true, 
			["defined-as"] = true, 
			["elements"] = true, 
			["c-wsp"] = true, 
			["c-nl"] = true, 
			["comment"] = true, 
			["alternation"] = true, 
			["concatenation"] = true, 
			["repetition"] = true, 
			["repeat"] = true, 
			["element"] = true, 
			["group"] = true, 
			["option"] = true, 
			["char-val"] = true, 
			["num-val"] = true, 
			["bin-val"] = true, 
			["dec-val"] = true, 
			["hex-val"] = true,
			["prose-val"] = true,
		}
		
		--Combine our pattern matching rules with the associated transformations		
		for k,v in pairs(abnfRules) do
			if productions[k] and transformations[k] then -- skip our target rule
				abnfRules[k] = productions[k] / transformations[k]
			end
		end

		--ABNF depends on a set of core rules
		for k,v in pairs(coreRules) do 
			abnfRules[k] = v
		end

		return lpeg.P(abnfRules)
	end,
	["normalize"] = function(input)
		return  endWithNewline(
				fixMultilineRules(
					removeMultipleNewline(
						removeComments(
							trimPreceedingWhitespace(
								windowsNewline(input))))))
	end,
	["compile"] = function(syntaxTree)

		local output
		local transformations = {
			["rulelist"] 		= function(input) return {["rulelist"] = input} end, 
			["rule"] 		= function(input) return {["rule"] = input} end,
			["rulename"] 		= function(input) return {["rulename"] = input} end,
			["defined-as"] 		= function(input) return {["defined-as"] = input} end,
			["elements"] 		= function(input) return {["elements"] = input} end,
			["c-wsp"] 		= function(input) return nil end,
			["c-nl"] 		= function(input) return nil end,
			["comment"] 		= function(input) return nil end,
			["alternation"] 	= function(input) return {["alternation"] = input} end,
			["concatenation"] 	= function(input) return {["concatenation"] = input} end,
			["repetition"] 		= function(input) return {["repetition"] = input} end,
			["repeat"] 		= function(input) return {["repeat"] = input} end,
			["element"] 		= function(input) return {["element"] = input} end,
			["group"] 		= function(input) return {["group"] = input} end,
			["option"] 		= function(input) return {["option"] = input} end,
			["char-val"] 		= function(input) return {["char-val"] = input} end,
			["num-val"] 		= function(input) return {["num-val"] = input} end,
			["bin-val"] 		= function(input) return {["bin-val"] = input} end,
			["dec-val"] 		= function(input) return {["dec-val"] = input} end,
			["hex-val"] 		= function(input) return {["hex-val"] = input} end,
			["prose-val"] 		= function(input) return {["prose-val"] = input} end,
		}

		--local preFunc = function()

		--end


		--utils.treeWalk2()

		--utils.printTable2(syntaxTree,2)
		local preFunc = function(k,v,d)
				if v[1] and d == 2 then
					for l,w in pairs(v[3]) do
						print(l) -- get key
					end
					utils.printTable(v[1])
				end
		end

		local leafFunc = function(k,v,d)
				--print("rule " .. v[3])
		end

		local postFunc = function(k,v,d)
		end

		utils.treeWalk2(syntaxTree,preFunc,leafFunc,postFunc,2)
		-- utils.printTable2(syntaxTree)
			
			--[[
			-- expected output
			local productions = {
				["rulelist"] 		= Ct( ( V("rule") + ( V("c-wsp")^0 * V("c-nl") ))^1 ) ,
				["rule"] 		= Ct( V("rulename") * V("defined-as") * V("elements") * V("c-nl") ) ,
				["rulename"] 		= Ct( V("ALPHA") * ( V("ALPHA") + V("DIGIT") + P("-") )^0 ) ,
				["defined-as"] 		= C( V("c-wsp")^0 * ( P("=") + P("=/") ) * (V("c-wsp") )^0 ) ,
				["elements"] 		= Cg( V("alternation") * ( V("c-wsp") )^0 ) ,
				["c-wsp"] 		= C( V("WSP") + ( V("c-nl") * V("WSP") ) ) ,
				["c-nl"] 		= C( V("comment") + V("CRLF") ) ,
				["comment"] 		= C( P(";") * ( V("WSP") + V("VCHAR") )^0 * V("CRLF") ) ,
				["alternation"] 	= Ct( V("concatenation") * ( V("c-wsp")^0 * P("/") * V("c-wsp")^0 * V("concatenation") )^0 ) ,
				["concatenation"] 	= Ct( V("repetition") * ( V("c-wsp")^1 * V("repetition") )^0 ) ,
				["repetition"] 		= Ct( V("repeat")^-1 * V("element") ) ,
				["repeat"] 		= Ct( ( V("DIGIT")^0 * P("*") * V("DIGIT")^0) + V("DIGIT")^1 ) ,
				["element"] 		= Ct( V("rulename") + V("group") + V("option") + V("char-val") + V("num-val") + V("prose-val") ) ,
				["group"] 		= Ct( P("(") * V("c-wsp")^0 * V("alternation") * V("c-wsp")^0 * P(")") ) ,
				["option"] 		= Ct( P("[") * V("c-wsp")^0 * V("alternation") * V("c-wsp")^0 * P("]") ) ,
				["char-val"] 		= C( V("DQUOTE") * ( R("\32\33") + R("\35\128") )^0 * V("DQUOTE") ) ,
				["num-val"] 		= C( P("%") * ( V("bin-val") + V("dec-val") + V("hex-val") ) ) ,
				["bin-val"] 		= C( P("b") * V("BIT")^1 * ( ( P(".") * V("BIT")^1 )^1 + ( P("-") * V("BIT")^1 ) )^-1 ) ,
				["dec-val"] 		= C( P("d") * V("DIGIT")^1 * ( ( P(".") * V("BIT")^1 )^1 + ( P("-") * V("BIT")^1 ) )^-1 ) ,
				["hex-val"] 		= C( P("x") * V("HEXDIG")^1 * ( ( P(".") * V("HEXDIG")^1 )^1 + ( P("-") * V("HEXDIG")^1 ) )^-1 ) ,
				["prose-val"] 		= C( P("<") * ( R("\32\61") + R("\63\128") )^0 *  P(">")  ) ,
			}
			--]]
	end,
	["capture"] = function (input)

	end
}


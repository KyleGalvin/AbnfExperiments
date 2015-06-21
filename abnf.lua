
require "io"
require "lpeg"

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
	['abnf.001.build']=function() 
		local f = io.open("./abnf.abnf.lua","r")
		local t = f:read("*all")

		--print("my test file is: ", t)
		f:close()
		local V = lpeg.V
		local P = lpeg.P
		local R = lpeg.R
		local Cg = lpeg.Cg
		local Ct = lpeg.Ct

		local parser = lpeg.P({
			--ABNF Definition of ABNF : https://tools.ietf.org/html/rfc5234#section-4
			"rulelist";
			["rulelist"] = Ct( ( V("rule") + ( V("c-wsp")^0 * V("c-nl") ))^1 ) / function(input) return {["rulelist"] = input} end, 
			["rule"] = Ct( V("rulename") * V("defined-as") * V("elements") * V("c-nl") ) / function(input) return {["rule"] = input} end,
			["rulename"] = Ct( V("ALPHA") * ( V("ALPHA") + V("DIGIT") + P("-") )^0 ) / function(input) return {["rulename"] = input} end,
			["defined-as"] = ( V("c-wsp") )^0 * ( P("=") + P("=/")) * (V("c-wsp") )^0 / function(input) return {["defined-as"] = input} end,
			["elements"] = V("alternation") * ( V("c-wsp") )^0 / function(input) return {["elements"] = input} end,
			["c-wsp"] = V("WSP") + ( V("c-nl") * V("WSP") ) / function(input) return {["c-wsp"] = input} end,
			["c-nl"] = V("comment") + V("CRLF") / function(input) return {["c-nl"] = input} end,
			["comment"] = P(";") * ( V("WSP") + V("VCHAR") )^0 * V("CRLF") / function(input) return {["comment"] = input} end,
			["alternation"] = V("concatenation") * ( V("c-wsp")^0 * P("/") * V("c-wsp")^0 * V("concatenation") )^0 / function(input) return {["alternation"] = input} end,
			["concatenation"] = V("repetition") * ( V("c-wsp")^1 * V("repetition") )^0 / function(input) return {["concatenation"] = input} end,
			["repetition"] = V("repeat")^-1 * V("element") / function(input) return {["repetition"] = input} end,
			["repeat"] = V("DIGIT")^1 + ( V("DIGIT")^0 * P("*") * V("DIGIT")^0) / function(input) return {["repeat"] = input} end,
			["element"] = V("rulename") + V("group") + V("option") + V("char-val") + V("num-val") + V("prose-val") / function(input) return {["element"] = input} end,
			["group"] = P("(") * V("c-wsp")^0 * V("alternation") * V("c-wsp")^0 * P(")") / function(input) return {["group"] = input} end,
			["option"] = P("[") * V("c-wsp")^0 * V("alternation") * V("c-wsp")^0 * P(")") / function(input) return {["option"] = input} end,
			["char-val"] = V("DQUOTE") * ( R("\32\33") + R("\35\128") )^0 * V("DQUOTE") / function(input) return {["char-val"] = input} end,
			["num-val"] = P("%") * ( V("bin-val") + V("dec-val") + V("hex-val") ) / function(input) return {["num-val"] = input} end,
			["bin-val"] = P("b") * V("BIT")^1 * ( ( P(".") * V("BIT")^1 )^1 + ( P("-") * V("BIT")^1 ) )^-1 / function(input) return {["bin-val"] = input} end,
			["dec-val"] = P("d") * V("DIGIT")^1 * ( ( P(".") * V("BIT")^1 )^1 + ( P("-") * V("BIT")^1 ) )^-1 / function(input) return {["dec-val"] = input} end,
			["hex-val"] = P("x") * V("HEXDIG")^1 * ( ( P(".") * V("HEXDIG")^1 )^1 + ( P("-") * V("HEXDIG")^1 ) )^-1 / function(input) return {["hex-val"] = input} end,
			["prose-val"] = P("<") * ( R("\32\61") + R("\63\128") )^0 *  P(">") / function(input) return {["prose-val"] = input} end,
			--Core Rules : https://tools.ietf.org/html/rfc5234#appendix-B.1
			["ALPHA"] = Cg( R("az","AZ") ) / function(input) return {["ALPHA"] = input} end,
			["BIT"] = P("01"),
			["CHAR"] = R("\1\127"),
			["CR"] = P("\13"),
			["CRLF"] = P("\r\n"),
			["CTL"] = R("\0\31") + P("\127"), 
			["DIGIT"] = Cg( R("09") ) / function (input) return{["DIGIT"] = input} end,
			["DQUOTE"] = P("\""),
			["HEXDIG"] = R("09","AF"),
			["HTAB"] = P("\9"),
			["LF"] = P("\10"),
			["LWSP"] = Ct( ( V("WSP") + ( V("CRLF") * V("WSP") ) )^0) / function(input) return{["lwsp"] = input} end,
			["OCTET"] = R("\0\255"),
			["SP"] = P("\32"),
			["VCHAR"] = R("\33\126"),
			["WSP"] = Ct( V("SP") + V("HTAB") ) / function(input) return{["wsp"] = input} end,
		})
		parser = Cg(parser)

		local f = io.open("./abnfTest1.lua","r")
		local ABNFDefinitionOfABNF = f:read("*all")
		ABNFDefinitionOfABNF  = "rulelist       =  *2( rule / (*c-wsp c-nl) )\r\n"
		print("Text:",ABNFDefinitionOfABNF)
		local result = lpeg.match(parser,ABNFDefinitionOfABNF)

		print("Results:")
		if(type(result) == "table") then
			tprint(result)
		else
			print(result)
		end 
	end,

	-- use new abnf builder to build a clone of itself again
	['abnf.002.rebuilt']=function()
		
	end,

	-- check that the two abnf builders are identical
	['abnf.003.compare']=function()


	end,
}

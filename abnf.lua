require "lpeg"

local grammar = function()
	local V = lpeg.V
	local P = lpeg.P
	local R = lpeg.R
	local C = lpeg.C
	local Cg = lpeg.Cg
	local Ct = lpeg.Ct
	local Cc = lpeg.Cc

	return lpeg.P({
		--ABNF Definition of ABNF : https://tools.ietf.org/html/rfc5234#section-4
		"rulelist";
		["rulelist"] = Ct( ( V("rule") + ( V("c-wsp")^0 * V("c-nl") ))^1 ) / 
			function(input) return {["rulelist"] = input} end, 
		["rule"] = Ct( V("rulename") * V("defined-as") * V("elements") * V("c-nl") ) / 
			function(input) return {["rule"] = input} end,
		["rulename"] = C( V("ALPHA") * ( V("ALPHA") + V("DIGIT") + P("-") )^0 ) / 
			function(input) return {["rulename"] = input} end,
		["defined-as"] = Ct( V("c-wsp")^0 * ( P("=") + P("=/") ) * (V("c-wsp") )^0 ) / 
			function(input) return {["defined-as"] = input} end,
		["elements"] = Ct( V("alternation") * ( V("c-wsp") )^0 ) / 
			function(input) return {["elements"] = input} end,
		["c-wsp"] = Ct( V("WSP") + ( V("c-nl") * V("WSP") ) ) / 
			function(input) return {["c-wsp"] = input} end,
		["c-nl"] = Ct( V("comment") + V("CRLF") ) / 
			function(input) return {["c-nl"] = input} end,
		["comment"] = Ct( P(";") * ( V("WSP") + V("VCHAR") )^0 * V("CRLF") ) / 
			function(input) return {["comment"] = input} end,
		["alternation"] = Ct( V("concatenation") * ( V("c-wsp")^0 * P("/") * V("c-wsp")^0 * V("concatenation") )^0 ) / 
			function(input) return {["alternation"] = input} end,
		["concatenation"] = Ct( V("repetition") * ( V("c-wsp")^1 * V("repetition") )^0 ) / 
			function(input) return {["concatenation"] = input} end,
		["repetition"] = Ct( V("repeat")^-1 * V("element") ) / 
			function(input) return {["repetition"] = input} end,
		["repeat"] = Ct( ( V("DIGIT")^0 * P("*") * V("DIGIT")^0) + V("DIGIT")^1 ) / 
			function(input) return {["repeat"] = input} end,
		["element"] = Ct( V("rulename") + V("group") + V("option") + V("char-val") + V("num-val") + V("prose-val") ) / 
			function(input) return {["element"] = input} end,
		["group"] = Ct( P("(") * V("c-wsp")^0 * V("alternation") * V("c-wsp")^0 * P(")") ) / 
			function(input) return {["group"] = input} end,
		["option"] = Ct( P("[") * V("c-wsp")^0 * V("alternation") * V("c-wsp")^0 * P(")") ) / 
			function(input) return {["option"] = input} end,
		["char-val"] = Ct( V("DQUOTE") * ( R("\32\33") + R("\35\128") )^0 * V("DQUOTE") ) / 
			function(input) return {["char-val"] = input} end,
		["num-val"] = Ct( P("%") * ( V("bin-val") + V("dec-val") + V("hex-val") ) ) / 
			function(input) return {["num-val"] = input} end,
		["bin-val"] = Ct( P("b") * V("BIT")^1 * ( ( P(".") * V("BIT")^1 )^1 + ( P("-") * V("BIT")^1 ) )^-1 ) / 
			function(input) return {["bin-val"] = input} end,
		["dec-val"] = Ct( P("d") * V("DIGIT")^1 * ( ( P(".") * V("BIT")^1 )^1 + ( P("-") * V("BIT")^1 ) )^-1 ) / 
			function(input) return {["dec-val"] = input} end,
		["hex-val"] = Ct( P("x") * V("HEXDIG")^1 * ( ( P(".") * V("HEXDIG")^1 )^1 + ( P("-") * V("HEXDIG")^1 ) )^-1 ) / 
			function(input) return {["hex-val"] = input} end,
		["prose-val"] = Ct( P("<") * ( R("\32\61") + R("\63\128") )^0 *  P(">")  ) / 
			function(input) return {["prose-val"] = input} end,
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
		["WSP"] = Cg( V("SP") + V("HTAB") ) / function(input) return{["wsp"] = input} end,
	})
end

return grammar

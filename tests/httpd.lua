
require "luacurl"
--require "httpd"
return {
	{name = "httpd.parse.01", test = function() 
		--[[
		input=""


		--- collected ABNF from https://tools.ietf.org/html/rfc7230
		-- I've attached section references to blocks to allow more detail to be looked up
		-- the complete set of production rules are reitereated in Appendix B
		-- https://tools.ietf.org/html/rfc7230#appendix-B
		local httpMessage = lpeg.P({
			"httpMessage";

			--- 1.2. Syntax Notation
			-- This references https://tools.ietf.org/html/rfc5234#appendix-B.1
			-- and defines core token rules for RFC ABNF
			VCHAR = lpeg.R("\33\126");
			DIGIT = lpeg.R("09");
			ALPHA = lpeg.R("az","AZ");
			CRLF = lpeg.P("\r\n");
			OCTET = lpeg.R("\0\255");
			DQUOTE = lpeg.P("\"");

			--- https://tools.ietf.org/html/rfc7230#section-3
			-- 3. Message Format
			httpMessage = lpeg.V("startLine") * (lpeg.V("headerField") * lpeg.V("CRLF"))^0 * lpeg.V("CRLF") * lpeg.V("messageBody");
		
			--- 3.1. Start Line
			-- this takes us down the call/response branches
			startLine = lpeg.V("requestLine") + lpeg.V("statusLine");

			--- 3.1.1. Request Line
			-- 3.1.1. requires: https://tools.ietf.org/html/rfc7231#section-4 
			-- which defines request methods
			SP = lpeg.S(" ");
			requestLine = lpeg.V("method") * lpeg.V("SP") * lpeg.V("requestTarget") * lpeg.V("SP") * lpeg.V("httpVersion") * lpeg.V("CRLF");
			method = lpeg.V("token");
			HTAB = lpeg.S("\t");

			--- 3.1.2. Status Line
			statusLine = lpeg.V("httpVersion") * lpeg.V("SP") * lpeg.V("statusCode") * lpeg.V("SP") * lpeg.V("reasonPhrase") * lpeg.V("CRLF");
			statusCode = lpeg.V("DIGIT") * lpeg.V("DIGIT") * lpeg.V("DIGIT");
			reasonPhrase = ( lpeg.V("HTAB") + lpeg.V("SP") + lpeg.V("VCHAR") + lpeg.V("obsText"))^0;

			--- 3.2. Header Fields
			headerField = lpeg.V("fieldName") * ":" * lpeg.V("OWS") * lpeg.V("fieldValue") * lpeg.V("OWS");
			fieldName = lpeg.V("token");
			fieldValue = ( lpeg.V("fieldContent") + lpeg.V("obsFold") )^0;
			fieldContent = lpeg.V("fieldVChar") * (lpeg.V("SP") + lpeg.V("HTAB")^-1 * lpeg.V("fieldVChar"))^-1;
			fieldVChar = lpeg.V("VCHAR") + lpeg.V("obsText");
			obsFold = lpeg.V("CRLF") * (lpeg.V("SP") + lpeg.V("HTAB"))^-1;

			--- 3.2.3. Whitespace
			OWS = (lpeg.V("SP") + lpeg.V("HTAB"))^0;
			RWS = (lpeg.V("SP") + lpeg.V("HTAB"))^1;
			BWS = OWS; --bad white space. Only included for historical reasons
			
			--- 3.2.6. Field Value Components
			token = lpeg.V("tchar")^1;
			tchar = lpeg.S("!#$%'*+-.^_`|~") + lpeg.V("DIGIT") + lpeg.V("ALPHA");
			quotedString = lpeg.V("DQUOTE") * ( lpeg.V("qdText") + lpeg.V("quotedPair") )^0 * lpeg.V("DQUOTE");
			qdText = lpeg.V("HTAB") + lpeg.V("SP") + lpeg.S("\31") +lpeg.R("\33\91")+ lpeg.R("\93\126") + lpeg.V("obsText") ;
			obsText = lpeg.R("\128\255");
			comment = lpeg.S("(") * (lpeg.V("cText") + lpeg.V("quotedPair")+ lpeg.V("comment"))^0 * lpeg.S(")");
			cText = lpeg.V("HTAB") + lpeg.V("SP") + lpeg.R("\31\39")+ lpeg.R("\93\126") + lpeg.V("obsText") ;
			quotedPair = lpeg.S("\\") * (lpeg.V("HTAB") + lpeg.V("SP") + lpeg.V("VCHAR") + lpeg.V("obsText") );
		
			--- 3.3. Message Body
			messageBody = lpeg.V("OCTET")^0;	
			--- 3.3.2	
			contentLength = lpeg.V("DIGIT")^1;
	
			--- 5.3. Request Target
			requestTarget = lpeg.V("originForm") + lpeg.V("absoluteForm") + lpeg.V("authorityForm") + lpeg.V("asteriskForm");
			--- 5.3.1. origin-form
			originForm = lpeg.V("absolutePath") * (lpeg.S("?") * lpeg.V("query"))^-1

			--- URI definitions are their own seperate RFC

			--- Absolute URI defined in RFC3986 Section 4.3
			--- https://tools.ietf.org/html/rfc3986#section-4.3
			absoluteURI = scheme ":" hierPart ("?" query);

			--- Scheme defined in RFC3986 Section 3.1
			--- https://tools.ietf.org/html/rfc3986#section-3.1
			scheme = ALPHA ( ALPHA + DIGIT + "+" + "-" + ".")^0
		})
		result = lpeg.match(httpMessage,input)
		print("result: " .. result)

		--]]
		return false
	end},
	{name = "httpd.curl.01", test = function() 
		local c = curl.new()
		c:setopt(curl.OPT_WRITEFUNCTION,
			function(userparam, buffer)
			--	print("writing: " ..buffer)
			end)
		c:setopt(curl.OPT_URL,"127.0.0.1")
		--c:setopt(curl.OPT_HTTPHEADER,exampleHeader)
		c:setopt(curl.OPT_HTTPGET,true)	
		--c:setopt(curl.OPT_READFUNCTION,
		--	function(userparam, buffer)
		--		print("got response: " ..buffer)
		--	end)
		c:perform()
		c:close()
		--print("curl call sent...")
	end},
}

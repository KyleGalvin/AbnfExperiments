local lpeg = require "lpeg"

return {
	httpd_peg_parse_http=function(input)

		-- collected ABNF from https://tools.ietf.org/html/rfc7230
		-- I've attached section references to blocks to allow more detail to be looked up
		-- the complete set of production rules are reitereated in Appendix B
		-- https://tools.ietf.org/html/rfc7230#appendix-B
		local httpMessage = lpeg.P({
			"httpMessage";
			DIGIT = lpeg.R("09");
			ALPHA = lpeg.R("az","AZ");

			-- https://tools.ietf.org/html/rfc7230#section-3
			-- 3. Message Format
			CRLF = lpeg.P("\r\n");
			httpMessage = lpeg.V("startLine") * (lpeg.V("headerField") * lpeg.V("CRLF"))^0 * lpeg.V("CRLF") * lpeg.V("messageBody");
		
			-- 3.1. Start Line
			-- this takes us down the call/response branches
			startLine = lpeg.V("requestLine") + lpeg.V("statusLine")

			-- 3.1.1. Request Line
			-- 3.1.1. requires: https://tools.ietf.org/html/rfc7231#section-4 
			-- which defines request methods
			SP = lpeg.S(" ");
			requestLine = lpeg.V("method") * lpeg.V("SP") * lpeg.V("requestTarget") * lpeg.V("SP") * lpeg.V("httpVersion") * lpeg.V("CRLF");
			method = lpeg.V("token");

			-- 3.1.2. Status Line
			statusLine = lpeg.V("httpVersion") * lpeg.V("SP") * lpeg.V("statusCode") * lpeg.V("SP") * lpeg.V("reasonPhrase") * lpeg.V("CRLF");
			statusCode = lpeg.V("digit") * lpeg.V("digit") * lpeg.V("digit");
			reasonPhrase = ( lpeg.V("HTAB") + lpeg.V("SP") + lpeg.V("VCHAR") + lpeg.V("obsText"))^0;

			-- 3.2. Header Fields
			headerField = lpeg.V("fieldName") * ":" * lpeg.V("OWS") * lpeg.V("fieldValue") * lpeg.V("OWS");
			fieldName = lpeg.V("token");
			fieldValue = ( lpeg.V("fieldContent") + lpeg.V("obsFold") )^0;
			fieldContent = lpeg.V("fieldVChar") * (lpeg.V("SP") + lpeg.V("HTAB")^-1 lpeg.V("fieldVChar"))^-1;
			fieldVChar = lpeg.V("VCHAR") + lpeg.V("obsText")
			obsFold = lpeg.V("CRLF") (lpeg.V("SP") + lpeg.V("HTAB"))^-1

			-- 3.2.3. Whitespace
			HTAB = lpeg.S("\t");
			OWS = (lpeg.V("SP") + lpeg.V("HTAB"))^0;
			RWS = (lpeg.V("SP") + lpeg.V("HTAB"))^1;
			BWS = OWS; --bad white space. Only included for historical reasons
			
			-- 3.2.6. Field Value Components
			tchar = lpeg.S("!#$%'*+-.^_`|~") + lpeg.V("DIGIT") + lpeg.V("ALPHA");
			token = lpeg.V("tchar")^1;
			
			-- 3.3.2	
			contentLength = lpeg.V("DIGIT")^1;
		})

		return false
	end
}

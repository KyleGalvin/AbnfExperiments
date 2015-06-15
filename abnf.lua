
require "io"
return {

	--build abnf builder from RFC definition of abnf grammar
	['abnf.001.build']=function() 
		local f = io.open("./abnf.abnf.lua","r")
		local t = f:read("*all")
		--print("my test file is: ", t)
		f:close()
	end,

	-- use new abnf builder to build a clone of itself again
	['abnf.002.rebuilt']=function()
		
	end,

	-- check that the two abnf builders are identical
	['abnf.003.compare']=function()


	end,
}

local SDL = require "./src/SDL2"
local ffi = require "ffi"
local screenWidth = 640
local screenHeight = 480

local main = function()
	local quit = false
	local e = ffi.new("SDL_Event")
	SDL.init(SDL.INIT_VIDEO)
	local window = SDL_createWindow( "SDL Tutorial", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, screenWidth, screenHeight, SDL_WINDOW_SHOWN )

	local screenSurface = SDL.getWindowSurface(window)
	SDL.fillRect(screenSurface, nil, SDL.mapRGB(screenSurface.format,255,255,255))
	SDL.updateWindowSurface(window)
	while (not quit) do
		while ( SDL.pollEvent(e) ~=0 ) do
			if ( e.type == SDL.quit ) then
				quit = true
			end
		end
	end
	SDL.destroyWindow(window)
	SDL.quit()
end

main()

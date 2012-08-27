--      ==          == == ==       ==       == ==
--      ==          ==    ==    ==    ==    ==    ==
--      ==          ==    ==    == == ==    ==    ==
--      ==          ==    ==    ==    ==    ==    ==
--      == == ==    == == ==    ==    ==    == ==    

function love.load()
	-- load basic modules
	require("resources/entities")
	require("resources/entityFactory")
	ents.Startup()

	-- disabled until marty fixes repo
	local ent=ents.Create("player", 200,200)

	-- at end of file for prototyping. 
	--Leave file, but try to move contents to a permanent home once prototyped
	tempInit()
	
end


--      ==    ==    == ==       == ==          ==       == == ==    == == ==
--      ==    ==    ==    ==    ==    ==    ==    ==       ==       ==
--      ==    ==    == ==       ==    ==    == == ==       ==       == ==
--      ==    ==    ==          ==    ==    ==    ==       ==       ==
--      == == ==    ==          == ==       ==    ==       ==       == == ==

function love.update(dt)
	-- Update factory
	entFactory.update(dt)
	
	-- Update entities
	ents:update(dt)
end


--     == ==       == ==          ==       ==    ==
--     ==    ==    ==    ==    ==    ==    ==    ==
--     ==    ==    == ==       == == ==    ==    ==
--     ==    ==    ==   ==     ==    ==    == == ==
--     == ==       ==   ==     ==    ==    ==    ==

function love.draw()
	-- Draw entities
	tempDraw()
	ents:draw()
end

function love.focus(bool)
end


--      == == ==    ==    ==    == ==       ==    ==    == == ==
--         ==       == == ==    ==    ==    ==    ==       ==
--         ==       == == ==    == ==       ==    ==       ==
--         ==       ==    ==    ==          ==    ==       ==
--      == == ==    ==    ==    ==          == == ==       ==

function love.keypressed(key, unicode)
	-- Notify entity of keypressed event
	ents:keypressed(key, unicode)
end

function love.keyreleased(key, unicode)
	-- Notify entity of keyreleased event
	ents:keyreleased(key, unicode)
end

function love.mousepressed(x, y, button)
	-- Notify entity of mousepressed event
	ents:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
end


--      == == ==    ==    ==    == == ==    == == ==
--      ==    ==    ==    ==       ==          ==
--      ==    ==    ==    ==       ==          ==
--      == == ==    ==    ==       ==          ==
--            ==    == == ==    == == ==       ==

function love.quit()
end


---- everything below this should probably be moved into something useful

function tempInit()
print("init works")

imgBackground = { }

imgBackground[1] = love.graphics.newImage("resources/images/background_a.png")
imgBackground[2] = love.graphics.newImage("resources/images/background_b.png")
imgBackground[3] = love.graphics.newImage("resources/images/background_c.png")


end


function tempDraw()

	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(imgBackground[3],0,0)
end

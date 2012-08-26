--      ==          == == ==       ==       == ==
--      ==          ==    ==    ==    ==    ==    ==
--      ==          ==    ==    == == ==    ==    ==
--      ==          ==    ==    ==    ==    ==    ==
--      == == ==    == == ==    ==    ==    == ==    

function love.load()
	-- Entity module
	require("resources/entities")
	ents.Startup()
	
	local entPlayer = ents.Create("player", 100, 100)
	entPlayer:addMount("mount", 1)
end


--      ==    ==    == ==       == ==          ==       == == ==    == == ==
--      ==    ==    ==    ==    ==    ==    ==    ==       ==       ==
--      ==    ==    == ==       ==    ==    == == ==       ==       == ==
--      ==    ==    ==          ==    ==    ==    ==       ==       ==
--      == == ==    ==          == ==       ==    ==       ==       == == ==

function love.update(dt)
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





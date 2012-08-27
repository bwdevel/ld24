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

	tempUpdate(dt)
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

	tempKeyPress(key, unicode)

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

--------------------------------------------------------------------------------------
---- everything below this should probably be moved to it's home after prototyping ---
--------------------------------------------------------------------------------------
function tempInit()
	print("init works")


	imgBackground = { }

	imgBackground[1] = love.graphics.newImage("resources/images/background_a.png")
	imgBackground[2] = love.graphics.newImage("resources/images/background_b.png")
	imgBackground[3] = love.graphics.newImage("resources/images/background_c.png")

	bgCurrent = 1
	bgOld = #imgBackground
	bgFade = false
	bgFadeRate = 255
	bgFadeLevel = 255

end

function tempUpdate(dt)
	if bgFade == true then
		bgFadeLevel = bgFadeLevel - bgFadeRate*dt
		if bgFadeLevel < 0 then
			bgFadeLevel = 255
			bgFade = false
		end
	end

end

function tempDraw()
	love.graphics.setBackgroundColor(0,0,0)

	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(imgBackground[bgCurrent],0,0)

	if bgFade == true then
		love.graphics.setColor(255,255,255,bgFadeLevel)
		love.graphics.draw(imgBackground[bgOld],0,0)
	end
end

function tempKeyPress(key, unicode)
	if key == "5" and bgFade == false then
		bgOld = bgCurrent
		bgCurrent = bgCurrent + 1
		if bgCurrent > #imgBackground then bgCurrent = 1 end
		bgFade = true
	end

end


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

--	local ent=ents.Create("enemy", 600,400)
--	local ent=ents.Create("enemy", 600,200)
--	local ent=ents.Create("enemy", 200,400)

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

	-- used to track game phases
	gamePhase = 1

	
	-- code to manage background states
	imgBackground = { }

	imgBackground[1] = love.graphics.newImage("resources/images/background_a.png")
	imgBackground[2] = love.graphics.newImage("resources/images/background_ba.png")
	imgBackground[3] = love.graphics.newImage("resources/images/background_c.png")

	bgCurrent = 1
	bgOld = #imgBackground
	bgFade = false
	bgFadeRate = 255
	bgFadeLevel = 255


	-- xpBar code
	xpBar = {}

	xpBar.x, xpBar.y, xpBar.w, xpBar.h = 200, 550, 400, 25

	xpBar.xp = 1
	xpBar.dir = 1


end

function tempUpdate(dt)
	if bgFade == true then
		bgFadeLevel = bgFadeLevel - bgFadeRate*dt
		if bgFadeLevel < 0 then
			bgFadeLevel = 255
			bgFade = false
		end
	end

	xpBar.xp = xpBar.xp + 25 * xpBar.dir * dt

	-- reverse bar (mockup)
	if xpBar.xp > 100 then
		xpBar.xp = 100
		xpBar.dir = -(xpBar.dir)
	elseif xpBar.xp < 1 then 
		xpBar.xp = 1
		xpBar.dir = -(xpBar.dir) 
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


	if gamePhase == 1 then
		love.graphics.setColor(108,108,108,255)
		love.graphics.rectangle("fill", xpBar.x-4, xpBar.y-4, xpBar.w+8, xpBar.h+8)

		love.graphics.setColor(104,55,45,255)
		love.graphics.rectangle("fill", xpBar.x, xpBar.y, xpBar.w*xpBar.xp/100, xpBar.h)
	end

		if gamePhase == 1 then
		love.graphics.setColor(108,108,108,255)
		love.graphics.rectangle("fill", xpBar.x-4, xpBar.y-4, xpBar.w+8, xpBar.h+8)

		love.graphics.setColor(104,55,45,255)
		love.graphics.rectangle("fill", xpBar.x, xpBar.y, xpBar.w*xpBar.xp/100, xpBar.h)
	end

	
end

function tempKeyPress(key, unicode)
	if key == "5" and bgFade == false then
		bgOld = bgCurrent
		bgCurrent = bgCurrent + 1
		if bgCurrent > #imgBackground then bgCurrent = 1 end
		bgFade = true
		gamePhase = gamePhase + 1
		if gamePhase > 3 then gamePhase = 1 end
		print(gamePhase)
	end

end


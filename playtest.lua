--      ==          == == ==       ==       == ==
--      ==          ==    ==    ==    ==    ==    ==
--      ==          ==    ==    == == ==    ==    ==
--      ==          ==    ==    ==    ==    ==    ==
--      == == ==    == == ==    ==    ==    == ==    

function love.load()
	imgPath = "images/"
	player = {}
	player.sprite = love.graphics.newImage("images/player.png")

	enemy = {}
	enemy.sprite = love.graphics.newImage("images/enemy.png")

	pBullets = {}

	pBulletSpeed = 250


	width = love.graphics.getWidth()
	height = love.graphics.getHeight()

	player.rot, 	player.rotSpd, 	player.rotDec, 	player.rotDir, 	player.deg = 
	0, 				2, 				5, 				0, 				0
	enemy.rot,		enemy.rotSpd,	enemy.rotDec,	enemy.rotDir,	enemy.deg =
	0,				2,				5,				0,				0

	--player.rot 				= current player rotation
	--player.rotSpd 			= speed at which the player rotates
	--player.rotDec 			= the rotation decay					**unused**
	--player.rotDir				= -1, 0, +1 for direction of rotation
	--player.deg 				= container for degrees from rads
	
	player.x, 	player.y,	player.ox,	player.oy,	player.sx,	player.sy,	player.vx,	player.vy = 
	200,		200,		15.5,		15.5,		1,			1,			0,			0

	player.w = 32

	enemy.x,	enemy.y, 	enemy.ox,	enemy.oy,	enemy.sx, 	enemy.sy,	enemy.vx,	enemy.vy =
	600,		400,		15.5,		15.5,		1,			1,			0,			0
	--player.x, player.y 		= player coordinates on screen
	--player.ox , player.oy 	= rotation offset of player
	--player.sx, player.sy		= scale of player
	--player.vx, player.vy		= player's current velocity

	player.t, 	player.tRate,	player.spd,	player.spdMax,	player.friction = 
	false, 		15,				25,			0,				0.99

	enemy.t,	enemy.tRate,	enemy.spd,	enemy.spdMax,	enemy.friction =
	false,		15,				25,			0,				0.99
	--player.t 					= toggle for state of player thrust
	--player.tRate 				= accel/thrust rate
	--player.spdMax				= max velocity of player
	--player.spd 				= current player speed
	--player.friction			= decay rate without thrust

	enemy.range = 250

	playerAimType = 1 			-- 1 = keys, 2 = mouse aim, 3= mouse rotate

	rotateRight = false			-- current rotation state for key controls
	rotateLeft = false			-- current rotation state for key controls

	reactionLoss = 0.80 		-- how much velocity is lost in a collision

	debug = {}
	debug.state = false
	debug.x	=	5
	debug.mx = width/3
	debug.y	= 550
	debug.my = 12
	debug.timer = 0
	debug.delay = 0.5

	debug.a = "Player Rotation: "
	debug.b = "Player vx/vy:    "
	debug.c = "FPS:             "

	debug.f = "Enemy Rotation:  "
	debug.g = "Enemy vx/vy:     "
	debug.h = "Distance:        "


end


--      ==    ==    == ==       == ==          ==       == == ==    == == ==
--      ==    ==    ==    ==    ==    ==    ==    ==       ==       ==
--      ==    ==    == ==       ==    ==    == == ==       ==       == ==
--      ==    ==    ==          ==    ==    ==    ==       ==       ==
--      == == ==    ==          == ==       ==    ==       ==       == == ==

function love.update(dt)

	rotation(dt)

	if player.t == true then
		player.vx = player.vx + math.cos((player.rot))*player.tRate 
		player.vy = player.vy + math.sin((player.rot))*player.tRate
	else
		player.vx = player.vx * player.friction
		player.vy = player.vy * player.friction
	end

	player.x = player.x + player.vx*dt/10
	player.y = player.y + player.vy*dt/10

	player.deg = player.rot*180/math.pi

	-- bounce if beyond borders and ensure that it doesn't get into an infinate toggle
	if (player.x > width and player.vx > 0) 	or (player.x < 0 and player.vx < 0) then player.vx = -(player.vx)*reactionLoss end
	if (player.y > height and player.vy > 0)	or (player.y < 0 and player.vy < 0) then player.vy = -(player.vy)*reactionLoss end

	if (enemy.x > width and enemy.vx > 0) 	or (enemy.x < 0 and enemy.vx < 0) then enemy.vx = -(enemy.vx)*reactionLoss end
	if (enemy.y > height and enemy.vy > 0)	or (enemy.y < 0 and enemy.vy < 0) then enemy.vy = -(enemy.vy)*reactionLoss end


	debug.timer = debug.timer + dt
	if debug.timer > debug.delay then debug.timer = 0 end

	enemy.rot = math.atan2((player.y - enemy.y), (player.x - enemy.x))

	if getDistance(player.x, player.y, enemy.x, enemy.y) > enemy.range then  enemy.t = true
	else enemy.t = false end

	if enemy.t == true then
		enemy.vx = enemy.vx + math.cos((enemy.rot))*enemy.tRate
		enemy.vy = enemy.vy + math.sin((enemy.rot))*enemy.tRate
	else
		enemy.vx = enemy.vx * player.friction
		enemy.vy = enemy.vy * player.friction
	end

	enemy.x = enemy.x + enemy.vx*dt/10
	enemy.y = enemy.y + enemy.vy*dt/10

	for i, v in pairs(pBullets) do
		v["x"] = v["x"] + (v["dx"] * dt)
		v["y"] = v["y"] + (v["dy"] * dt)
	end




end


--     == ==       == ==          ==       ==    ==
--     ==    ==    ==    ==    ==    ==    ==    ==
--     ==    ==    == ==       == == ==    ==    ==
--     ==    ==    ==   ==     ==    ==    == == ==
--     == ==       ==   ==     ==    ==    ==    ==

function love.draw()


	love.graphics.setColor(255,255,255,255)

	for i, v in ipairs(pBullets) do
		love.graphics.circle("fill", v["x"], v["y"], 3)
	end

	drawDebug(debug.state)
	love.graphics.draw(player.sprite,	player.x,	player.y,	player.rot,	player.sx,	player.sy,	player.ox,	player.oy)
	if enemy.t == true then 	love.graphics.setColor(255,0,0,255) end
	love.graphics.draw(enemy.sprite,	enemy.x,	enemy.y,	enemy.rot,	enemy.sx,	enemy.sy,	enemy.ox,	enemy.oy)
end

function love.focus(bool)
end


--      == == ==    ==    ==    == ==       ==    ==    == == ==
--         ==       == == ==    ==    ==    ==    ==       ==
--         ==       == == ==    == ==       ==    ==       ==
--         ==       ==    ==    ==          ==    ==       ==
--      == == ==    ==    ==    ==          == == ==       ==

function love.keypressed(key, unicode)
	if playerAimType == 1 then
		if 		key == "d" 	then rotateRight = true
		elseif	key == "a" 	then rotateLeft = true 
		end
	end
	if key == "w" then player.t = true end
	if key == "p" then
		if debug.state == true then
			debug.state = false
		else
			debug.state = true
		end
	end

end

function love.keyreleased(key, unicode)
	if playerAimType == 1 then
		if		key == "d" then
			rotateRight = false
		end
		if 	key == "a" then
			rotateLeft = false
		end
	end
	if key == "w" then
		player.t = false
	end
end

function love.mousepressed(x, y, button)
	if button == "l" then
		local startX = player.x
		local startY = player.y
		local mouseX = x
		local mouseY = y

--		local angle = math.atan2((mouseY - startY), (mouseX - startX))
		local angle = player.rot

		local bulletDx = pBulletSpeed * math.cos(angle)
		local bulletDy = pBulletSpeed * math.sin(angle)

		table.insert(pBullets, {x = startX, y = startY, dx = bulletDx, dy = bulletDy})
	end
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


function rotation(dt)
	if player.rot >= 2*math.pi then
		player.rot = player.rot - 2*math.pi
	elseif player.rot < 0 then
		player.rot = player.rot + 2*math.pi
	end


	if playerAimType == 1 then
		if rotateLeft == true then
			player.rotDir = -1
		elseif rotateRight == true then
			player.rotDir = 1
		else
			player.rotDir = 0
		end
	end
	player.rot = player.rot + (player.rotSpd*player.rotDir*dt)

end

function drawDebug(bool)
	if bool == false then return; end

	if debug.timer == 0 then
		debug.a = "Player Rotation: " .. tostring(round(player.deg,2))
		debug.b = "Player vx/vy:    " .. tostring(round(player.vx,2)) .. " / " .. tostring(round(player.vy,2))
		debug.c = "FPS:             " .. tostring(love.timer.getFPS())
		debug.f = "Enemy Rotation:  " .. tostring(round(enemy.deg,2))
		debug.g = "Enemy vx/vy:     " .. tostring(round(enemy.vx,2)) .. " / " .. tostring(round(enemy.vy,2))
		debug.h = "Distance:        " .. tostring(getDistance(player.x, player.y, enemy.x, enemy.y))
	end

	love.graphics.print(debug.a,debug.x,debug.y + (debug.my*0))
	love.graphics.print(debug.b, debug.x + (debug.mx*0), debug.y + (debug.my*1))
	love.graphics.print(debug.c, debug.x + (debug.mx*0), debug.y + (debug.my*2))
	love.graphics.print(debug.f, debug.x + (debug.mx*1), debug.y + (debug.my*0))
	love.graphics.print(debug.g, debug.x + (debug.mx*1), debug.y + (debug.my*1))
	love.graphics.print(debug.h, debug.x + (debug.mx*1), debug.y + (debug.my*2))

end

-- rounds numbers to a precision of 0.00
function round(val,prec)
	return math.floor(val*math.pow(10,prec)+0.5)/math.pow(10,prec);
end

-- return the distance between two points
function getDistance(x1, y1, x2, y2)

	return math.sqrt( math.pow( math.abs( x1 - x2 ), 2) + math.pow(math.abs( y1 - y2),2) )

end
local player = ents.Inherit("baseMount")
local settings = {}

-- Player bullets
local bullets = {}
local bulletSpeed = 250

function player:setSize( w, h)
	self.w = w
	self.h = h
end

function player:getSize()
	return self.w, self.h;
end

function player:setSprite(sprite)
	if sprite then
		settings.sprite = love.graphics.newImage(ents.imgPath .. sprite)
	else
		print("Error: Sprite could not be loaded!")
		return false;
	end
end

function player:load(x, y)
	self:initPlayer(x, y)
	
	self:setMaxMountPoints(1)
	self:initMountPoints(x, y)
end

function player:initPlayer(x, y)
	-- initialize graphics
	self:initPlayerGraphics()
	-- set start width and height from the image, because of orientation issues the width is the height and viceversa
	self:setPos(x, y)
	self:setSize(settings.sprite:getHeight(), settings.sprite:getWidth())
	
	width = ents.window.width	-- get the window width
	height = ents.window.height -- get the window height
	
	-- initialize settings
	settings.rot, 	settings.rotSpd, 	settings.rotDec, 	settings.rotDir, 	settings.deg = 
	0, 				2, 					5, 					0, 					0

	--settings.rot 				= current player rotation
	--settings.rotSpd 			= speed at which the player rotates
	--settings.rotDec 			= the rotation decay					**unused**
	--settings.rotDir			= -1, 0, +1 for direction of rotation
	--settings.deg 				= container for degrees from rads
	
	settings.ox,	settings.oy,	settings.sx,	settings.sy,	settings.vx,	settings.vy = 
	15.5,			15.5,			1,				1,				0,				0

	--settings.ox, settings.oy 	= rotation offset of player
	--settings.sx, settings.sy	= scale of player
	--settings.vx, settings.vy	= player's current velocity
	
	settings.t, 	settings.tRate,	settings.spd,	settings.spdMax,	settings.friction = 
	false, 			15,				25,				0,					0.99

	--settings.t 				= toggle for state of player thrust
	--settings.tRate 			= accel/thrust rate
	--settings.spdMax			= max velocity of player
	--settings.spd 				= current player speed
	--settings.friction			= decay rate without thrust
	
	settings.rotateRight = false	-- current rotation state for key controls
	settings.rotateLeft = false		-- current rotation state for key controls

	settings.reactionLoss = 0.80 	-- how much velocity is lost in a collision
	
	--self.loadDebug()	-- load debug information
end

function player:initPlayerGraphics()
	self:setSprite("player.png")
end

function player:loadDebug()
	debug.x	=	5
	debug.mx = width/3
	debug.y	= 550
	debug.my = 12
	debug.timer = 0
	debug.delay = 0.5

	debug.a = "Player Rotation: "
	debug.b = "Player vx/vy:    "
	debug.c = "FPS:             "
end

function player:initMountPoints(x, y)
	-- initialize mountpoints for this entity relative to this entity
	mountPoints = {
		{id = -1,	x = self.w/2, 	y = 0}
	}
	
	--print("boxMount_initMountPoints: " .. mountPoints[1].id)
end

function player:update(dt)
	-- update the player entity
	self:updatePlayer(dt)
	
	-- update mountpoints
	self:updateMounts(dt)

	-- update debug info
	--if debug.state then
	--	debug.timer = debug.timer + dt
	--	if debug.timer > debug.delay then debug.timer = 0 end
	--end
end

function player:updatePlayer(dt)
	-- update player entity
	self:rotation(dt)

	if settings.t == true then
		settings.vx = settings.vx + math.cos((settings.rot))*settings.tRate 
		settings.vy = settings.vy + math.sin((settings.rot))*settings.tRate
	else
		settings.vx = settings.vx * settings.friction
		settings.vy = settings.vy * settings.friction
	end

	self.x = self.x + settings.vx*dt/10
	self.y = self.y + settings.vy*dt/10

	settings.deg = settings.rot*180/math.pi

	-- bounce if beyond borders and ensure that it doesn't get into an infinate toggle
	if (self.x > width and settings.vx > 0) 	or (self.x < 0 and settings.vx < 0) then settings.vx = -(settings.vx)*settings.reactionLoss end
	if (self.y > height and settings.vy > 0)	or (self.y < 0 and settings.vy < 0) then settings.vy = -(settings.vy)*settings.reactionLoss end

	-- update bullets
	for i, v in pairs(bullets) do
		v["x"] = v["x"] + (v["dx"] * dt)
		v["y"] = v["y"] + (v["dy"] * dt)
	end
end

function player:rotation(dt)
	if settings.rot >= 2*math.pi then
		settings.rot = settings.rot - 2*math.pi
	elseif settings.rot < 0 then
		settings.rot = settings.rot + 2*math.pi
	end

	if ents.playerAimType == 1 then
		if settings.rotateLeft == true then
			settings.rotDir = -1
		elseif settings.rotateRight == true then
			settings.rotDir = 1
		else
			settings.rotDir = 0
		end
	end
	settings.rot = settings.rot + (settings.rotSpd*settings.rotDir*dt)
end

function player:draw()
	love.graphics.setColor(255,255,255,255)

	-- draw player entity
	--print("player_draw:" .. self.x .. " " .. self.y .. " " .. settings.rot .. " " .. settings.sx .. " " .. settings.sy .. " " .. settings.ox .. " " .. settings.oy)
	love.graphics.draw(settings.sprite,	self.x,	self.y,	settings.rot,	settings.sx,	settings.sy,	settings.ox,	settings.oy)	

	-- draw bullets
	for i, v in ipairs(bullets) do
		love.graphics.circle("fill", v["x"], v["y"], 3)
	end
	
	-- temporary
	love.graphics.setColor(0,255,0,255)
	love.graphics.rectangle("fill",self.x,self.y,2,2)
	
	-- draw debug info
	--self:drawDebug(debug.state)	
end

function player:drawDebug(bool)
	if bool == false then return; end

	--print("player_drawDebug: debug.timer[" .. debug.timer .. "]")
	if debug.timer == 0 then
		debug.a = "Player Rotation: " .. tostring(ents:round(settings.deg,2))
		debug.b = "Player vx/vy:    " .. tostring(ents:round(settings.vx,2)) .. " / " .. tostring(ents:round(settings.vy,2))
		debug.c = "FPS:             " .. tostring(love.timer.getFPS())
	end

	print("debug.a:" ..debug.a)
	
	love.graphics.print(debug.a, debug.x,debug.y + (debug.my*0))
	love.graphics.print(debug.b, debug.x + (debug.mx*0), debug.y + (debug.my*1))
	love.graphics.print(debug.c, debug.x + (debug.mx*0), debug.y + (debug.my*2))
end

function player:keypressed(key, unicode)
	--print("player_keypressed: key[" .. key .. "] unicode[" .. unicode .. "] playerAimType[" .. ents.playerAimType .. "]")
	if ents.playerAimType == 1 then
		if 		key == "d" 	then 
			settings.rotateRight = true
		elseif	key == "a" 	then 
			settings.rotateLeft = true 
		end
	end
	if key == "w" then settings.t = true end
	if key == "p" then
		if debug.state == true then
			debug.state = false
		else
			debug.state = true
		end
	end
end

function player:keyreleased(key, unicode)
	--print("player_keyreleased: key[" .. key .. "] playerAimType[" .. ents.playerAimType .. "]")
	if ents.playerAimType == 1 then
		if		key == "d" then 
			settings.rotateRight = false
		elseif 	key == "a" then	
			settings.rotateLeft = false
		end
	end
	if key == "w" then settings.t = false end
end

function player:mousepressed(x, y, button)
	if button == "l" then
		local bulletDx = bulletSpeed * math.cos(settings.rot)
		local bulletDy = bulletSpeed * math.sin(settings.rot)

		table.insert(bullets, {x = self.x, y = self.y, dx = bulletDx, dy = bulletDy})
	end
end

return player;

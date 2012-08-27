local enemy = ents.Inherit("player")
local settings = {}
local enemyImages = { "enemy_01.png", "enemy_02.png", "enemy_03.png"}

local enemySize = { 64, 128, 512 }



settings.sprites = {}

-- Enemy bullets
local bullets = {}
local bulletSpeed = 250
local bulletDamage = 10

function enemy:setSprite(sprite)
	if sprite then
--		settings.sprite = love.graphics.newImage(ents.imgPath .. sprite)
		settings.sprite = settings.sprites[sprite]
	else
		print("Error: Sprite could not be loaded!")
		return false;
	end
end

function enemy:getBullets()
	return bullets;
end

--      ==          == == ==       ==       == ==
--      ==          ==    ==    ==    ==    ==    ==
--      ==          ==    ==    == == ==    ==    ==
--      ==          ==    ==    ==    ==    ==    ==
--      == == ==    == == ==    ==    ==    == ==    

function enemy:load(x, y)
	self:initEnemy(x, y)
	-- Enemy specific iniitialization settings
	settings.range = 250
end

function enemy:initEnemy(x, y)
	-- initialize graphics
	self:initEnemyGraphics()
	-- set start width and height from the image, because of orientation issues the width is the height and viceversa
	self:setPos(x, y)
	self:setSize(settings.sprite:getHeight(), settings.sprite:getWidth())
	
	-- Set maximum allowed health and initiate full health
	self.maxHealth = 100
	self.health = self.maxHealth
	
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
	
	-- Calculate collision distance
	self:setColDist(self:calcColDist(self.w, settings.sx))
	--self.loadDebug()	-- load debug information

	settings.transitioning = false

end

function enemy:initEnemyGraphics()
	--self:setSprite(enemyImages[1])
	for i =1, 3, 1 do
		settings.sprites[i] = love.graphics.newImage(ents.imgPath .. enemyImages[i])
	end
	if not gamePhase then gamePhase = 1 end
	settings.sprite = settings.sprites[gamePhase]
end

function enemy:loadDebug()
	debug.x	=	5
	debug.mx = width/3
	debug.y	= 550
	debug.my = 12
	debug.timer = 0
	debug.delay = 0.5

	debug.f = "Enemy Rotation:  "
	debug.g = "Enemy vx/vy:     "
	debug.h = "Distance:        "
end

--      ==    ==    == ==       == ==          ==       == == ==    == == ==
--      ==    ==    ==    ==    ==    ==    ==    ==       ==       ==
--      ==    ==    == ==       ==    ==    == == ==       ==       == ==
--      ==    ==    ==          ==    ==    ==    ==       ==       ==
--      == == ==    ==          == ==       ==    ==       ==       == == ==

function enemy:update(dt)
	-- update player entity
	self:rotation(dt)

	enemy:transition()

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
	local delBullets = {}
	for i, v in pairs(bullets) do
		-- update x, y coordinates
		v["x"] = v["x"] + (v["dx"] * dt)
		v["y"] = v["y"] + (v["dy"] * dt)
		-- check if out of bounds
		if v.x < 0 or v.x > width or v.y < 0 or v.y > height then
			table.insert(delBullets, i)
		end
	end
	-- remove any bullets out of bounds
	if #delBullets > 0 then
		for i,v in ipairs(delBullets) do
			table.remove(bullets, v)
		end
	end
	
	-- update enemy specific entity
	self:updateEnemy(dt)
	
	-- update mountpoints
	self:updateMounts(dt)

	-- Calculate collision distance
	self:setColDist(self:calcColDist(self.w, settings.sx))
	
	-- Check for collisions
	self:checkCollision()
	
	-- update debug info
	--if debug.state then
	--	debug.timer = debug.timer + dt
	--	if debug.timer > debug.delay then debug.timer = 0 end
	--end
end

function enemy:updateEnemy(dt)
	local player = {}
	player.Id = ents.playerEntityId
	player.x = ents.objects[player.Id].x
	player.y = ents.objects[player.Id].y
	
	--print("enemy_updateEnemy: player.x[" .. player.x .. "] player.y[" .. player.y .. "]")
	
	settings.rot = math.atan2((player.y - self.y), (player.x - self.x)) 

	if ents:getDistance(player.x, player.y, self.x, self.y) > settings.range then
		settings.t = true
	else 
		settings.t = false
	end

	--print("enemy_updateEnemy: settings.tRate[" .. settings.tRate .. "]")
	if settings.t == true then
		settings.vx = settings.vx + math.cos((settings.rot))*settings.tRate
		settings.vy = settings.vy + math.sin((settings.rot))*settings.tRate
	else
		settings.vx = settings.vx * settings.friction
		settings.vy = settings.vy * settings.friction
	end

	self.x = self.x + settings.vx*dt/10
	self.y = self.y + settings.vy*dt/10
end

function enemy:rotation(dt)
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

function enemy:shoot()
	local bulletDx = bulletSpeed * math.cos(settings.rot)
	local bulletDy = bulletSpeed * math.sin(settings.rot)

	table.insert(bullets, {x = self.x, y = self.y, dx = bulletDx, dy = bulletDy})
end 

--     == ==       == ==          ==       ==    ==
--     ==    ==    ==    ==    ==    ==    ==    ==
--     ==    ==    == ==       == == ==    ==    ==
--     ==    ==    ==   ==     ==    ==    == == ==
--     == ==       ==   ==     ==    ==    ==    ==

function enemy:draw()
	love.graphics.setColor(255,255,255,255)
	if settings.t == true then 	love.graphics.setColor(255,0,0,255) end
	-- draw player entity
	--print("enemy_draw:" .. self.x .. " " .. self.y .. " " .. settings.rot .. " " .. settings.sx .. " " .. settings.sy .. " " .. settings.ox .. " " .. settings.oy)
	love.graphics.draw(settings.sprite,	self.x,	self.y,	settings.rot,	settings.sx,	settings.sy,	settings.ox,	settings.oy)	

	-- draw bullets
	for i, v in ipairs(bullets) do
		love.graphics.circle("fill", v["x"], v["y"], 3)
	end
	
	-- temporary HP count
	love.graphics.setColor(255,0,0,255)
	love.graphics.print(self.health, self.x + 15, self.y)
	
	-- draw debug info
	--self:drawDebug(debug.state)	
end

--      == == ==    ==    ==    == ==       ==    ==    == == ==
--         ==       == == ==    ==    ==    ==    ==       ==
--         ==       == == ==    == ==       ==    ==       ==
--         ==       ==    ==    ==          ==    ==       ==
--      == == ==    ==    ==    ==          == == ==       ==

function enemy:keypressed(key, unicode)
end

function enemy:keyreleased(key, unicode)
end

function enemy:mousepressed(x, y, button)
	-- temporarily added to shoot with enemy
	if button == "r" then self:shoot() end
end

function enemy:transition()

	if not gamePhase then gamePhase = 1 end
	settings.sprite = settings.sprites[gamePhase]

	local scale = 64/enemySize[gamePhase]
	settings.ox = enemySize[gamePhase]/2
	settings.oy = enemySize[gamePhase]/2
	settings.sx = scale
	settings.sy = scale


end

return enemy;



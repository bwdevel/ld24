local enemy = ents.Inherit("player")
local settings = {}
local enemyImages = { "enemy_01.png", "enemy_02.png", "enemy_03.png"}

local enemySize = { 64, 128, 512 }

settings.sprites = {}

-- Enemy bullets
local bullets = {}
local bulletSpeed = 250
local bulletDamage = 5

-- Enemy fire
local fireStatus = false
local fireRate = 5
local fireCountDown = 5
local fireRange = 150

-- Enemy target
local target = 0
local targetRadius = 250
local range = 150

-- Experience
local experienceGain = 50
local experience = 0
local maxExperience = 100

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

function enemy:getFireRate()
	return fireRate;
end

function enemy:getFireCountDown()
	return fireCountDown;
end

function enemy:getTarget()
	return target;
end
function enemy:setTarget(entityId)
	if entityId then target = entityid end
end

function enemy:getTargetRadius()
	return targetRadius;
end
function enemy:setTargetRadius(value)
	targetRadius = value
end

function enemy:getFireCountDown()
	return fireCountDown;
end
function enemy:setFireCountDown(value)
	fireCountDown = value
end

function enemy:getExperienceGain()
	return experienceGain;
end

--      ==          == == ==       ==       == ==
--      ==          ==    ==    ==    ==    ==    ==
--      ==          ==    ==    == == ==    ==    ==
--      ==          ==    ==    ==    ==    ==    ==
--      == == ==    == == ==    ==    ==    == ==    

function enemy:load(x, y)
	self:initEnemy(x, y)
	-- Enemy specific iniitialization settings
	settings.range = 100 --MW-- deprecated moved to self.range
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
	
	-- Set fire rate of the enemy
	self.fireStatus = false
	self.fireRate = 10
	self.fireCountDown = self.fireRate
	self.fireRange = 150
	
	-- set Experience gain for killing this enemy
	self.experienceGain = 5
	self.experience = 0
	self.maxExperience = 100
	
	-- set target id
	self.target = 0
	self.targetRadius = 250
	self.range = 150
	
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

	settings.scaleMod = 1
	settings.sx = settings.sx * settings.scaleMod
	settings.sy = settings.sy * settings.scaleMod

end

function enemy:initEnemyGraphics()
	--self:setSprite(enemyImages[1])
	for i =1, 3, 1 do
		settings.sprites[i] = love.graphics.newImage(ents.imgPath .. enemyImages[i])
	end
	if not gamePhase then gamePhase = 1 end
	if gamePhase >=1 and gamePhase <= 3 then 
		settings.sprite = settings.sprites[gamePhase]
	end
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

	-- Start fireCountDown 
	if self.target then 
		if self.fireCountDown == 0 then
			-- shoot at player
			--self:shoot()
			-- reset countdown
			self.fireCountDown = self.fireRate
		else
			self.fireCountDown = self.fireCountDown - 1
		end
	end
	
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
	
	-- Aquire target
	self:aquireTarget()
	
	-- Actions against target if target aqcuired
	self:processActions()
	
	-- update debug info
	--if debug.state then
	--	debug.timer = debug.timer + dt
	--	if debug.timer > debug.delay then debug.timer = 0 end
	--end
end

function enemy:updateEnemy(dt)
	--MW--Deprecated by enemy:actionMove
	--local player = {}
	--player.Id = ents.playerEntityId
	--player.x = ents.objects[player.Id].x
	--player.y = ents.objects[player.Id].y
	--
	----print("enemy_updateEnemy: player.x[" .. player.x .. "] player.y[" .. player.y .. "]")
	--
	--settings.rot = math.atan2((player.y - self.y), (player.x - self.x)) 
	--
	--if ents:getDistance(player.x, player.y, self.x, self.y) > settings.range then
	--	settings.t = true
	--else 
	--	settings.t = false
	--end

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

function enemy:aquireTarget()
-- For now only target players if in range
	-- find player entity
	local player = {}
	player.id = ents.playerEntityId
	player.x = ents.objects[player.id].x
	player.y = ents.objects[player.id].y
	-- calculate distance and check range
	local entDist = ents:getDistance(player.x, player.y, self.x, self.y)
	if entDist <= self.targetRadius then
		self.target = player.id
	else
		self.target = 0
	end

--MW-- For future use
--	-- aquire a target to get into range and shoot at
--	for i, entity in pairs(ents.objects) do
--		if entity and entity.id ~= self.id  and entity.type == "player" then
--			-- Get position of entity
--			local x,y = entity.getPos()
--				
--			-- Check collisions between entities
--			-- Calculate distance between entities
--			local entDist = ents:getDistance(x, y, self.x, self.y)
--			-- Check if there is a possible target in range
--			if entDist <= self.targetRadius then
--				self.target = entity.id
--				--print("target aquired: [" .. self.id .. "] [" .. entity.id .. "]")
--			else
--				self.target = 0
--				--print("target lost: [" .. self.id .. "]")
--			end
--		end
--	end
--MW--
end

function enemy:processActions()
	self:actionMove()
	self:actionPullTrigger()
	self:actionShoot()
end

function enemy:actionMove()
	if self.target > 0 then
		local player = {}
		player.x = ents.objects[self.target].x
		player.y = ents.objects[self.target].y
		
		-- calculate heading towards target
		settings.rot = math.atan2((player.y - self.y), (player.x - self.x)) 
		-- start thrusters
		if ents:getDistance(player.x, player.y, self.x, self.y) > self.range then
			settings.t = true
		else
			settings.t = false
		end
	else 
		settings.t = false
	end
end

function enemy:actionPullTrigger()
	if self.target > 0 then
		local player = {}
		player.x = ents.objects[self.target].x
		player.y = ents.objects[self.target].y
		
		if ents:getDistance(player.x, player.y, self.x, self.y) <= self.fireRange then
			self.fireStatus = true
		else
			self.fireStatus = false
		end
	else
		self.fireStatus = false			
	end
end

function enemy:actionShoot()
	if self.fireStatus then
		-- Start shoot countdown
		if self.fireCountDown > 0 then
			-- Count down till shoot
			self.fireCountDown = self.fireCountDown - 1
		else
			-- Start shoot'in!
			self:shoot()
			-- reset countdown
			self.fireCountDown = self.fireRate
		end
	else
		-- reset countdown
		self.fireCountDown = self.fireRate
	end
end

function enemy:shoot()
	local bulletDx = bulletSpeed * math.cos(settings.rot)
	local bulletDy = bulletSpeed * math.sin(settings.rot)

	table.insert(bullets, {x = self.x, y = self.y, dx = bulletDx, dy = bulletDy, damage = bulletDamage})
end

--     == ==       == ==          ==       ==    ==
--     ==    ==    ==    ==    ==    ==    ==    ==
--     ==    ==    == ==       == == ==    ==    ==
--     ==    ==    ==   ==     ==    ==    == == ==
--     == ==       ==   ==     ==    ==    ==    ==

function enemy:draw()
	love.graphics.setColor(255,255,255,255)
	if settings.t == true then 	love.graphics.setColor(255,0,0,255) end

	-- draw bullets
	for i, v in ipairs(bullets) do
		love.graphics.circle("fill", v["x"], v["y"], 3)
	end
	
	-- draw player entity
	--print("enemy_draw:" .. self.x .. " " .. self.y .. " " .. settings.rot .. " " .. settings.sx .. " " .. settings.sy .. " " .. settings.ox .. " " .. settings.oy)
	love.graphics.draw(settings.sprite,	self.x,	self.y,	settings.rot,	settings.sx,	settings.sy,	settings.ox,	settings.oy)	
	
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
end

function enemy:transition()

	if not gamePhase then gamePhase = 1 end

	if gamePhase >= 1 and gamePhase <=3 then

		settings.sprite = settings.sprites[gamePhase]

		local scale = 64/enemySize[gamePhase]
		settings.ox = enemySize[gamePhase]/2
		settings.oy = enemySize[gamePhase]/2
		settings.sx = scale * settings.scaleMod
		settings.sy = scale * settings.scaleMod
	end

end

return enemy;



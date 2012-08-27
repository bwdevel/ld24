local player = ents.Inherit("baseMount")
local settings = {}
local playerImgs = { "player_03a", "player_03b", "player_03c", "player_03d", "player_03e", "player_03f", "player_03g","player_03h", "player_03i"}

settings.sprites= {}
--playerImgs[1] = "player_03a"
	
--}

-- Player bullets
local bullets = {}
local bulletSpeed = 250
local bulletDamage = 10

-- Experience
local experience = 0

-- Killed
local playerKilled = false

function player:setSize( w, h)
	self.w = w
	self.h = h
	-- Sizes has changed, change also the colDist
	if self.w and settings.sx then
		self:setColDist(self:calcColDist(self.w, settings.sx))
	end
end

function player:getSize()
	return self.w, self.h;
end

function player:setSprite(sprite)
	if sprite then
		settings.sprite = settings.sprites[sprite]
	else
		print("Error: Sprite could not be loaded!")
		return false;
	end
end

function player:getBullets()
	return bullets;
end

function player:getExperience()
	return experience;
end

function player:setExperience(value)
	experience = experience + value
end

--      ==          == == ==       ==       == ==
--      ==          ==    ==    ==    ==    ==    ==
--      ==          ==    ==    == == ==    ==    ==
--      ==          ==    ==    ==    ==    ==    ==
--      == == ==    == == ==    ==    ==    == ==    

function player:load(x, y)
	self:initPlayer(x, y)
	
	self:setMaxMountPoints(0)
	self:initMountPoints(x, y)
end

function player:initPlayer(x, y)
	-- initialize graphics
	self:initPlayerGraphics()
	-- set start width and height from the image, because of orientation issues the width is the height and viceversa
	self:setPos(x, y)
	self:setSize(settings.sprite:getHeight(), settings.sprite:getWidth())
	
	-- Set maximum allowed health and initiate full health	
	self.maxHealth = 200
	self.health = self.maxHealth
	self.playerKilled = false
	self.experience = 0
	
	width = ents.window.width	-- get the window width
	height = ents.window.height -- get the window height
	
	-- initialize settings
	settings.rot, 	settings.rotSpd, 	settings.rotDec, 	settings.rotDir, 	settings.deg = 
	0, 				2, 					5, 					0, 					0

	settings.guns = 1
	settings.engines = 1

	--settings.rot 				= current player rotation
	--settings.rotSpd 			= speed at which the player rotates
	--settings.rotDec 			= the rotation decay					**unused**
	--settings.rotDir			= -1, 0, +1 for direction of rotation
	--settings.deg 				= container for degrees from rads
	
	settings.ox,	settings.oy,	settings.sx,	settings.sy,	settings.vx,	settings.vy = 
	255.5,			255.5,			0.125,				0.125,				0,				0

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
end

function player:initPlayerGraphics()
	for i =1 , 9, 1 do
		settings.sprites[i] = love.graphics.newImage(ents.imgPath .. playerImgs[i] .. ".png")
	end

	settings.sprite = settings.sprites[1]

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
--	mountPoints = {
--		{id = -1,	x = 100, 	y = 1000}
--	}
	mountPoints = {

	}
	
end

--      ==    ==    == ==       == ==          ==       == == ==    == == ==
--      ==    ==    ==    ==    ==    ==    ==    ==       ==       ==
--      ==    ==    == ==       ==    ==    == == ==       ==       == ==
--      ==    ==    ==          ==    ==    ==    ==       ==       ==
--      == == ==    ==          == ==       ==    ==       ==       == == ==

function player:update(dt)
	-- Only update player if not killed
	if not self.playerKilled then
		-- update the player entity
		self:updatePlayer(dt)
	
		if settings.engines == 1 then
			self:setSprite(settings.guns)
		elseif settings.engines == 2 then
			self:setSprite(settings.guns+3)
		else
			self:setSprite(settings.guns+6)
		end
	
		
		-- update mountpoints
		--- limited use
		self:updateMounts(dt, self.x, self.y, settings.rot, settings.sx, settings.sy)
	
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

function player:shoot()
	local bulletDx = bulletSpeed * math.cos(settings.rot)
	local bulletDy = bulletSpeed * math.sin(settings.rot)

	table.insert(bullets, {x = self.x, y = self.y, dx = bulletDx, dy = bulletDy, damage = bulletDamage})
end 

function player:checkCollision()
	for i,entity in pairs(ents.objects) do
		if entity then
			if not entity.playerKilled then
				-- only check on enities other then ourself
				if entity.id ~= self.id then 
					-- Get position of entity
					local x,y = entity.getPos()
					
					-- Check collisions between entities
					-- Calculate distance between entities
					--print("checkCollision: [" .. x .. "] [" .. y .. "] [" .. self.x .. "] [" .. self.y .. "]")
					local entDist = ents:getDistance(x, y, self.x, self.y)
					-- Calculate combined collision distance
					local colDist = entity.getColDist() + self.getColDist()
					if entDist <= colDist then
						--print("Collision occured between: [" .. self.id .. "] [" .. entity.id .. "]")
					end
					
					-- Check collisions between bullets and entities
					for j, bullet in pairs(self:getBullets()) do
						-- Calculate distance between bullets and entities
						--print("checkCollision: [" .. x .. "] [" .. y .. "] [" .. self.x .. "] [" .. self.y .. "]")
						local entDist = ents:getDistance(x, y, bullet.x, bullet.y)
						-- Calculate combined collision distance
						local colDist = entity.getColDist()
						if entDist <= colDist then
							-- Damage entity
							local reward = entity:modifyHealth(bullet.damage, true)
							if (reward) then self:modifyExperience(entity.getExperienceGain()) end
							-- Remove bullet by setting coordinates out of bounds
							bullet.x = love.graphics.getWidth() * 3
							bullet.y = love.graphics.getHeight() * 3
							--print("Collision occured between: bullet-[" .. self.id .. "] [" .. entity.id .. "] [" .. bullet.damage .. "]")
						end		
					end
				end
			end			
		else
			print("Error: Invalid entity in global entity list!")
		end
	end
end

function player:modifyHealth(value, damage)
	-- Increase or decrease health and return if entity should be rewarded
	if damage then
		self.health = self.health - value
	else
		self.health = self.health + value
	end 
	
	-- Check health status
	if self.health > self.maxHealth then self.health = self.maxHealth end
	if self.health <= 0 then 
		-- entity dead!
		if self.type ~= "player" then
			ents.Destroy(self.id)
			return true;
		else
			-- Hide player if killed
			self.playerKilled = true
		end 
	end
	return false;
end

function player:modifyExperience(value, decrease)
	-- Increase or decrease experience
	if decrease then
		self.experience = self.experience - value
	else
		self.experience = self.experience + value
	end
end
	

--     == ==       == ==          ==       ==    ==
--     ==    ==    ==    ==    ==    ==    ==    ==
--     ==    ==    == ==       == == ==    ==    ==
--     ==    ==    ==   ==     ==    ==    == == ==
--     == ==       ==   ==     ==    ==    ==    ==

function player:draw()
	-- Only draw player if not killed
	if not self.playerKilled then	
		love.graphics.setColor(255,255,255,255)

		-- draw player entity
		--print("player_draw:" .. self.x .. " " .. self.y .. " " .. settings.rot .. " " .. settings.sx .. " " .. settings.sy .. " " .. settings.ox .. " " .. settings.oy)
		love.graphics.draw(settings.sprite,	self.x,	self.y,	settings.rot,	settings.sx,	settings.sy,	settings.ox,	settings.oy)	

		-- draw bullets
		for i, v in ipairs(bullets) do
			love.graphics.circle("fill", v["x"], v["y"], 3)
		end
	
		-- temporary HP count
		love.graphics.setColor(255,0,0,255)
		love.graphics.print(tostring(self.health), self.x + 15, self.y + 15)
		love.graphics.setColor(0, 255, 255, 255)
		love.graphics.print(tostring(self.experience), self.x - 40, self.y + 15)
	
		-- draw debug info
		--self:drawDebug(debug.state)
	end
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

--      == == ==    ==    ==    == ==       ==    ==    == == ==
--         ==       == == ==    ==    ==    ==    ==       ==
--         ==       == == ==    == ==       ==    ==       ==
--         ==       ==    ==    ==          ==    ==       ==
--      == == ==    ==    ==    ==          == == ==       ==

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
	if key == "1" then 
		print("Scale down" .. " " .. tostring(settings.sx))
		settings.sx = settings.sx - 0.10
		settings.sy = settings.sy - 0.10
	end
	if key == "2" then 
		print("Scale up" .. " " .. tostring(settings.sx))
		settings.sx = settings.sx + 0.10
		settings.sy = settings.sy + 0.10
	end
	if key == "3" then
		settings.guns = settings.guns + 1
		if settings.guns > 3 then settings.guns = 1 end
	end

	if key == "4" then
		settings.engines = settings.engines + 1
		if settings.engines > 3 then settings.engines = 1 end

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
	if button == "l" then self:shoot() end
end

return player;

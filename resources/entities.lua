-- initial settings
ents = {}								-- array that contains entities
ents.objects = {} 						-- table of objects
ents.objpath = "resources/entities/"	-- path for entities

ents.imgPath = "resources/images/"		-- path for image resources
ents.window = {}						-- information on current window
ents.window.width = love.graphics.getWidth()	-- get the window width
ents.window.height = love.graphics.getHeight()	-- get the window height
ents.playerAimType = 1 					-- 1 = keys, 2 = mouse aim, 3= mouse rotate
ents.playerEntityId = 0					-- Reference to player entity id

local register = {} 					-- register the templates for the entities
local id = 0							-- ID numbers for entities

-- Register all entities here
function ents.Startup()
	ents.Register("box")
	ents.Register("boxMount")
	ents.Register("mount")
	ents.Register("mount2")
	
	ents.Register("player")
	ents.Register("enemy")
end

function ents.Register( name )
	if name then
		register[ name ] = love.filesystem.load( ents.objpath .. name .. ".lua" )
	end
end

-- Search registered entities for a match
function ents.isRegisteredEntity(entityName)
    if register[entityName] then
    	return true
    end    
    return false
end

-- Entity inheritence
function ents.Inherit( name )
	if not name then
		print("Error: Cannot inherit entity without a name!")
		return false;
	end
	return love.filesystem.load( ents.objpath .. name .. ".lua" )()
end

function ents.Create( name, x, y)
	-- Basic checking of parameters
	if not name then
		print("Error: Cannot create entity without a name!")
		return false;
	end
	if not x then
		x = 0
	end
	if not y then
		y = 0
	end

	-- Create the entity
	if register[ name ] then 
		-- Only one player entity can exist	
		if name == "player" then
			if ents.playerEntityId ~= 0 then
				print("Error: Only one player entity allowed!")
				return false;
			end
		end
		id = id + 1
		local ent = register[ name ]()
		ent:load(x, y)
		ent.type = name
		ent.id = id
		ents.objects[ id] = ent -- add new entity
		
		-- set player entity reference id
		if name == "player" then
			ents.playerEntityId = id
		end
		
		return ents.objects[ id ] -- return new entity
	else
		print("Error: Entity " .. name .. " does not exist!")
		return false;
	end
end

-- Destroy entity
function ents.Destroy( id )
	if ents.objects[ id ] then
		if ents.objects[id].Die then
			ents.objects[id]:Die()
		end
		ents.objects[id] = nil
	else
		print("Error: Entity " .. id .. " cannot be destroyed!")
		return false;
	end
end

-- Update function inside entity
function ents:update( dt )
	for i, ent in pairs( ents.objects ) do
		if ent.update then
			ent:update( dt )
		end
	end
end

-- draw function inside entity
function ents:draw()
	for i, ent in pairs( ents.objects ) do
		if not ent.BG then
			if ent.draw then
				ent:draw()
			end
		end
	end
end

-- Keypressed event inside entity
function ents:keypressed(key, unicode)
	for i, ent in pairs( ents.objects ) do
		if ent.keypressed then
			ent:keypressed(key, unicode)
		end
	end
end

-- Keyreleased event inside entity
function ents:keyreleased(key, unicode)
	for i, ent in pairs( ents.objects ) do
		if ent.keyreleased then
			ent:keyreleased(key, unicode)
		end
	end
end

-- Mousepressed event insinde entity
function ents:mousepressed(x, y, button)
	for i, ent in pairs( ents.objects ) do
		if ent.mousepressed then
			ent:mousepressed(x, y, button)
		end
	end
end

-- rounds numbers to a precision of 0.00
function ents:round(val,prec)
	if not prec then prec = 2 end	
	if val and prec then
		return math.floor(val*math.pow(10,prec)+0.5)/math.pow(10,prec);
	end
end

-- return the distance between two points
function ents:getDistance(x1, y1, x2, y2)
	return math.sqrt( math.pow( math.abs( x1 - x2 ), 2) + math.pow(math.abs( y1 - y2),2) )
end


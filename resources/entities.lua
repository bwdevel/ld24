-- initial settings
ents = {}								-- array that contains entities
ents.objects = {} 						-- table of objects
ents.objpath = "resources/entities/"	-- path for entities
local register = {} 					-- register the templates for the entities
local id = 0							-- ID numbers for entities

-- Register all entities here
function ents.Startup()
	ents.Register("box")
	ents.Register("boxMount")
	ents.Register("mount")
	ents.Register("mount2")
end

function ents.Register( name )
	if name then
		register[ name ] = love.filesystem.load( ents.objpath .. name .. ".lua" )
	end
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
		id = id + 1
		local ent = register[ name ]()
		ent:load()
		ent.type = name
		ent:setPos( x, y)
		ent.id = id
		ents.objects[ id] = ent -- add new entity
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


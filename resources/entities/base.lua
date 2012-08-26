-- A very basic entity.
local base = {}
debug = {}
debug.state = false

base.x = 0
base.y = 0
base.health = 1

function base:setPos( x, y )
	base.x = x
	base.y = y
end

function base:getPos()
	return base.x, base.y;
end

-- in case a load function is forgotten, 
-- an empty load is run (error handling?)
function base:load()
end

return base;
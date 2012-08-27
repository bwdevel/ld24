-- A very basic entity.
local base = {}
debug = {}
debug.state = false

base.x = 0
base.y = 0
base.health = 1
base.colDist = 0

function base:setPos( x, y )
	base.x = x
	base.y = y
end

function base:getPos()
	return base.x, base.y;
end

function base:setColDist(distance)
	base.colDist = distance
end

function base:getColDist()
	return base.colDist
end

function base:setHealth(health)
	base.health = health
end

function base:getHealth()
	return base.health
end

function base:calcColDist(width, scaleX)
	return (width/2) * scaleX
end

-- in case a load function is forgotten, 
-- an empty load is run (error handling?)
function base:load()
end

return base;
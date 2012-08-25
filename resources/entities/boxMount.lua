local boxMount = ents.Inherit("box")
local mountPoints = {}
local maxMountPoints = 4

function boxMount:load( x, y )
	self:setPos(x,y)
	self.w = 64
	self.h = 64
	
	-- initialize mountpoints for this entity relative to this entity
	mountPoints = {
		{id = -1,	x = 0, 				y = 0},
		{id = -1,	x = self.w - 10, 	y = 0},
		{id = -1,	x = 0,				y = self.h - 10},
		{id = -1,	x = self.w - 10,	y = self.h - 10}
	}
end

function boxMount:update( dt )
	-- update self
	self.y = self.y + 32*dt
	
	-- update attached mounts
	for i,mount in pairs( mountPoints ) do
		if mount and mount.id ~= -1 then
			--print("update: " .. mount.id)
			entity = ents.objects[mount.id]
			if entity then
				--print("haz object")
				entity:setPos(mount.x + self.x, mount.y + self.y)
			else
				print("Error: Cannot update mountId[" .. i .. "] no entity[" .. mount.id .. "] found!")
			end
		end
	end
end

function boxMount:addMount(entityName, place)
	--print("boxMount_addMount[" .. entityName .. "][" .. place .. "]")
	
	-- Basic checking of parameters
	if not entityName then
		print("Error: Cannot mount nameless entity!")
		return false;
	end
	if place < 1 or place > maxMountPoints then
		place = 1
	end
	
	-- Check if mountpoint is already in use
	if mountPoints[place].id ~= -1 then
		print("Error: Mountpoint already used!")
		return false;
	end
	
	--print("  Mountpoint[" .. place .. "] id:" .. mountPoints[place].id)
	
	-- Occupy mountpoint
	local mountBox = ents.Create(entityName, mountPoints[place].x + self.x, mountPoints[place].y + self.y)
	mountPoints[place].id = mountBox.id
end

function boxMount:delMount(mountId)
	--print("boxMount_delMount[" .. mountId .. "]")
	if not mountId then
		print("Error: Cannot delete mountpoint " .. mountId .. " - Entity id: " .. mountPoints[mountId].id)
		return false;
	else
		--print("  Destroy mount[" .. mountId .. "]")
		ents.Destroy(mountPoints[mountId].id)
		mountPoints[mountId].id = -1
	end
	
end

return boxMount;

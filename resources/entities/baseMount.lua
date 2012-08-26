local baseMount = ents.Inherit("base")
local maxMountPoints = 1
mountPoints = {}

function baseMount:getMaxMountPoints()
	return maxMountPoints;
end

function baseMount:setMaxMountPoints(maxMounts)
	maxMountPoints = maxMounts
end

function baseMount:load( x, y )
	self:setPos(x,y)	
	self:setMaxMountPoints(1)
	self:initMountPoints(x, y)
end

function baseMount:initMountPoints(x, y)
	-- initialize mountpoints for this entity relative to this entity
	mountPoints = {
		{id = -1,	x = 0, 	y = 0}
	}
end

function baseMount:updateMounts( dt )
	-- update attached mounts
	for i,mount in pairs( mountPoints ) do
		if mount and mount.id ~= -1 then
			--print("update: " .. mount.id)
			entity = ents.objects[mount.id]
			if entity then
				entity:setPos(mount.x + self.x, mount.y + self.y)
			else
				print("Error: Cannot update mountId[" .. i .. "] no entity[" .. mount.id .. "] found!")
			end
		end
	end
end

function baseMount:addMount(entityName, mountPos)
	--print("boxMount_addMount[" .. entityName .. "][" .. mountPos .. "]")
	
	-- Basic checking of parameters
	if not entityName then
		print("Error: Cannot mount nameless entity!")
		return false;
	end
	if mountPos < 1 or mountPos > maxMountPoints then
		mountPos = 1
	end
	
	--print("  Mountpoint[" .. mountPos .. "] id:" .. mountPoints[mountPos].id)
	
	-- Check if mountpoint is already in use
	if mountPoints[mountPos].id ~= -1 then
		print("Error: Mountpoint [" .. mountPos .. "] already used!")
		return false;
	end
	
	--print("  Mountpoint[" .. mountPos .. "] id:" .. mountPoints[mountPos].id)
	
	-- Occupy mountpoint
	local mountBox = ents.Create(entityName, mountPoints[mountPos].x + self.x, mountPoints[mountPos].y + self.y)
	mountPoints[mountPos].id = mountBox.id
end

function baseMount:delMount(mountId)
	--print("boxMount_delMount[" .. mountId .. "]")
	if mountId < 1 or mountId > maxMountPoints then
		print("Error: Cannot delete mountpoint ["  .. mountId .. "] it does not exist!")
		return false;
	else
		--print("  Destroy mount[" .. mountId .. "]")
		ents.Destroy(mountPoints[mountId].id)
		mountPoints[mountId].id = -1
	end	
end

return baseMount;

local boxMount = ents.Inherit("baseMount")

function boxMount:load( x, y )
	self:setPos(x,y)
	self.w = 64
	self.h = 64
	
	self:setMaxMountPoints(4)
	self:initMountPoints(x, y)
end

function boxMount:initMountPoints(x, y)
	-- initialize mountpoints for this entity relative to this entity
	mountPoints = {
		{id = -1,	x = 0, 				y = 0},
		{id = -1,	x = self.w - 10, 	y = 0},
		{id = -1,	x = 0,				y = self.h - 10},
		{id = -1,	x = self.w - 10,	y = self.h - 10}
	}
	
	--print("boxMount_initMountPoints: " .. mountPoints[1].id)
end

function boxMount:setSize(w, h)
	self.w = w
	self.h = h
end

function boxMount:getSize()
	return self.w, self.h;
end

function boxMount:update( dt )
	self.y = self.y + 32*dt
	-- update mountpoints
	self:updateMounts(dt)
end

function boxMount:draw()

	local x, y = self:getPos()
	local w, h = self:getSize()

	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.rectangle( "fill", x, y , w , h )
end

return boxMount;

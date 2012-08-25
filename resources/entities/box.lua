local ent = ents.Inherit("base")

function ent:load( x, y )
	self:setPos(x,y)
	self.w = 64
	self.h = 64
end

function ent:setSize( w, h)
	self.w = w
	self.h = h
end

function ent:getSize()
	return self.w, self.h;
end

function ent:update( dt )
	self.y = self.y + 32*dt
end

function ent:draw()
	local x, y = self:getPos()
	local w, h = self:getSize()

	love.graphics.setColor( 0, 0, 0, 255 )
	love.graphics.rectangle( "fill", x, y , w , h )
end

return ent;
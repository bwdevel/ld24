local ent = ents.Inherit("base")

function ent:load( x, y )
	self:setPos(x,y)
	self.w = 10
	self.h = 10
	self.dox = 127.5
	self.doy = 32.5
	self.ox = 127.5
	self.oy = 32.5
	self.sx = 1
	self.sy = 1
	self.dsx = 1
	self.dsy = 1

	self.rot = 0
	self.image = love.graphics.newImage("images/gun_02.png")
end

function ent:setSize( w, h)
	self.w = w
	self.h = h
end

function ent:getSize()
	return self.w, self.h;
end

function ent:update( dt )
	--self.y = self.y + 32*dt
end

function ent:draw()

	local x, y = self:getPos()
	local w, h = self:getSize()

		
	
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.draw(self.image,x,y,self.rot, self.sx, self.sy, self.ox*self.sy, self.oy*self.sy)
--	love.graphics.rectangle( "fill", x, y , w , h )
end

return ent;

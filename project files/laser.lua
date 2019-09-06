local Laser = {}
local lg = love.graphics

function Laser:create(data)
	local laser = {}
	laser.type = data.type or "playerlaser"	-- used for collision management
	laser.body = {
		shape = "rect",
		x = data.x/2 + SCREEN.width/2,
		y = data.y,
		-- orig size: 20x20
		sizeX = SCREEN.width - data.x,
		sizeY = SCREEN.height * 0.01,
	}
	laser.timer = 0.15
	
	function laser:tick(dt)
		self.timer = self.timer - dt
		if self.timer <= 0 then
			self:destroy()
		end
	end
	
	
	function laser:getPosition()
		return { x = self.body.x, y = self.body.y }
	end
	
	function laser:getBody()
		return self.body
	end
	
	function laser:draw()
		lg.setColor(255, 20, 20, 120)
		lg.rectangle("fill", self.body.x - self.body.sizeX/2, self.body.y - self.body.sizeY/2, self.body.sizeX, self.body.sizeY)
		lg.setColor(255, 255, 255, 255)
	end
	
	
	function laser:destroy()
		
		gameloop:remove(self)
		renderer:remove(self)
		entman:remove(self)
		self = nil
	end
	
	
	gameloop:add(laser)
	renderer:add(laser, LAYER_BULLETS)
	entman:add(laser)
	
	return laser
end

return Laser

local Bullet = {}
local lg = love.graphics

function Bullet:create(data)
	local bullet = {}
	bullet.type = data.type or "playerbullet"	-- used for collision management
	bullet.body = {
		shape = "rect",
		x = data.x,
		y = data.y,
		-- orig size: 20x20
		sizeX = data.sizeX or 20,
		sizeY = data.sizeY or 20,
		velocity = { x = data.velocity.x or 0, y = data.velocity.y or 0 },
	}
	bullet.followPlayerSpeed = data.followPlayerSpeed	-- enemy bullets might follow the player
	
	
	function bullet:tick(dt)
		
		-- bullets can slightly adjust their trajectory in relation to the player's current position
		if self.followPlayerSpeed then
			if self.body.y < player:getBody().y then
				-- bullet is above the player
				self.body.velocity.y = self.body.velocity.y + self.followPlayerSpeed * METER * dt
				
			elseif self.body.y > player:getBody().y then
				-- bullet is below the player
				self.body.velocity.y = self.body.velocity.y - self.followPlayerSpeed * METER * dt
				
			end
		end
		
		self.body.x = self.body.x + self.body.velocity.x * dt
		self.body.y = self.body.y + self.body.velocity.y * dt
		
		-- borders (remove the entity)
		local extra = 0	-- margin around the screen rect (experimental value, probably not even needed!)
		if self.body.x < 0 - extra
		or self.body.x > SCREEN.width + extra
		or self.body.y < 0 - extra
		or self.body.y > SCREEN.height + extra then
			self:destroy()
		end
		
	end
	
	
	function bullet:getPosition()
		return { x = self.body.x, y = self.body.y }
	end
	
	function bullet:getBody()
		return self.body
	end
	
	function bullet:draw()
		lg.rectangle("fill", self.body.x - self.body.sizeX/2, self.body.y - self.body.sizeY/2, self.body.sizeX, self.body.sizeY)
	end
	
	
	function bullet:destroy()
		
		
		--print("destroy bullet")
		gameloop:remove(self)
		renderer:remove(self)
		entman:remove(self)
		self = nil
	end
	
	
	gameloop:add(bullet)
	renderer:add(bullet, LAYER_BULLETS)
	entman:add(bullet)
	
	return bullet
end

return Bullet

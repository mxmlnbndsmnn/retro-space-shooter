local Meteorite = {}
local lg = love.graphics

local testimg = lg.newImage("images/testparticle.png")

function Meteorite:create(data)
	local meteorite = {}
	meteorite.type = "meteorite"	-- used for collision management
	meteorite.body = {
		shape = "circle",
		x = data.x,
		y = data.y,
		radius = data.radius or data.size or SCREEN.height * 0.04,
		velocity = { x = data.velocity.x or 0, y = data.velocity.y or 0 },
	}
	meteorite.hitsPlayer = true	-- on direct collision
	meteorite.hitpoints = 1
	
	function meteorite:tick(dt)
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
	
	
	function meteorite:draw()
		lg.setColor(180, 180, 180, 255)
		lg.circle("fill", self.body.x, self.body.y, self.body.radius)
		lg.setColor(255, 255, 255, 255)
	end
	
	
	function meteorite:getPosition()
		return { x = self.body.x, y = self.body.y }
	end
	
	function meteorite:getBody()
		return self.body
	end
	
	
	function meteorite:hurt()
		if self.hitpoints > 1 then
			self.hitpoints = self.hitpoints - 1
			
			entman:onPlayerBulletHit()
			
		else
			entman:onEnemyDestroyed()
			self:destroy(true, 1)
		end
	end
	
	
	function meteorite:destroy(_drawPS, _score)
		if _drawPS then
			local ps = {}
			ps.system = love.graphics.newParticleSystem(testimg, 32)
			ps.system:setParticleLifetime(0.75, 1.5)		-- particles live at least (min)s and at most (max)s.
			ps.system:setEmissionRate(8)					-- number of particles emitted per second
			ps.system:setSizeVariation(1)					-- the amount of variation (0 meaning no variation and 1 meaning full variation between start and end)
			ps.system:setEmitterLifetime(0.7)				-- sets how long the particle system should emit particles (if -1 then it emits particles forever)
			-- newly created particles will spawn in an area around the emitter based on the parameters to this function
			-- note: in newer versions (11+) use ParticleSystem:setEmissionArea
			ps.system:setAreaSpread("uniform", self.body.radius, self.body.radius)
			ps.system:setLinearAcceleration(-20, -20, 20, 20)			-- random movement in all directions
			ps.system:setColors(106, 0, 128, 255, 106, 0, 128, 0)		-- fade to transparency
			ps.system:setSizes(0.2, 0.4, 0.5)							-- particles can have different sizes (specify at least one)
			ps.pos = { x = self.body.x, y = self.body.y }
			
			partman:add(ps)
		end
		
		lvlman:enemydestroyed(_score or 0)
		
		gameloop:remove(self)
		renderer:remove(self)
		entman:remove(self)
		self = nil
	end
	
	
	gameloop:add(meteorite)
	renderer:add(meteorite, LAYER_ENEMIES)
	entman:add(meteorite)
	
	return meteorite
end

return Meteorite

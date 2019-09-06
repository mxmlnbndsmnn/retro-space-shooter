local Enemy = {}
local lg = love.graphics
local random = love.math.random

local testimg = lg.newImage("images/testparticle.png")
local imageShip = lg.newImage("images/enemy_ship_1.png")

-- note: enemy should have multiple types of movement to "select" from initially
--> fly straight to the left / move up and down only but not horizontal / move both to the left and up and down

function Enemy:create(data)
	local enemy = {}
	enemy.type = data.type or "enemy"	-- used for collision management
	enemy.body = {
		shape = "rect",
		x = data.x,
		y = data.y,
		sizeX = data.sizeX or SCREEN.width * 0.05,
		sizeY = data.sizeY or SCREEN.height * 0.06,
		velocity = { x = data.velocity.x or 0, y = data.velocity.y or 0 },
	}
	enemy.attackWait = 3
	enemy.fireTick = 0
	enemy.hitpoints = 2
	
	-- movement types:
	--> normal = fly straight to the left
	--> stay_right = only briefly move right, then move up and down only
	enemy.movementType = data.movementType or "normal"
	
	
	-- image
	-- note: the image is a little bit larger than the hitbox
	enemy.imgScaleX = 1.2 * enemy.body.sizeX / imageShip:getWidth()
	enemy.imgScaleY = 1.2 * enemy.body.sizeY / imageShip:getHeight()
	
	enemy.imgOffsetX = enemy.body.sizeX * 0.6 / enemy.imgScaleX
	enemy.imgOffsetY = enemy.body.sizeY * 0.6 / enemy.imgScaleY
	
	
	function enemy:tick(dt)
		
		if self.movementType == "stay_right" then
			if self.body.x < SCREEN.width * 0.85 then
				self.body.velocity.x = 0
			end
			
		end
		
		if self.movementType == "stay_right" then
			if self.body.velocity.y > 0 then	--> moving down
				if self.body.y >= SCREEN.height * 0.58 then
					self.body.velocity.y = -random(3,6) * METER
				end
			else	--> moving up (or not at all)
				if self.body.y <= SCREEN.height * 0.12 then
					self.body.velocity.y = random(3,6) * METER
				end
			end
			
		elseif self.movementType == "stray" then
			if self.body.velocity.y > 0 then	--> moving down
				if self.body.y >= SCREEN.height * 0.58 then
					self.body.velocity.y = -6 * METER
				end
			else	--> moving up (or not at all)
				if self.body.y <= SCREEN.height * 0.12 then
					self.body.velocity.y = 6 * METER
				end
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
		
		self.fireTick = self.fireTick + dt
		if self.fireTick >= self.attackWait then
			self:shoot()
		end
		
	end
	
	
	function enemy:shoot()
		bullet:create( { x = self.body.x, y = self.body.y, sizeX = SCREEN.width/80, sizeY = SCREEN.height/80, velocity = { x = -35 * METER, y = 0 }, type = "enemybullet" } )
		self.fireTick = self.fireTick - self.attackWait + random()	-- testing...
		
		-- play a sound
		soundmgr:playSound("shoot1")
	end
	
	
	function enemy:getPosition()
		return { x = self.body.x, y = self.body.y }
	end
	
	
	function enemy:getBody()
		return self.body
	end
	
	
	function enemy:draw()
		--lg.setColor(255, 55, 55, 255)
		--lg.rectangle("fill", self.body.x - self.body.sizeX/2, self.body.y - self.body.sizeY/2, self.body.sizeX, self.body.sizeY)
		--lg.setColor(255, 255, 255, 255)
		--lg.rectangle("line", self.body.x - self.body.sizeX/2, self.body.y - self.body.sizeY/2, self.body.sizeX, self.body.sizeY)
		
		local body = self.body
		lg.draw(imageShip, body.x, body.y, 0, self.imgScaleX, self.imgScaleY, self.imgOffsetX, self.imgOffsetY)
	end
	
	
	function enemy:hurt()
		if self.hitpoints > 1 then
			self.hitpoints = self.hitpoints - 1
			
			local ps = {}
			ps.system = love.graphics.newParticleSystem(testimg, 32)
			ps.system:setParticleLifetime(0.75, 1.5)		-- particles live at least (min)s and at most (max)s.
			ps.system:setEmissionRate(8)					-- number of particles emitted per second
			ps.system:setSizeVariation(1)					-- the amount of variation (0 meaning no variation and 1 meaning full variation between start and end)
			ps.system:setEmitterLifetime(0.7)				-- sets how long the particle system should emit particles (if -1 then it emits particles forever)
			-- newly created particles will spawn in an area around the emitter based on the parameters to this function
			-- note: in newer versions (11+) use ParticleSystem:setEmissionArea
			ps.system:setAreaSpread("uniform", self.body.sizeX/2, self.body.sizeY/2)
			ps.system:setLinearAcceleration(-20, -20, 20, 20)			-- random movement in all directions
			ps.system:setColors(255, 255, 255, 255, 255, 255, 255, 0)	-- fade to transparency
			ps.system:setSizes(0.2, 0.4, 0.5)							-- particles can have different sizes (specify at least one)
			ps.pos = { x = self.body.x, y = self.body.y }
			
			partman:add(ps)
			
			entman:onPlayerBulletHit()
			
		else
			--SCORE = SCORE + 1
			entman:onEnemyDestroyed()
			self:destroy(true)
		end
	end
	
	
	function enemy:destroy(_drawPS)
		if _drawPS then
			local ps = {}
			ps.system = love.graphics.newParticleSystem(testimg, 32)
			ps.system:setParticleLifetime(0.75, 1.5)		-- particles live at least (min)s and at most (max)s.
			ps.system:setEmissionRate(8)					-- number of particles emitted per second
			ps.system:setSizeVariation(1)					-- the amount of variation (0 meaning no variation and 1 meaning full variation between start and end)
			ps.system:setEmitterLifetime(0.7)				-- sets how long the particle system should emit particles (if -1 then it emits particles forever)
			-- newly created particles will spawn in an area around the emitter based on the parameters to this function
			-- note: in newer versions (11+) use ParticleSystem:setEmissionArea
			ps.system:setAreaSpread("uniform", self.body.sizeX/2, self.body.sizeY/2)
			ps.system:setLinearAcceleration(-20, -20, 20, 20)			-- random movement in all directions
			ps.system:setColors(186, 40, 28, 255, 186, 40, 28, 0)	-- fade to transparency
			ps.system:setSizes(0.2, 0.4, 0.5)							-- particles can have different sizes (specify at least one)
			ps.pos = { x = self.body.x, y = self.body.y }
			
			partman:add(ps)
		end
		
		lvlman:enemydestroyed()
		
		gameloop:remove(self)
		renderer:remove(self)
		entman:remove(self)
		self = nil
	end
	
	
	gameloop:add(enemy)
	renderer:add(enemy, LAYER_ENEMIES)
	entman:add(enemy)
	
	return enemy
end

return Enemy

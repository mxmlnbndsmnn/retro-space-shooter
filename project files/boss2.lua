local Boss = {}
local lg = love.graphics
local random = love.math.random

local testimg = lg.newImage("images/testparticle.png")
local imageShip = lg.newImage("images/boss_ship_2.png")

local bulletVelocity = 34

-- second miniboss enemy
--> has a shield that activates every few seconds and lasts a few seconds

function Boss:create(data)
	local boss = {}
	boss.type = "enemy"
	boss.body = {
		shape = "rect",
		x = data.x,
		y = data.y,
		sizeX = SCREEN.width * 0.075,
		sizeY = SCREEN.height * 0.1,
		velocity = { x = -8 * METER, y = tools.getRandomFromTable( { -5, -4, 4, 5} ) * METER },
	}
	boss.attackWait = 1.5
	boss.fireTick = 0
	boss.hitpoints = 15
	
	boss.shieldTick = 0
	boss.shieldDuration = 2
	boss.shieldRefresh = 3
	boss.shieldActive = false
	
	boss.credit = 10	-- SCORE rewarded when defeated
	--> careful: score needed to reach the next set of spawn chances!
	
	
	-- image
	-- note: the image is a little bit larger than the hitbox
	boss.imgScaleX = 1.2 * boss.body.sizeX / imageShip:getWidth()
	boss.imgScaleY = 1.2 * boss.body.sizeY / imageShip:getHeight()
	
	boss.imgOffsetX = boss.body.sizeX * 0.6 / boss.imgScaleX
	boss.imgOffsetY = boss.body.sizeY * 0.6 / boss.imgScaleY
	
	
	function boss:tick(dt)
		if self.body.x < SCREEN.width * 0.8 then
			self.body.velocity.x = 0
		else
			self.body.x = self.body.x + self.body.velocity.x * dt
			-- no y movement here...
		end
		
		-- move up and down
		if self.body.velocity.y > 0 then	--> moving down
			if self.body.y >= SCREEN.height * 0.58 then
				self.body.velocity.y = -random(3, 5) * METER
			end
		else	--> moving up (or not at all)
			if self.body.y <= SCREEN.height * 0.12 then
				self.body.velocity.y = random(3, 5) * METER
			end
		end
		self.body.y = self.body.y + self.body.velocity.y * dt
		
		self.fireTick = self.fireTick + dt
		if self.fireTick >= self.attackWait then
			self:shoot()
		end
		
		-- manage the shield
		self.shieldTick = self.shieldTick + dt
		
		if self.shieldActive then
			if self.shieldTick >= self.shieldDuration then
				self.shieldActive = false
				self.shieldTick = self.shieldTick - self.shieldDuration
			end
		else
			if self.shieldTick >= self.shieldRefresh then
				self.shieldActive = true
				self.shieldTick = self.shieldTick - self.shieldRefresh
			end
		end
		
	end
	
	
	function boss:shoot()
		--local vec2 = tools.setVectorLength( { x = -50 , y = 0 } , 25 * METER)
		
		-- followPlayerSpeed (if specified) enables the bullet to target the player by adjusting the y velocity by that amount (*METER) per tick
		bullet:create( { x = self.body.x - self.body.sizeX * 0.5, y = self.body.y, sizeX = SCREEN.width/80, sizeY = SCREEN.height/80, velocity = { x = -bulletVelocity * METER, y = 0 }, type = "enemybullet", followPlayerSpeed = 2 } )
		self.fireTick = self.fireTick - self.attackWait + random()	-- testing...
		
		-- play a sound
		soundmgr:playSound("shoot1")
	end
	
	
	function boss:getPosition()
		return { x = self.body.x, y = self.body.y }
	end
	
	
	function boss:getBody()
		return self.body
	end
	
	
	function boss:draw()
		--lg.setColor(155, 155, 255, 255)
		--lg.rectangle("fill", self.body.x - self.body.sizeX/2, self.body.y - self.body.sizeY/2, self.body.sizeX, self.body.sizeY)
		--lg.setColor(255, 255, 255, 255)
		--lg.rectangle("line", self.body.x - self.body.sizeX/2, self.body.y - self.body.sizeY/2, self.body.sizeX, self.body.sizeY)
		
		local body = self.body
		lg.draw(imageShip, body.x, body.y, 0, self.imgScaleX, self.imgScaleY, self.imgOffsetX, self.imgOffsetY)
		
		if self.shieldActive then
			lg.setLineWidth(4)
			lg.circle("line", self.body.x, self.body.y, tools.max(self.body.sizeX, self.body.sizeY) * 0.8)
		end
		lg.setLineWidth(1)
	end
	
	
	function boss:hurt()
		
		-- shield can absorb any incomming damage
		if self.shieldActive then
			return
		end
		
		if self.hitpoints > 1 then
			self.hitpoints = self.hitpoints - 1
			
			local ps = {}
			ps.system = love.graphics.newParticleSystem(testimg, 32)
			ps.system:setParticleLifetime(1.5, 2.0)			-- particles live at least (min)s and at most (max)s.
			ps.system:setEmissionRate(8)					-- number of particles emitted per second
			ps.system:setSizeVariation(1)					-- the amount of variation (0 meaning no variation and 1 meaning full variation between start and end)
			ps.system:setEmitterLifetime(1.4)				-- sets how long the particle system should emit particles (if -1 then it emits particles forever)
			-- newly created particles will spawn in an area around the emitter based on the parameters to this function
			-- note: in newer versions (11+) use ParticleSystem:setEmissionArea
			ps.system:setAreaSpread("uniform", self.body.sizeX/2, self.body.sizeY/2)
			ps.system:setLinearAcceleration(-20, -20, 20, 20)			-- random movement in all directions
			ps.system:setColors(255, 255, 255, 255, 255, 255, 255, 0)	-- fade to transparency
			ps.system:setSizes(0.2, 0.4, 0.5, 0.8)						-- particles can have different sizes (specify at least one)
			ps.pos = { x = self.body.x, y = self.body.y }
			
			partman:add(ps)
			
			entman:onPlayerBulletHit()
			
		else
			--SCORE = SCORE + 1
			entman:onEnemyDestroyed()
			self:destroy(true)
		end
	end
	
	
	function boss:destroy(_drawPS)
		if _drawPS then
			local ps = {}
			ps.system = love.graphics.newParticleSystem(testimg, 32)
			ps.system:setParticleLifetime(1.8, 2.8)			-- particles live at least (min)s and at most (max)s.
			ps.system:setEmissionRate(8)					-- number of particles emitted per second
			ps.system:setSizeVariation(1)					-- the amount of variation (0 meaning no variation and 1 meaning full variation between start and end)
			ps.system:setEmitterLifetime(1.4)				-- sets how long the particle system should emit particles (if -1 then it emits particles forever)
			-- newly created particles will spawn in an area around the emitter based on the parameters to this function
			-- note: in newer versions (11+) use ParticleSystem:setEmissionArea
			ps.system:setAreaSpread("uniform", self.body.sizeX/2, self.body.sizeY/2)
			ps.system:setLinearAcceleration(-20, -20, 20, 20)			-- random movement in all directions
			ps.system:setColors(186, 40, 28, 255, 186, 40, 28, 0)		-- fade to transparency
			ps.system:setSizes(0.2, 0.4, 0.5, 0.8)						-- particles can have different sizes (specify at least one)
			ps.pos = { x = self.body.x, y = self.body.y }
			
			partman:add(ps)
		end
		
		--> tell the level manager how many points the player should be rewarded for defeating this boss
		lvlman:bossdestroyed(self.credit)
		
		gameloop:remove(self)
		renderer:remove(self)
		entman:remove(self)
		self = nil
	end
	
	
	gameloop:add(boss)
	renderer:add(boss, LAYER_ENEMIES)
	entman:add(boss)
	
	return boss
end

return Boss

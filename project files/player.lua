local Player = {}

local lg = love.graphics
local testimg = lg.newImage("images/testparticle.png")
local imageShip = lg.newImage("images/player_ship_1.png")
local pAttackWait = 0.4

function Player:create()
	local player = {}
	
	-- init
	player.type = "player"	-- used for collision management
	player.body = {
		x = SCREEN.width / 18,
		y = SCREEN.height * 0.3,
		shape = "rect",
		--> note: size is also modified in player:resetSize
		sizeX = SCREEN.width * 0.045,
		sizeY = SCREEN.height * 0.07,
		velocity = { x = 0, y = 0 },
	}
	player.speed = 17 * METER	--> note: size is also modified in player:resetSize
	player.attackWait = pAttackWait
	player.lastHurtTimer = 0
	
	--print("player size: ", player.body.sizeX, player.body.sizeY)
	
	-- weapon energy
	player.maxEnergy = 100
	player.energy = 100				-- reduces when shooting
	player.energyPerShoot = 5		-- can be changed with powerups (consume less)
	player.energyRegeneration = 6	-- can be increased with powerups?
	-- note: attackWait * energyRegeneration == energyPerShoot --> no drain/no gain
	
	-- lives
	player.maxLives = 8
	player.currentLives = 4
	
	-- calculate "borders"
	player.minx, player.maxx = SCREEN.width * 0.025 + player.body.sizeX/2, SCREEN.width * 0.4 - player.body.sizeX/2
	player.miny, player.maxy = SCREEN.height * 0.05 + player.body.sizeY/2, SCREEN.height * 0.65 - player.body.sizeY/2
	
	-- "thrust" particles
	player.thrustPs = {}
	player.thrustPs.system = love.graphics.newParticleSystem(testimg, 32)
	player.thrustPs.system:setParticleLifetime(0.25, 0.75)		-- particles live at least (min)s and at most (max)s.
	player.thrustPs.system:setEmissionRate(12)					-- number of particles emitted per second
	player.thrustPs.system:setSizeVariation(1)					-- the amount of variation (0 meaning no variation and 1 meaning full variation between start and end)
	player.thrustPs.system:setEmitterLifetime(-1)				-- sets how long the particle system should emit particles (if -1 then it emits particles forever)
	-- newly created particles will spawn in an area around the emitter based on the parameters to this function
	-- note: in newer versions (11+) use ParticleSystem:setEmissionArea
	player.thrustPs.system:setAreaSpread("normal", 0, player.body.sizeY * 0.05)
	player.thrustPs.system:setLinearAcceleration(-80, -10, -20, 10)			-- move to the left
	player.thrustPs.system:setColors(255, 255, 255, 255, 255, 255, 255, 0)	-- fade to transparency
	player.thrustPs.system:setSizes(0.2, 0.25, 0.5)							-- particles can have different sizes (specify at least one)
	player.thrustPs.pos = { x = player.body.x - player.body.sizeX * 0.5, y = player.body.y }
	player.thrustPs.active = true
	
	partman:add(player.thrustPs)
	
	-- image; see shrinkSize and resetSize
	-- note: the image is a little bit larger than the hitbox
	function player:updateImageProperties()
		player.imgScaleX = 1.2 * player.body.sizeX / imageShip:getWidth()
		player.imgScaleY = 1.2 * player.body.sizeY / imageShip:getHeight()
		
		player.imgOffsetX = player.body.sizeX * 0.6 / player.imgScaleX
		player.imgOffsetY = player.body.sizeY * 0.6 / player.imgScaleY
	end
	
	
	function player:tick(dt)
		-- update position etc
		
		self.body.x = tools.clamp(self.body.x + self.body.velocity.x * dt, player.minx, player.maxx)
		self.body.y = tools.clamp(self.body.y + self.body.velocity.y * dt, player.miny, player.maxy)
		
		self.body.velocity.x = 0--self.body.velocity.x * 0.99
		self.body.velocity.y = 0--self.body.velocity.y * 0.99
		
		self.attackWait = self.attackWait - dt
		if self.attackWait < 0 then
			self.attackWait = 0
		end
		
		-- generate weapon energy
		self.energy = self.energy + self.energyRegeneration * dt
		if self.energy > self.maxEnergy then
			self.energy = self.maxEnergy
		end
		
		if self.lastHurtTimer > 0 then
			self.lastHurtTimer = tools.max(0, self.lastHurtTimer - dt)
		end
		
		self.thrustPs.pos = { x = self.body.x - self.body.sizeX * 0.5, y = self.body.y }
	end
	
	
	function player:canShoot()
		return self.attackWait == 0 and self.energy >= self.energyPerShoot and self.currentLives > 0	-- TODO: remove last condition?
	end
	
	
	function player:hasEnoughEnergy()
		return self.energy >= self.energyPerShoot
	end
	
	function player:shoot()
		if pupman:isPowerupActive(PU_SUPERCANNON) then
			self.attackWait = pAttackWait * 0.5
		else
			self.attackWait = pAttackWait
		end
		
		-- drain weapon energy
		if pupman:isPowerupActive(PU_SUPERCANNON) then
			self.energy = self.energy - self.energyPerShoot * 0.5
		else
			self.energy = self.energy - self.energyPerShoot
		end
		
		
		if pupman:isPowerupActive(PU_LASERCANNON) then
			
			-- laser instead of bullets
			laser:create( { x = self.body.x + self.body.sizeX/2, y = self.body.y } )
			
			-- play a sound
			soundmgr:playSound("shoot2")
			
			return
		end
		
		-- create a new bullet...
		bullet:create( { x = self.body.x, y = self.body.y, sizeX = SCREEN.width/80, sizeY = SCREEN.height/80, velocity = { x = 36 * METER, y = 0 }, type = "playerbullet" } )
		
		-- extra: shoot three bullets total when powerup is active
		if pupman:isPowerupActive(PU_TRIPPLECANNON) then
			bullet:create( { x = self.body.x, y = self.body.y, sizeX = SCREEN.width/80, sizeY = SCREEN.height/80, velocity = { x = 35.6 * METER, y = -24 }, type = "playerbullet" } )
			bullet:create( { x = self.body.x, y = self.body.y, sizeX = SCREEN.width/80, sizeY = SCREEN.height/80, velocity = { x = 35.6 * METER, y =  24 }, type = "playerbullet" } )
		end
		
		-- play a sound
		soundmgr:playSound("shoot3")
	end
	
	
	function player:getEnergy() 
		return self.energy / self.maxEnergy
	end
	
	
	function player:getPosition()
		return { x = self.body.x, y = self.body.y }
	end
	
	
	function player:getBody()
		return self.body
	end
	
	
	function player:push(vec2)
		self.body.velocity.x = self.body.velocity.x + vec2.x
		self.body.velocity.y = self.body.velocity.y + vec2.y
		
		--self.body.velocity = tools.trimVector(self.body.velocity, 200)
		self.body.velocity = tools.setVectorLength(self.body.velocity, player.speed)
	end
	
	
	function player:draw()
		
		-- recently been hurt? invulnerable for a moment...
		if self.lastHurtTimer > 0 then
			lg.setColor(255, 255, 255, 100)
		end
		
		local body = self.body
		
		-- debug ("image")
		--lg.rectangle("line", body.x - body.sizeX/2, body.y - body.sizeY / 2, body.sizeX, body.sizeY)
		
		lg.draw(imageShip, body.x, body.y, 0, self.imgScaleX, self.imgScaleY, self.imgOffsetX, self.imgOffsetY)
		
		-- powerups...
		-- shield active?
		if pupman:isPowerupActive(PU_SHIELD) then
			lg.setLineWidth(4)
			lg.circle("line", body.x, body.y, tools.max(body.sizeX, body.sizeY) / 1.8)
		end
		
		lg.setColor(255, 255, 255, 255)
		lg.setLineWidth(1)
	end
	
	
	function player:hurt()	-- amount?
		--print("player getting HURT!")
		
		if pupman:isPowerupActive(PU_SHIELD) then
			-- ignore any incomming damage while shield is active
			-- but inform the powerup manager that the shield got hit
			pupman:onShieldHit()
			return
		end
		
		if self.lastHurtTimer > 0 then
			-- also ignore any incomming damage if damage has been taken very recently
			return
		end
		
		self.lastHurtTimer = 2	-- for the next 2 seconds: take no damage
		self.currentLives = self.currentLives - 1
		if self.currentLives < 1 then
			print("player has LOST!")
			self:destroy()
			gameOver()
		else
			-- lost one life but still got at least one more...
			--> loose progress for curent powerup charge?
			pupman:playerLostOneLife()
			
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
		end
	end
	
	-- obtained by a powerup
	function player:addExtraLife()
		if self.currentLives < self.maxLives then
			self.currentLives = self.currentLives + 1
		end
	end
	
	-- powerup: make the player smaller
	function player:shrinkSize()
		self.body.sizeX = SCREEN.width * 0.025
		self.body.sizeY = SCREEN.height * 0.035
		self.speed = 22 * METER
		
		self:updateImageProperties()
	end
	
	-- reset shrink powerup modification
	function player:resetSize()
		self.body.sizeX = SCREEN.width * 0.045
		self.body.sizeY = SCREEN.height * 0.07
		self.speed = 17 * METER
		
		self:updateImageProperties()
	end
	
	
	function player:destroy()
		gameloop:remove(self)
		renderer:remove(self)
		entman:remove(self)
		self = nil
	end
	
	player:updateImageProperties()
	
	gameloop:add(player)
	renderer:add(player, LAYER_PLAYER)
	entman:add(player)
	
	return player
end

return Player

-- more like a powerup manager!?
local Powerupmanager = {}
local random = love.math.random

--[[
	GENERAL IDEA:
	
	- hitting an enemy/obstacle fills up the powerup bar
	- reaching max, a random powerup spawns (to be collected?)
	- as soon as a powerup is active, the bar represents its remaining duration
	
	POWERUP IDEAS:
	
	* shield
	- get immune to any damage for a few seconds
	
	* tripple cannon
	- shoot three bullets in a cone instead of one
	
	* piercing bullets
	- playerbullets do not get destroyed on colliding with enemies/obstacles
	- they can hit multiple -> problem: how to not hit one enemy serveral times?
	* ALT: laser
	- instead of bullets, the player can shoot lasers that go through every enemy/obstacle in a straight line
	
	* super cannon
	- increased fire rate + energy regeneration for a short duration
	
	* extra life
	- can be stacked up to a maximum (8? 5?)
	
	* exploding bullets
	- two variants: bullets that come close to enemies/obstacles explode, dealing AOE damage
	- or: upon destroying an enemy/obstacle it explodes, dealing AOE damage around it
	
	* shrink the player
	- for a few seconds make the player hitbox smaller to make it easier to dodge obstacles and enemies
	- also increase the movement speed
	
	
--]]

local POWERUP_CHARGE = 0
local POWERUP_USING = 1
local POWERUP_READY = 2

-- spawn chances
local CHANCE_ZERO = 0
local CHANCE_LOW = 2
local CHANCE_NORMAL = 5
local CHANCE_HIGH = 8
local CHANCE_SUPER = 50	-- mainly for debugging purposes...

-- global :/
PU_SHIELD = 1
PU_TRIPPLECANNON = 2
PU_EXTRALIFE = 3
PU_SUPERCANNON = 4
PU_LASERCANNON = 5
PU_SHRINK = 6

local POWERUPS = {
	[1] = {
		-- shield
		id = PU_SHIELD,
		icon = "pu_shield",
		duration = 8,		-- seconds
		chance = CHANCE_NORMAL,
	},
	[2] = {
		-- shoot three bullets at once
		id = PU_TRIPPLECANNON,
		icon = "pu_tripplecannon",
		duration = 10,		-- seconds
		chance = CHANCE_HIGH,
	},
	[3] = {
		-- restore a life (if not already at maximum)
		id = PU_EXTRALIFE,
		icon = "pu_extralife",
		duration = 3,		-- seconds / cooldown? not used
		chance = CHANCE_NORMAL,
	},
	[4] = {
		id = PU_SUPERCANNON,
		icon = "pu_supercannon",
		duration = 10,
		chance = CHANCE_NORMAL,
	},
	[5] = {
		id = PU_LASERCANNON,
		icon = "pu_lasercannon",
		duration = 10,
		chance = CHANCE_NORMAL,
	},
	[6] = {
		id = PU_SHRINK,
		icon = "pu_shrink",
		duration = 10,
		chance = CHANCE_LOW,
	},
}

function Powerupmanager:create()
	local pupman = {}
	
	pupman.status = POWERUP_CHARGE
	pupman.value = 0	-- in %
	pupman.bag = randombag:create()
	
	
	function pupman:isCharging()
		return self.status == POWERUP_CHARGE
	end
	
	function pupman:isPowerupReady()
		return self.status == POWERUP_READY
	end
	
	
	function pupman:getProgress()
		return self.value / 100
	end
	
	
	function pupman:charge(_val)
		-- only charge if we are currently charging, but not while using a powerup (or cooldown? for instant powerups, eg. extra life)
		if self:isCharging() then
			self.value = tools.min(100, self.value + _val or 1)
		end
	end
	
	-- player lost one life --> reset progress if currently charging
	function pupman:playerLostOneLife()
		if self:isCharging() then
			self.value = 0
		end
	end
	
	-- returns the index only!
	function pupman:getRandomPowerup()
		
		-- adjust the chance to get a nice extra life if needed or if already at max
		if player.currentLives == player.maxLives then
			POWERUPS[PU_EXTRALIFE].chance = CHANCE_ZERO
		elseif player.currentLives == 1 then
			POWERUPS[PU_EXTRALIFE].chance = CHANCE_HIGH
		end
		
		self.bag:clear()
		for i = 1, #POWERUPS do
			self.bag:add(POWERUPS[i], POWERUPS[i].chance)
		end
		
		return self.bag:getRandom().id
		
	end
	
	
	function pupman:tick(dt)
		
		if self:isCharging() then
			
			if self.value == 100 then
				
				-- ready to spawn/use a powerup!
				local rnd = self:getRandomPowerup()	-- ID!
				self:readyPowerup(rnd)
				--self:setPowerup(rnd)
				
			else
				-- slowly decrease charge value; TODO remove?
				--self.value = tools.max(0, self.value - dt * 0.5)
				
			end
			
		else
			-- we are currently using a powerup, do not charge
			
			if self:isPowerupReady() then
				return
			end
			
			if self.value == 0 then
				
				-- powerup time is over
				self:setPowerup()	-- nil = none active
				
			else
			
				-- first, check if we have a powerup that is applied immediately
				-- it has no real duration, but maybe a cooldown (before we start charging again)
				--> ALT: use the same mechanic for duration and cooldown!
				if self.powerup.id == PU_EXTRALIFE then
				
					self.value = 0
					
				else	-- "normal" powerup that is active for a limitted time
				
					local drain = 100 / self.powerup.duration
					self.value = tools.max(0, self.value - drain * dt)
					
				end
				
				
			end
			
		end
		
	end
	
	-- the player shield got hit... reduce the remaining duration a little bit
	function pupman:onShieldHit()
		if self.powerup.id ~= PU_SHIELD then
			return false
		end
		
		local punishment = 20	-- getting hit reduces the shield duration
		if self.value > punishment then
			self.value = self.value - punishment
		else
			self.value = 0	-- remove next tick
		end
	end
	
	
	-- prepare to use a powerup (keep it until activated)
	function pupman:readyPowerup(_id)
		if not _id or not POWERUPS[_id] then
			print("pupman error: cannot ready powerup", _id)
			return false
		end
		
		-- from now on the player can activate that powerup
		self.powerup = POWERUPS[_id]
		--print("pupman: ready ", self.powerup.icon)
		self.status = POWERUP_READY
		
		if self.powerup.id == PU_EXTRALIFE then	--> use that one immediately
			self:setPowerup(self.powerup.id)
		end
		
		gui:onPowerupReady()
	end
	
	function pupman:getReadyPowerupId()
		if not self.powerup
		or not self:isPowerupReady() then
			return false
		end
		return self.powerup.id
	end
	
	function pupman:getCurrentIconName()	-- returns the name (string)
		if not self.powerup then
			return false
		end
		return self.powerup.icon
	end
	
	-- use a powerup or set to nil
	function pupman:setPowerup(_id)
		if _id then
			
			self.powerup = POWERUPS[_id]
			
			-- update status
			self.status = POWERUP_USING
			
			-- check if we have to apply some effect immediately
			if _id == PU_EXTRALIFE then
				player:addExtraLife()
				
			elseif _id == PU_SHRINK then
				player:shrinkSize()
				
			end
			
		else
			
			-- revert/disable the old powerup effect
			if self.powerup.id == PU_SHRINK then
				player:resetSize()
			end
			
			self.powerup = nil
			
			-- start charging again
			self.status = POWERUP_CHARGE
			
		end
	end
	
	
	-- check whether or not a certain powerup/effect is currently active
	function pupman:isPowerupActive(_id)
		if self.powerup and self.powerup.id == _id and self.status == POWERUP_USING then
			return true
		end
		
		return false
	end
	
	
	function pupman:destroy()
		gameloop:remove(self)
		self = nil
	end
	
	
	gameloop:add(pupman)
	
	return pupman
end

return Powerupmanager

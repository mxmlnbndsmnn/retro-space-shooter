local Entitymanager = {}

function Entitymanager:create()
	local entman = {}
	
	-- init
	entman.entities = {}
	entman.laseredEntities = {}
	
	-- add a new entity that should be manged in terms of collisions / movement / other inteactions ??
	function entman:add(e)
		table.insert(self.entities, e)
	end
	
	
	-- fetch all entities
	function entman:getEntities()
		return self.entities
	end
	
	
	function entman:tick(dt)
		
		-- manage collisions etc
		for i, e1 in pairs(self.entities) do
			for j, e2 in pairs(self.entities) do
				if i ~= j then
					self:checkAndHandleCollisions(e1, e2)
				end
			end
		end
		
	end
	
	--
	function entman:checkAndHandleCollisions(e1, e2)
		local e1Type = e1.type	-- "attacker"/"hurter"
		local e2Type = e2.type	-- "target"/"hurted"
		
		-- first check if they overlap in the world
		if not tools.areBodiesColliding(e1:getBody(), e2:getBody()) then
			return
		end
		
		--[[
			WHO CAN COLLIDE AT ALL?
			
			meteorite, player
			meteorite, playerbullet
			
			playerbullet, enemy
			
			enemy, player
			
			enemybullet, player
			
		--]]
		
		-- only check once per tick -> check if e1 collides with e2, not vice versa (this would be a second check for the same two entities)
		--> e.g. let e1 always be the entity comming from the right side
		if e1Type == "meteorite" then
			if e2Type == "player" then
				--print("meteorite hits player")
				
				-- hurt the player
				e2:hurt()
				-- destroy the meteorite + draw particles
				e1:destroy(true)
				
			elseif e2Type == "playerbullet" then
				--print("meteorite hits playerbullet")
				
				if e2.explosive then
					
				end
				
				-- destroy the playerbullet and hurt the meteorite (use hurt even if it is going to destroy it in one hit!)
				e1:hurt()
				e2:destroyOnImpact()
				
				--self:onPlayerBulletHit()
				
			elseif e2Type == "playerlaser"
			and not tools.isValueInTable(e1, self.laseredEntities) then
				e1:hurt()
				table.insert(self.laseredEntities, e1)
				
			end
		
		elseif e1Type == "enemybullet" then
			if e2Type == "player" then
				--print("enemybullet hits player")
				
				-- hurt the player
				e2:hurt()
				-- destroy the enemybullet
				e1:destroyOnImpact()
				
			end
			
		elseif e1Type == "enemy" then
			if e2Type == "player" then
				--print("enemy hits player")
				
				-- hurt the player
				e2:hurt()
				-- destroy the enemy + draw particles
				e1:destroy(true)
				
			elseif e2Type == "playerlaser"
			and not tools.isValueInTable(e1, self.laseredEntities) then
				e1:hurt()
				table.insert(self.laseredEntities, e1)
				
			elseif e2Type == "playerbullet" then
				--print("enemy hits playerbullet")
				
				-- destroy the playerbullet and hurt the enemy
				e1:hurt()
				e2:destroyOnImpact()
				
			end
			
		end
	end
	
	
	function entman:onPlayerBulletHit()
		
		-- give information to powerupmanager
		pupman:charge(12)
		
	end
	
	-- enemy OR obstacle
	function entman:onEnemyDestroyed()
		
		-- give information to powerupmanager
		pupman:charge(20)
		
	end
	
	
	function entman:remove(entity)
		if entity.type == "playerlaser" then
			self.laseredEntities = {}
		end
		
		for i = #self.entities, 1, -1 do
			if self.entities[i] == entity then
				table.remove(self.entities, i)
				return
			end
		end
	end
	
	
	function entman:destroy()
		gameloop:remove(self)
		self = nil
	end
	
	gameloop:add(entman)
	
	return entman
end

return Entitymanager

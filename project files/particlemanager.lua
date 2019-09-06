local Particlemanager = {}
local lg = love.graphics


function Particlemanager:create()
	local partman = {}
	
	partman.ps = {}	-- particle systems
	
	function partman:tick(dt)
		for i, ps in pairs(self.ps) do
			local pMin, pMax = ps.system:getParticleLifetime()
			local lifetime = ps.system:getEmitterLifetime()
			-- also take the particle lifetime into consideration, not only the emitter's!
			-- emitter lifetime of -1 means it emitts forever -> do not remove
			if (ps.startTime + lifetime + pMax <= GAMETIME) and (lifetime > -1) then
				--print("ps: remove")
				table.remove(self.ps, i)
			else
				ps.system:update(dt)
			end
		end
	end
	
	
	function partman:add(_ps)
		if not _ps.startTime then
			_ps.startTime = GAMETIME
		end
		--if not _ps.color then
			--_ps.color = { r = 255, g = 255, b = 255, a = 255 }
		--end
		table.insert(self.ps, _ps)
	end
	
	
	function partman:draw()
		lg.setColor(255, 255, 255, 255)
		for i, ps in pairs(self.ps) do
			--local c = ps.color
			--lg.setColor(c.r, c.g, c.b, c.a)
			lg.draw(ps.system, ps.pos.x, ps.pos.y)
		end
	end
	
	-- remove all current particle systems (eg. when a level is completed)
	function partman:clear()
		self.ps = {}
	end
	
	
	function partman:destroy()
		gameloop:remove(self)
		renderer:remove(self)
		self = nil
	end
	
	gameloop:add(partman)
	renderer:add(partman, LAYER_GUI)
	
	return partman
end

return Particlemanager

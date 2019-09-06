local Levelmanager = {}
local random = love.math.random

local spawnTypes = { meteorite = 1, enemy = 2 }	-- expand...

local leveldata = {}

leveldata[1] = {
	--time = 20,	-- seconds
	segmentCount = 2,
	segmentTime = 10,	-- seconds
	segments = {
		{
			startTime = 0,
			spawns = {
				[spawnTypes.meteorite] = { min = 3, max = 5 },
			},
		},
		{
			startTime = 10,
			spawns = {
				[spawnTypes.meteorite] = { min = 6, max = 10 },
			},
		},
	}
}

function Levelmanager:create()
	local lvlman = { currentLevel = 0, spawns = {} }
	
	
	function lvlman:startLevel(index)
		if leveldata[index] then
			--return leveldata[index]
			self.currentLevel = index
			GAMETIME = 0	-- alt: LEVELTIME?
			
			self:scheduleSpawns()
			
		else
			print("error: cannot load level", index)
			return false
		end
	end
	
	
	function lvlman:scheduleSpawns()
		local lvl = leveldata[self.currentLevel]	-- the current level
		
		self.spawns = {}
		
		-- for every segment...
		for n = 1, lvl.segmentCount do
			local segment = lvl.segments[n]
			
			-- for every entity type that can be spawned
			for j, spawnTypeData in pairs(segment.spawns) do
				local amount = random(spawnTypeData.min, spawnTypeData.max)
				print(j, "amount: ", amount)
			end
			
			-- all possible spawn times (one second intervalls)
			for spawnTime = 1, lvl.segmentTime do
				self.spawns[spawnTime] = {}
				
				
				
			end
			
			-- assign (add) entity spawns -> group them
			local rndTime = random(lvl.segmentTime) + (n-1) * lvl.segmentTime
		end
	end
	
	
	function lvlman:quitlevel()
	
	end
	
	
	function lvlman:getCurrentSegment()
		if leveldata[self.currentLevel] then
			
		else
			return false
		end
	end
	
	
	function lvlman:tick(dt)
		--[[
		if self.currentLevel > 0 then
			for i, sp in pairs(self.spawns) do
				if GAMETIME >= sp.time then
					-- do the spawn
					self:spawnEntities(sp)
					
					-- remove from the schedule
					table.remove(sp, i)
				end
			end
		end
		--]]
	end
	
	
	function lvlman:spawnEntities(sp)
		-- if multiple entites are to be created at the same time, distribute them along the y-axis to avoid overlapping
		
	end
	
	
	gameloop:add(lvlman)
	
	return lvlman
end

return Levelmanager

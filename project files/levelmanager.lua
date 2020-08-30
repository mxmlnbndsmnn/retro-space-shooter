local Levelmanager = {}
local random = love.math.random

local spawnTypes = {
	meteorite = 1,
	enemyNormal = 2,
	enemySticky = 3,
	enemyMobile = 4,
	boss1 = 5,
	boss2 = 6,
	boss3 = 7,
	boss4 = 8,
}	-- expand...

local leveldata = {}
local maxEnemyCounter = 8	-- no more enemies than that amount at a time
local spawnRate = 3		-- only spawn once per X seconds
local spawnTick = 0
--local fightingBoss = false	-- (not) allowed spawn normal enemies right now?

--[[
leveldata[1] = {
	
	spawnChances = {
		[spawnTypes.meteorite]	= function(time) if time < 20 or time > 60 then return 0.3 else return 0.5 end end,
		[spawnTypes.enemy]		= function(time) if time < 30 then return 0.3 else return 0.45 end end,
	},

}
--]]

-- another approach on how to manage enemy spawns:
-- spawn in waves (every X seconds) except when a bossfight is ongoing
-- the current SCORE is the main factor that determines what units are possibly going to be spawned next
-- per wave there is a chance for a unit/group of units to spawn, they will be distributed along the y axis

local CHANGE_SPAWN_SET = 1
local START_BOSS_FIGHT = 2

function Levelmanager:create()
	local lvlman = { currentLevel = 0, spawns = {}, useSpawnSetIndex = 1, fightingBoss = false, enemiesAlive = 0, spawnSlots = 1 }
	
	-- IMPORTANT: for now defeating a boss ALWAYS gives a score of 10(?)
	--> take care of that when setting the score needed for the next spawnSet/event --> next event must have a score that is 1 higher
	
	-- actionParam = the next index in lvlman.waveSpawns to be used from now on
	--> they are usually but do not HAVE TO be ascending, a set that already has been used might be used again!
	lvlman.eventQueue = {
		{ score =  5, actionType = CHANGE_SPAWN_SET, actionParam = 2 },
		{ score = 20, actionType = CHANGE_SPAWN_SET, actionParam = 3 },
		{ score = 50, actionType = START_BOSS_FIGHT, actionParam = 4 },
		{ score = 51, actionType = CHANGE_SPAWN_SET, actionParam = 5 },
		{ score = 60, actionType = CHANGE_SPAWN_SET, actionParam = 3 },
		{ score = 80, actionType = CHANGE_SPAWN_SET, actionParam = 5 },
		{ score = 100, actionType = START_BOSS_FIGHT, actionParam = 6 },
		{ score = 101, actionType = CHANGE_SPAWN_SET, actionParam = 8 },
		{ score = 150, actionType = START_BOSS_FIGHT, actionParam = 7 },
		{ score = 151, actionType = CHANGE_SPAWN_SET, actionParam = 3 },
		{ score = 200, actionType = START_BOSS_FIGHT, actionParam = 9 },
		{ score = 201, actionType = CHANGE_SPAWN_SET, actionParam = 8 },
		{ score = 250, actionType = START_BOSS_FIGHT, actionParam = 9 },
		{ score = 251, actionType = CHANGE_SPAWN_SET, actionParam = 10 },
		{ score = 300, actionType = START_BOSS_FIGHT, actionParam = 11 },
		{ score = 301, actionType = CHANGE_SPAWN_SET, actionParam = 10 },
		{ score = 350, actionType = START_BOSS_FIGHT, actionParam = 11 },
		{ score = 351, actionType = CHANGE_SPAWN_SET, actionParam = 10 },
		-- repeating...
		{ score = 400, actionType = START_BOSS_FIGHT, actionParam = 12 },
		{ score = 401, actionType = CHANGE_SPAWN_SET, actionParam = 10 },
		{ score = 450, actionType = START_BOSS_FIGHT, actionParam = 11 },
		{ score = 451, actionType = CHANGE_SPAWN_SET, actionParam = 10 },
		{ score = 500, actionType = START_BOSS_FIGHT, actionParam = 12 },
		{ score = 501, actionType = CHANGE_SPAWN_SET, actionParam = 10 },
	}
	
	-- give all entries a "weigth" for their number (chance) of appearances
	lvlman.waveSpawns = {}
	for i = 1, 12 do
		lvlman.waveSpawns[i] = randombag:create()
	end
	
	-- only meteorite
	lvlman.waveSpawns[1]:add(spawnTypes.meteorite, 7)
	
	-- normal enemy + meteorite
	lvlman.waveSpawns[2]:add(spawnTypes.meteorite, 5)
	lvlman.waveSpawns[2]:add(spawnTypes.enemyNormal, 5)
	
	-- meteorite + enemies normal and sticky
	lvlman.waveSpawns[3]:add(spawnTypes.meteorite, 3)
	lvlman.waveSpawns[3]:add(spawnTypes.enemyNormal, 4)
	lvlman.waveSpawns[3]:add(spawnTypes.enemySticky, 3)	-- they stay right
	
	-- first boss (easy)
	lvlman.waveSpawns[4]:add(spawnTypes.boss1, 1)
	
	-- meteorite and sticky enemy
	lvlman.waveSpawns[5]:add(spawnTypes.meteorite, 5)
	lvlman.waveSpawns[5]:add(spawnTypes.enemySticky, 5)
	
	-- second boss (easy)
	lvlman.waveSpawns[6]:add(spawnTypes.boss2, 1)
	
	-- first OR second boss (easy)
	lvlman.waveSpawns[7]:add(spawnTypes.boss1, 1)
	lvlman.waveSpawns[7]:add(spawnTypes.boss2, 1)
	
	-- meteorite and sticky + straying enemy
	lvlman.waveSpawns[8]:add(spawnTypes.meteorite, 3)
	lvlman.waveSpawns[8]:add(spawnTypes.enemySticky, 5)
	lvlman.waveSpawns[8]:add(spawnTypes.enemyMobile, 5)
	
	-- third boss (easy to moderate)
	lvlman.waveSpawns[9]:add(spawnTypes.boss3, 1)
	
	-- few meteorites and mostly all three default enemies
	lvlman.waveSpawns[10]:add(spawnTypes.meteorite, 3)
	lvlman.waveSpawns[10]:add(spawnTypes.enemyNormal, 5)
	lvlman.waveSpawns[10]:add(spawnTypes.enemySticky, 5)
	lvlman.waveSpawns[10]:add(spawnTypes.enemyMobile, 5)
	
	-- any of the first three boss types (easy to moderate)
	lvlman.waveSpawns[11]:add(spawnTypes.boss1, 1)
	lvlman.waveSpawns[11]:add(spawnTypes.boss2, 1)
	lvlman.waveSpawns[11]:add(spawnTypes.boss3, 1)
	
	-- fourth boss (moderate)
	lvlman.waveSpawns[12]:add(spawnTypes.boss4, 1)
	
	
	function lvlman:startLevel(index)
		
		self.currentLevel = index
		GAMETIME = 0
		self.enemiesAlive = 0
		self.spawnSlots = 1
		
	end
	
	
	function lvlman:quitlevel()
	
	end
	
	
	-- notified when an enemy unit or obstacle has been destroyed
	function lvlman:enemydestroyed(credit)
		self.enemiesAlive = self.enemiesAlive - 1
		
		-- while a bossfight is active do not give any extra SCORE!
		if not self.fightingBoss then
			SCORE = SCORE + (credit or 1)
		end
	end
	
	function lvlman:bossdestroyed(credit)
		self.enemiesAlive = self.enemiesAlive - 1
		SCORE = SCORE + (credit or 10)
		BOSSESDEFEATED = BOSSESDEFEATED + 1
		gui.bossCountText:set("BOSSES DEFEATED: " .. BOSSESDEFEATED)
		self.fightingBoss = false
		--print("bossfight over!")
	end
	
	
	function lvlman:tick(dt)
		
		if PAUSED then
			return
		end
		
		for i = 1, #self.eventQueue do
			if SCORE >= self.eventQueue[i].score then
				-- trigger the event
				if self.eventQueue[i].actionType == CHANGE_SPAWN_SET then
					self.useSpawnSetIndex = self.eventQueue[i].actionParam
				
				elseif self.eventQueue[i].actionType == START_BOSS_FIGHT then
					self.useSpawnSetIndex = self.eventQueue[i].actionParam
					self.fightingBoss = true
					self.spawnSlots = 1
					--print("bossfight active!")
					
					-- spawn the boss
					self:spawnEntityAtY(self.waveSpawns[self.useSpawnSetIndex]:getRandom(), SCREEN.height * 0.35)
					
				end
				
				-- remove the event from the queue
				table.remove(self.eventQueue, i)
				break
			end
		end
		
		if not self.fightingBoss then
			self.spawnSlots = tools.min(self.spawnSlots + dt, maxEnemyCounter)
		end
		
		spawnTick = spawnTick + dt
		if spawnTick >= spawnRate
		and not self.fightingBoss then
			--if alive >= maxEnemyCounter then
				--return
			--end
			
			local toSpawn = {}
			
			-- which set of spawn chances to use based on current SCORE
			local numSpawns = tools.min(math.floor(random(1, 8) / 2), math.floor(self.spawnSlots))
			for j = 1, numSpawns do
				table.insert(toSpawn, self.waveSpawns[self.useSpawnSetIndex]:getRandom())
			end
			
			--[[
			for i, spType in pairs(spawnTypes) do
				if alive >= maxEnemyCounter then
					break
				end
				
				if random() < leveldata[self.currentLevel].spawnChances[spType](GAMETIME) then
					--self:spawnEntity(spType)
					table.insert(toSpawn, spType)
				end
				
			end
			--]]
			
			self:spawnEntities(toSpawn)
			
			spawnTick = spawnTick - spawnRate
		end
		
	end
	
	
	function lvlman:spawnEntityAtY(spType, _y)
	
		if spType == spawnTypes.meteorite then
			meteorite:create( { x = SCREEN.width, y = _y, velocity = { x = random(16, 22) * -METER, y = 0 } } )
			
		elseif spType == spawnTypes.enemyNormal then
			--enemy:create( { x = SCREEN.width, y = random(SCREEN.height * 0.1, SCREEN.height * 0.6), velocity = { x = -100, y = 0 } } )
			enemy:create( { x = SCREEN.width, y = _y, velocity = { x = -12 * METER, y = 0 }, movementType = "normal" } )
		
		elseif spType == spawnTypes.enemySticky then
			enemy:create( { x = SCREEN.width, y = _y, velocity = { x = -12 * METER, y = 10 * METER }, movementType = "stay_right" } )
		
		elseif spType == spawnTypes.enemyMobile then
			enemy:create( { x = SCREEN.width, y = _y, velocity = { x = -8 * METER, y = -10 * METER }, movementType = "stray" } )
			
		elseif spType == spawnTypes.boss1 then
			boss1:create( { x = SCREEN.width, y = _y } )
			
		elseif spType == spawnTypes.boss2 then
			boss2:create( { x = SCREEN.width, y = _y } )
			
		elseif spType == spawnTypes.boss3 then
			boss3:create( { x = SCREEN.width, y = _y } )
			
		elseif spType == spawnTypes.boss4 then
			boss4:create( { x = SCREEN.width, y = _y } )
			
		else -- unknown type, cannot spawn
			print("lvlman: unknown spawn type", spType)
			return false
		end
		
		self.enemiesAlive = self.enemiesAlive + 1
		self.spawnSlots = self.spawnSlots - 1
		
	end
	
	
	function lvlman:spawnEntities(spawns)	-- table
		-- if multiple entites are to be created at the same time, distribute them along the y-axis to avoid overlapping
		local n = #spawns
		
		--if n == 1 then
		local yrange = SCREEN.height * 0.5 / n
		for i = 1, n do
			local y = random(yrange) + (i-1) * yrange + SCREEN.height * 0.1
			
			self:spawnEntityAtY(spawns[i], y)
		end
	end
	
	
	gameloop:add(lvlman)
	
	return lvlman
end

return Levelmanager

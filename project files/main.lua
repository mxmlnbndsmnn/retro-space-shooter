local lg = love.graphics
local random = love.math.random

GAMETIME = 0
BOSSESDEFEATED = 0
SCORE = 0
HIGHSCORE = 0
PAUSED = false
SOUNDS = true

-- to be implemented...
STATS = {
	highscore = 0,
	bulletsAvoided = 0,
	bulletsTook = 0,
	bulletsHit = 0,
	bulletsMissed = 0,
	enemiesSruvived = 0,
	enemiesKilled = 0,
	bossesKilled = 0,
	gamesPlayed = 0,
	itemsUsed = 0,
}

-- note: all icon images must be 64x64
images = {}
images.pu_shield = lg.newImage("images/pu_shield.png")
images.pu_tripplecannon = lg.newImage("images/pu_tripplecannon.png")
images.pu_extralife = lg.newImage("images/pu_extralife.png")
images.pu_supercannon = lg.newImage("images/pu_supercannon.png")
images.pu_lasercannon = lg.newImage("images/pu_lasercannon.png")
images.pu_shrink = lg.newImage("images/pu_shrink.png")


--[[
	SOME IDEAS AND (POSSIBLE) TODO
	
	- powerup: freeze enemies so they cannot shoot
	- background "animations" - more than "stars" ...
--]]

-----------------------------------------------------------------------------------------------------------------------

function love.load()
	math.randomseed(os.time())
	SCREEN = { height = lg.getHeight(), width = lg.getWidth() }
	GAMETIME = 0
	BOSSESDEFEATED = 0
	SCORE = 0
	HIGHSCORE = 0
	PAUSED = false
	
	love.filesystem.setIdentity( "RETRO SPACE SHOOTER" )
	local osString = love.system.getOS()
	if osString ~= "Android" then
		love.window.setMode(1200, 600)	-- updateMode is not supported in versions prior to 11
		SCREEN = { height = lg.getHeight(), width = lg.getWidth() }
		--renderer:onScreenSizeChanged()
	end
	
	-- define some kind of "meter" or something to have the same velocities on different screen sizes
	METER = SCREEN.width / 100	-- the width of the screen equals 100 meters in the game "world"
	
	tools = require("tools")
	randombag = require("randombag")
	gameloop = require("gameloop"):create()
	--camera = require("camera"):create()
	soundmgr = require("soundmanager"):create()
	renderer = require("renderer"):create()
	input = require("input"):create()
	gui = require("gui"):create()
	background = require("background"):create()
	entman = require("entitymanager"):create()
	partman = require("particlemanager"):create()
	lvlman = require("levelmanager"):create()
	pupman = require("powerupmanager"):create()
	meteorite = require("meteorite")
	enemy = require("enemy")
	boss1 = require("boss1")
	boss2 = require("boss2")
	boss3 = require("boss3")
	boss4 = require("boss4")
	bullet = require("bullet")
	laser = require("laser")
	
	player = require("player"):create()
	
	--[[
		PROBLEM:
		how/when to generate enemy ships or obstacles within one level?
		
		IDEA:
		- divide each level into logical (time) segments
		- for each segment, set a fixed number of ships/obstacles of specific types to spawn
		- within that segment, choose their exact spawn time randomly
		-> levels are not always exactly the same, but the randomness has not to much of an impact on the gameplay
	--]]
	
	lvlman:startLevel(1)
	
	tryToReadStats()
	
	gui.highScoreText:set("HIGHSCORE: " .. HIGHSCORE)
	
	-- note: player restart also updates highscore (because it calls gameOver)
end

-----------------------------------------------------------------------------------------------------------------------

-- player lost his last life
-- save stats and reload
function gameOver()
	if SCORE > HIGHSCORE then
		HIGHSCORE = SCORE
	end
	
	tryToWriteStats()
	
	--love.load()
end


function tryToReadStats()
	local contents, size = love.filesystem.read("stats.txt")
	if not contents then
		print("stats: file does not exist yet!")
		return false
	end
	
	-- for now: highscore
	local nhs = tonumber( contents )
	if nhs then
		HIGHSCORE = nhs
	end
end


function tryToWriteStats()
	local saveDataString = tostring(HIGHSCORE)	-- for now: only the highscore
	
	local f = love.filesystem.newFile("stats.txt")
	local open_ok, open_err = f:open("w")
	if not open_ok then
		print("stats: cannot open file!")
		print(open_err)
		return
	end
	
	local write_ok, write_err = f:write(saveDataString)
	f:close()
	
	if write_ok then
		print("stats: successfully wrote file!")
	else
		print("stats: FAILED TO WRITE file!")
		print(write_err)
	end
end

-----------------------------------------------------------------------------------------------------------------------

function love.update(dt)
	
	if dt > 0.1 then
		return
	end
	
	GAMETIME = GAMETIME + dt
	
	gameloop:update(dt)
	
	
	-- PC version + debug: use spacebar to shoot, f to use powerup and w-a-s-d to move
	if input.isMobile then
		return
	end
	
	local down = love.keyboard.isDown
	
	if down( "space" ) then
		if player:canShoot() then
			player:shoot()
			input.shootCircle.active = true
		end
	end
	
	if down( "f" ) then
		local pupId = pupman:getReadyPowerupId()
		if pupId then
			pupman:setPowerup(pupId)
			input.usePupCircle.active = true
		end
	end
	
	local dx, dy = 0, 0
	if down( "a" ) then
		dx = -10
		input.movementCircle.active = true
	elseif down( "d" ) then
		dx = 10
		input.movementCircle.active = true
	end
	
	if down( "w" ) then
		dy = -10
		input.movementCircle.active = true
	elseif down( "s" ) then
		dy = 10
		input.movementCircle.active = true
	end
	
	-- note: at least one must be ~= 0
	if dx ~= 0 or dy ~= 0 then
		player:push( { x = dx, y = dy } )
	end
	
end

-----------------------------------------------------------------------------------------------------------------------

function love.draw()
	renderer:draw()
end

-----------------------------------------------------------------------------------------------------------------------

function love.keypressed( key, scancode, isrepeat )
	--[[
	if love.system.getOS() ~= "Android" then
		if key == "space" then
			if player:canShoot() then
				player:shoot()
				input.shootCircle.active = true
			end
		end
	end
	--]]
	
	if key == "escape" then	-- also gets triggered when the back function on android is used
		--love.event.quit()
		PAUSED = not PAUSED
	end
end

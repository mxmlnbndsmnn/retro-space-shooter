local lg = love.graphics
local random = love.math.random

GAMETIME = 0
BOSSESDEFEATED = 0
SCORE = 0
HIGHSCORE = 0
PAUSED = false
SOUNDS = true

--[[
	SOME IDEAS
	
	- powerups nicht sofort aktivieren (Icon erscheint + fliegt nach unten -> tippen = benutzen)
	- bosse, die einheiten spawnen
	- TODO: particle system (player thrust)
	- "must-hit" angreifer
	- powerup: gegner können nicht mehr schießen (einfrieren)
	- schutzschild (powerup): statt zeit, best. anzahl treffer einstecken
	- Hintergrund "Animation" (vorbeifliegende Sterne...)
--]]

function love.load()
	math.randomseed(os.time())
	SCREEN = { height = lg.getHeight(), width = lg.getWidth() }
	GAMETIME = 0
	BOSSESDEFEATED = 0
	SCORE = 0
	HIGHSCORE = 0
	PAUSED = false
	
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
	
	-- debug
	debugtext = lg.newText(lg.newFont(12), "")
	
end


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
	
	--debugtext:set( string.format("pos: %d:%d", player:getPosition().x, player:getPosition().y) )
	
end


function love.draw()
	-- debug
	--lg.draw(debugtext, SCREEN.width * 0.3, 10)
	
	renderer:draw()
end


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

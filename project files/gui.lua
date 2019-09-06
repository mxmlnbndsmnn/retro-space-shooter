local Gui = {}
local lg = love.graphics

local icon_restart	= lg.newImage("images/icon_restart.png")
local icon_start	= lg.newImage("images/icon_start.png")
local icon_quit		= lg.newImage("images/icon_quit.png")
local icon_sound_off= lg.newImage("images/icon_sound_off.png")
local icon_sound_on	= lg.newImage("images/icon_sound_on.png")

local imgPixelSize = 64

function Gui:create()
	local gui = {}
	
	local font18 = lg.newFont(18)
	
	-- TODO: where to print them! (different screen sizes...)
	
	-- number of defeated bosses
	gui.bossCountText = lg.newText(font18, "BOSSES DEFEATED: 0")
	-- current score
	gui.scoreText = lg.newText(font18, "SCORE: 0")
	-- (old) highscore score
	gui.highScoreText = lg.newText(font18, "HIGHSCORE: 0")
	
	
	function gui:tick(dt)
		self.scoreText:set("SCORE: " .. SCORE)
	end
	
	
	function gui:draw()
		
		if PAUSED then
			
			-- pause screen: squares with round corners
			local size = tools.min(SCREEN.height * 0.2, SCREEN.width * 0.2)
			local halfSize = size * 0.5
			local imgScale = size / imgPixelSize
			
			lg.setColor(150, 250, 200, 255)
			
			-- start/resume game
			lg.rectangle("line", SCREEN.width * 0.2 - halfSize, SCREEN.height * 0.5 - halfSize, size, size, 4, 4)
			--lg.setColor(124, 103, 132, 255)
			lg.draw(icon_start, SCREEN.width * 0.2, SCREEN.height * 0.5, 0, imgScale, imgScale, 32, 32)
			
			-- restart
			lg.rectangle("line", SCREEN.width * 0.4 - halfSize, SCREEN.height * 0.5 - halfSize, size, size, 4, 4)
			--lg.setColor(124, 103, 132, 255)
			lg.draw(icon_restart, SCREEN.width * 0.4, SCREEN.height * 0.5, 0, imgScale, imgScale, 32, 32)
			
			-- sound on/off
			lg.rectangle("line", SCREEN.width * 0.6 - halfSize, SCREEN.height * 0.5 - halfSize, size, size, 4, 4)
			if SOUNDS then
				lg.draw(icon_sound_on, SCREEN.width * 0.6, SCREEN.height * 0.5, 0, imgScale, imgScale, 32, 32)
			else
				lg.draw(icon_sound_off, SCREEN.width * 0.6, SCREEN.height * 0.5, 0, imgScale, imgScale, 32, 32)
			end
			
			-- exit
			lg.setColor(255, 55, 55, 255)
			lg.rectangle("line", SCREEN.width * 0.8 - halfSize, SCREEN.height * 0.5 - halfSize, size, size, 4, 4)
			--lg.setColor(124, 103, 132, 255)
			lg.draw(icon_quit, SCREEN.width * 0.8, SCREEN.height * 0.5, 0, imgScale, imgScale, 32, 32)
			
			return
		end
		
		
		-- remaining lives
		local radius = tools.min(SCREEN.height * 0.04, SCREEN.width * 0.04)
		lg.setColor(120, 230, 120, 255)
		for i = 1, player.currentLives do
			if i < 5 then
				lg.circle("fill", SCREEN.width * 0.25 + (i-1) * radius * 2.2, SCREEN.height - radius * 5.2, radius)
			else
				lg.circle("fill", SCREEN.width * 0.25 + (i-5) * radius * 2.2, SCREEN.height - radius * 2.6, radius)
			end
		end
		lg.setColor(255, 255, 255, 255)
		for i = 1, player.maxLives do
			if i < 5 then
				lg.circle("line", SCREEN.width * 0.25 + (i-1) * radius * 2.2, SCREEN.height - radius * 5.2, radius)
			else
				lg.circle("line", SCREEN.width * 0.25 + (i-5) * radius * 2.2, SCREEN.height - radius * 2.6, radius)
			end
		end
		
		-- weapon energy
		-- TODO: add a simple icon (left)
		if player:hasEnoughEnergy() then
			if pupman:isPowerupActive(PU_SUPERCANNON) then	--> purple
				lg.setColor(106, 0, 128, 255)
			elseif pupman:isPowerupActive(PU_LASERCANNON) then	--> reddish
				lg.setColor(214, 0, 108, 255)
			else
				lg.setColor(120, 230, 120, 255)
			end
		else
			lg.setColor(220, 230, 120, 255)
		end
		lg.rectangle("fill", SCREEN.width * 0.42, SCREEN.height * 0.85, SCREEN.width * 0.25 * player:getEnergy(), SCREEN.height * 0.05)
		lg.setColor(255, 255, 255, 255)
		lg.rectangle("line", SCREEN.width * 0.42, SCREEN.height * 0.85, SCREEN.width * 0.25, SCREEN.height * 0.05)
		
		-- power up timer/countdown
		-- TODO: add a simple icon (left)
		if pupman:isCharging() then
			lg.setColor(120, 230, 120, 255)
		else
			lg.setColor(220, 230, 120, 255)
		end
		lg.rectangle("fill", SCREEN.width * 0.42, SCREEN.height * 0.75, SCREEN.width * 0.25 * pupman:getProgress(), SCREEN.height * 0.05)
		lg.setColor(255, 255, 255, 255)
		lg.rectangle("line", SCREEN.width * 0.42, SCREEN.height * 0.75, SCREEN.width * 0.25, SCREEN.height * 0.05)
		
		-- powerup icon (activate it)
		--lg.circle("line", SCREEN.width * 0.75, SCREEN.height * 0.8, SCREEN.height * 0.1)
		
		lg.setColor(255, 255, 255, 255)
		
		
		-- text: defeated boss count + score + highscore
		lg.draw(self.highScoreText, SCREEN.width * 0.02, SCREEN.height * 0.01, 0, 1, 1)
		lg.draw(self.scoreText, SCREEN.width * 0.5, SCREEN.height * 0.01, 0, 1, 1, self.scoreText:getWidth()/2)
		lg.draw(self.bossCountText, SCREEN.width * 0.8, SCREEN.height * 0.01)
		
	end
	
	
	gameloop:add(gui)
	renderer:add(gui, LAYER_GUI)
	
	return gui
end

return Gui

local Input = {}

local lg = love.graphics
local lt = love.touch
local mdown = love.mouse.isDown
local toggleSoundCooldown = 0	-- ugly but simple

function Input:create()
	local input = { runWhenPaused = true }
	
	local osString = love.system.getOS()
	if osString == "Android" then
		input.isMobile = true
	else
		input.isMobile = false
	end
	
	-- input elements:
	
	-- movement circle
	--local radius = tools.min(SCREEN.height * 0.15, SCREEN.width * 0.15)
	local radius = SCREEN.height * 0.175
	input.movementCircle = { shape = "circle", body = { x = radius * 1.4, y = SCREEN.height - radius * 1, radius = radius}, active = false }
	
	-- shoot circle
	local radius2 = radius * 0.7
	input.shootCircle = { shape = "circle", body = { x = SCREEN.width - radius2 * 1.5, y = SCREEN.height - radius, radius = radius2}, active = false }
	
	-- activate powerup circle
	input.usePupCircle = { shape = "circle", body = { x = SCREEN.width - radius2 * 3.8, y = SCREEN.height - radius, radius = radius2}, active = false }
	
	
	-- pause screen: rectangles
	local rSize = tools.min(SCREEN.height * 0.2, SCREEN.width * 0.2)
	
	-- resume game
	input.startRect = { shape = "rect", body = { x = SCREEN.width * 0.2, y = SCREEN.height * 0.5, sizeX = rSize, sizeY = rSize }, enabled = true }
	
	-- restart game
	input.restartRect = { shape = "rect", body = { x = SCREEN.width * 0.4, y = SCREEN.height * 0.5, sizeX = rSize, sizeY = rSize }, enabled = true }
	
	-- toggle sound
	input.toggleSoundRect = { shape = "rect", body = { x = SCREEN.width * 0.6, y = SCREEN.height * 0.5, sizeX = rSize, sizeY = rSize }, enabled = true }
	
	-- quit
	input.quitRect = { shape = "rect", body = { x = SCREEN.width * 0.8, y = SCREEN.height * 0.5, sizeX = rSize, sizeY = rSize }, enabled = true }
	
	-- TODO: pause button (rect) at the top right corner?
	
	function input:tick(dt)
	
		self.movementCircle.active = false
		self.shootCircle.active = false
		self.usePupCircle.active = false
		
		if toggleSoundCooldown > 0 then
			toggleSoundCooldown = tools.max(0, toggleSoundCooldown - dt)
		end
		
		local touches = lt.getTouches()
		
		
		if PAUSED then
			
			for j, touchID in ipairs(touches) do
				local x, y = lt.getPosition(touchID)
				local touchPos = { x = x, y = y }
				
				if tools.isPointInsideRect(touchPos, self.startRect.body) then
					soundmgr:playSound("click1")
					PAUSED = false
				
				elseif tools.isPointInsideRect(touchPos, self.restartRect.body) then
					soundmgr:playSound("click1")
					gameOver()
				
				elseif tools.isPointInsideRect(touchPos, self.toggleSoundRect.body)
				and toggleSoundCooldown == 0 then
					SOUNDS = not SOUNDS
					soundmgr:playSound("click1")
					toggleSoundCooldown = 0.4
					
				elseif tools.isPointInsideRect(touchPos, self.quitRect.body) then
					love.event.quit()
					
				end
			end
			
			-- debug: mouse input
			--
			if self.isMobile then
				return
			end
			
			local mousePos = {}
			mousePos.x, mousePos.y = love.mouse.getPosition()
			if mdown(1) then
				if tools.isPointInsideRect(mousePos, self.startRect.body) then
					soundmgr:playSound("click1")
					PAUSED = false
				
				elseif tools.isPointInsideRect(mousePos, self.restartRect.body) then
					soundmgr:playSound("click1")
					gameOver()
				
				elseif tools.isPointInsideRect(mousePos, self.toggleSoundRect.body)
				and toggleSoundCooldown == 0 then
					SOUNDS = not SOUNDS
					soundmgr:playSound("click1")
					toggleSoundCooldown = 0.4
					
				elseif tools.isPointInsideRect(mousePos, self.quitRect.body) then
					love.event.quit()
				end
			end
			--
			
			return
		end
		
		-- NOT paused
		
		for j, touchID in ipairs(touches) do
			local x, y = lt.getPosition(touchID)
			local touchPos = { x = x, y = y }
			
			if tools.isPointInsideCircle(touchPos, self.movementCircle.body) then
				local vec2 = { x = touchPos.x - self.movementCircle.body.x, y = touchPos.y - self.movementCircle.body.y }
				player:push(vec2)
				self.movementCircle.active = true
			
			elseif tools.isPointInsideCircle(touchPos, self.shootCircle.body) then
				if player:canShoot() then
					player:shoot()
					self.shootCircle.active = true
				end
				
			elseif tools.isPointInsideCircle(touchPos, self.usePupCircle.body) then
				local pupId = pupman:getReadyPowerupId()
				if pupId then
					pupman:setPowerup(pupId)
					self.usePupCircle.active = true
				end
			end
		end
		
		-- debug: mouse input
		--
		if self.isMobile then
			return
		end
		
		local mousePos = {}
		mousePos.x, mousePos.y = love.mouse.getPosition()
		if tools.isPointInsideCircle(mousePos, self.movementCircle.body) then
			--local vec2 = tools.setVectorLength( { x = mousePos.x - self.movementCircle.body.x, y = mousePos.y - self.movementCircle.body.y }, 1)
			local vec2 = { x = mousePos.x - self.movementCircle.body.x, y = mousePos.y - self.movementCircle.body.y }
			-- careful: this results in unwanted behaviour (vector length is 0 -> for SOME reason!? the player bugs our of its area)
			if vec2.x ~= 0 or vec2.x ~= 0 then
				player:push(vec2)
				self.movementCircle.active = true
			end
			
		elseif tools.isPointInsideCircle(mousePos, self.shootCircle.body) then
			if mdown(1) then
				if player:canShoot() then
					player:shoot()
					self.shootCircle.active = true
				end
			end
			
		elseif tools.isPointInsideCircle(mousePos, self.usePupCircle.body) then
			if mdown(1) then
				local pupId = pupman:getReadyPowerupId()
				if pupId then
					pupman:setPowerup(pupId)
					self.usePupCircle.active = true
				end
			end
		end
		--
	end
	
	
	function input:draw()
		for i, c in pairs( {self.movementCircle, self.shootCircle, self.usePupCircle} ) do
			if c.active then
				lg.setColor(150, 190, 150, 150)
			else
				lg.setColor(150, 190, 150, 50)
			end
			lg.circle("fill", c.body.x, c.body.y, c.body.radius)
			
			lg.setColor(255, 255, 255, 255)
			-- powerup icon
			if not pupman:isCharging() then
				local body = self.usePupCircle.body
				-- make the icon only half as big as the circle
				local scale = body.radius * 0.5 / 32
				local offset = body.radius * 0.5 / scale
				local iconName = pupman:getCurrentIconName()
				if iconName and images[iconName] then
					lg.draw(images[iconName], body.x, body.y, 0, scale, scale, offset, offset)
				else
					--lg.draw(images.pu_shield, body.x, body.y, 0, scale, scale, offset, offset)
					lg.print("?", body.x, body.y)
				end
			end
		end
		
		--lg.setColor(150, 150, 150, 150)
		--local c = self.movementCircle.body
		--lg.circle("fill", c.x, c.y, c.radius)
		
		lg.setColor(255, 255, 255, 255)
	end
	
	gameloop:add(input)
	renderer:add(input, LAYER_GUI)
	
	return input
end

return Input

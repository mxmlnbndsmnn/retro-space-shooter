local BG = {}
local lg = love.graphics
local random = love.math.random

-- simple background "animation"
--> some moving stuff that should create the illusion of movement in space

function BG:create()
	local bg = { rendererDisableHide = true }
	
	-- scene "objects"
	-- TODO...
	
	bg.stars = {}
	for i = 1, 50 do
		local star = {
			x = random(SCREEN.width * 1.1),
			y = random(SCREEN.height * 0.6) + SCREEN.height * 0.05,
			velocity = { x = - random(3, 6) * METER, y = random(-1, 1) * 0.1 * METER },
			radius = random(3,7) * 0.1 * METER,
		}
		bg.stars[#bg.stars+1] = star
	end
	
	
	function bg:tick(dt)
		for i = 1, #self.stars do
			local s = self.stars[i]
			s.x = s.x + s.velocity.x * dt
			s.y = s.y + s.velocity.y * dt
			
			if s.x < 0 then
				s.x = SCREEN.width * 1.1
			end
		end
	end
	
	
	function bg:draw()
		
		-- "stars"
		lg.setColor(255, 255, 255, 40)
		for i = 1, #self.stars do
			local s = self.stars[i]
			lg.circle("fill", s.x, s.y, s.radius)
		end
		
		lg.setColor(255, 255, 255, 255)
	end
	
	gameloop:add(bg)
	renderer:add(bg, LAYER_BG)
	
	return bg
end


return BG

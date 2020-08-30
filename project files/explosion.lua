local Explosion = {}
local lg = love.graphics
local random = love.math.random

local image = lg.newImage("images/ugly_explosion.png")

function Explosion:create(data)
	local explosion = {}
	explosion.type = "explosion"	-- used for collision management
	explosion.body = {
		shape = "circle",
		x = data.x,
		y = data.y,
		radius = data.radius or data.size or 0.2 * SCREEN.height,
		rotation = random(2*math.pi),
	}
	explosion.ttl = data.ttl or 1	-- time in seconds
	
	
	-- image
	-- note: the image is a little bit larger than the hitbox
	explosion.imgScaleX = 2 * explosion.body.radius / image:getWidth()
	explosion.imgScaleY = 2 * explosion.body.radius / image:getHeight()
	
	explosion.imgOffsetX = explosion.body.radius / explosion.imgScaleX
	explosion.imgOffsetY = explosion.body.radius / explosion.imgScaleY
	
	
	function explosion:tick(dt)
		self.ttl = self.ttl - dt
		
		if self.ttl <= 0 then
			self:destroy()
		end
		
	end
	
	
	function explosion:draw()
		local body = self.body
		lg.setColor(255, 25, 25, 128)
		lg.draw( image, body.x, body.y, body.rotation, self.imgScaleX, self.imgScaleY, self.imgOffsetX, self.imgOffsetY )
		lg.setColor(255, 255, 255, 255)
	end
	
	
	function explosion:getPosition()
		return { x = self.body.x, y = self.body.y }
	end
	
	function explosion:getBody()
		return self.body
	end
	
	
	function explosion:destroy()
		gameloop:remove(self)
		renderer:remove(self)
		entman:remove(self)
		self = nil
	end
	
	
	-- hurt nearby entities once
	function explosion:hurtEntities( config )
		local body = self.body
		local entities = entman:getEntities()
		for i, entity in pairs(entities) do
			local entityType = entity.type
			if entityType == "meteorite"
			or entityType == "enemy" then	-- including bosses
				if tools.areBodiesColliding( entity:getBody(), body ) then
					entity:hurt()
				end
			elseif entityType == "player" and config and config.hurtPlayer then
				-- only hurt the player when intended...
				if tools.areBodiesColliding( entity:getBody(), body ) then
					entity:hurt()
				end
			end
		end
	end
	
	
	gameloop:add(explosion)
	renderer:add(explosion, LAYER_BULLETS)
	entman:add(explosion)
	
	return explosion
end

return Explosion

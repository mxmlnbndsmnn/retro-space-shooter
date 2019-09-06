local Camera = {}

local lg 		= love.graphics
local pop 		= lg.pop
local trans 	= lg.translate
local scale 	= lg.scale
local push 		= lg.push

function Camera:create()
	local camera = {
		x = 0,
		y = 0,
		scaleX = 1,
		scaleY = 1,
	}
	
	function camera:set()
		push()
		trans(-self.x,-self.y)
		scale(1 / self.scaleX,1 / self.scaleY)
	end

	-- centers the camera so that the position is in the center of the SCREEN
	function camera:setPosition(pos)
		if type(pos) ~= "table" then
			return false
		end
		self.x = pos.x * (1/self.scaleX) - SCREEN.width / 2
		self.y = pos.y * (1/self.scaleY) - SCREEN.height / 2
	end

	function camera:setScale(_sx, _sy)
		if not _sy then
			_sy = _sx
		end
		--sx = math.min(math.max(_sx or 1, 0.5), 3)
		--sy = math.min(math.max(_sy or 1, 0.5), 3)
		local sx = tools.clamp(_sx or 1, 0.5, 4)
		local sy = tools.clamp(_sy or 1, 0.5, 4)
		self.scaleX, self.scaleY = sx, sy
		--print("camera: set scale: " .. sx .. " / " .. sy)
	end

	function camera:zoomIn()
		local sx, sy = self:getScale()
		self:setScale(sx - 0.1, sy - 0.1)
	end

	function camera:zoomOut()
		local sx, sy = self:getScale()
		self:setScale(sx + 0.1, sy + 0.1)
	end

	function camera:getScale()
		return self.scaleX, self.scaleY
	end

	function camera:unset()
		pop()
	end

	function camera:getPosition(_x, _y)
		local x, y
		_x = _x or self.x
		_y = _y or self.y
		x = (_x + SCREEN.width / 2) * self.scaleX
		y = (_y + SCREEN.height / 2) * self.scaleY
		return x, y
	end
	
	return camera
end

return Camera

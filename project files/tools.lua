
-- tools

local tools = {}

function tools.copyTable(obj, seen)	-- from https://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[tools.copyTable(k, s)] = tools.copyTable(v, s) end
	return res
end

-- get the world coordinates from a SCREEN position
--[[
function tools.getWorldPosition(SCREENPos)
	local pos = { x = 0, y = 0 }
	local cx, cy = camera:getPosition()
	local sx, sy = camera:getScale()
	pos.x = cx + (SCREENPos.x - SCREEN.width / 2) * sx
	pos.y = cy + (SCREENPos.y - SCREEN.height / 2) * sy
	return pos
end
--]]

function tools.isPointInsideShape(point, shape)
	if shape.shape == "rect" then
		return tools.isPointInsideRect(point, shape)
	elseif shape.shape == "circle" then
		return tools.isPointInsideCircle(point, shape)
	else
		print("tools: unknown body type!", shape.shape)
		return false
	end
	
end


function tools.areBodiesColliding(body1, body2)
	
	if body1.shape == "rect" then
		
		if body2.shape == "rect" then
			return tools.areRectsColliding(body1, body2)
			
		elseif body2.shape == "circle" then
			return tools.areCircleAndRectColliding(body2, body1)
			
		elseif body2.shape == "point" then
			return tools.isPointInsideRect(body2, body1)
			
		else
			print("ERROR in tools: invalid shape (2)", body2.shape)
			return false
		end
		
	elseif body1.shape == "circle" then
		
		if body2.shape == "rect" then
			return tools.areCircleAndRectColliding(body1, body2)
			
		elseif body2.shape == "circle" then
			return tools.areCirclesColliding(body1, body2)
			
		elseif body2.shape == "point" then
			return tools.isPointInsideCircle(body2, body1)
			
		else
			print("ERROR in tools: invalid shape (2)", body2.shape)
			return false
		end
		
	elseif body1.shape == "point" then
		
		if body2.shape == "rect" then
			return tools.isPointInsideRect(body1, body2)
			
		elseif body2.shape == "circle" then
			return tools.isPointInsideCircle(body1, body2)
			
		elseif body2.shape == "point" then
			
			return body1.x == body2.x and body2.y == body2.y
			
		else
			print("ERROR in tools: invalid shape (2)", body2.shape)
			return false
		end
		
	else
		print("ERROR in tools: invalid shape (1)", body1.shape)
		return false
	end
	
end


function tools.isPointInsideRect(point, rect)
	
	local x, y = rect.x, rect.y
	
	if point.x > x - rect.sizeX/2
	and point.x < x + rect.sizeX/2
	and point.y > y - rect.sizeY/2
	and point.y < y + rect.sizeY/2 then
		
		return true
	end
	
	return false

end

-- note: here only non rotated rectangles... and all rects have their origin at the CENTER, not the top left corner anymore!
function tools.areRectsColliding(rect_1, rect_2)

	-- use the top left corner internally
	local x1, y1 = rect_1.x - rect_1.sizeX/2, rect_1.y - rect_1.sizeY/2
	local x2, y2 = rect_2.x - rect_2.sizeX/2, rect_2.y - rect_2.sizeY/2
	
	if x1 + rect_1.sizeX > x2 and
	   x1 < x2 + rect_2.sizeX and
	   y1 + rect_1.sizeY > y2 and
	   y1 < y2 + rect_2.sizeY then
	   	return true
	end

	return false
end

function tools.getCollisionRect(rect_1, rect_2)
	if tools.areRectsColliding(rect_1, rect_2) then
		return {
			shape = "rect",
			x = (tools.max(rect_1.x - rect_1.sizeX/2, rect_2.x - rect_2.sizeX/2) - tools.min(rect_1.x + rect_1.sizeX/2, rect_2.x + rect_2.sizeX/2)) / 2,
			y = (tools.max(rect_1.y - rect_1.sizeY/2, rect_2.y - rect_2.sizeY/2) - tools.min(rect_1.y + rect_1.sizeY/2, rect_2.y + rect_2.sizeY/2)) / 2,
			sizeX = (rect_1.sizeX/2 + rect_2.sizeX/2) - math.abs(rect_1.x - rect_2.x),
			sizeY = (rect_1.sizeY/2 + rect_2.sizeY/2) - math.abs(rect_1.y - rect_2.y),
		}
	else
		return nil
	end
end

function tools.getVectorFromAngle(_rotation)
	return {x = math.cos(_rotation), y = math.sin(_rotation)}
end


function tools.getSign(number)
	if number < 0 then
		return -1
	else
		return 1
	end
end

-- note: better use if conditions
function tools.clamp(value, min, max)
	--return math.max(math.min(value, max), min)
	return tools.max(tools.min(value, max), min)
end

function tools.min(a, b)
	if a > b then
		return b
	else
		return a
	end
end

function tools.max(a, b)
	if a < b then
		return b
	else
		return a
	end
end

function tools.isInRange(value, min, max)
	return value >= min and value <= max
end


function tools.isPointInsideCircle(point, circle)
	return tools.getDistanceSquared({x = circle.x, y = circle.y}, {x = point.x, y = point.y}) <= circle.radius * circle.radius
end

function tools.areCirclesColliding(circle1, circle2)
	return (circle1.radius + circle2.radius) * (circle1.radius + circle2.radius) >= tools.getDistanceSquared({x = circle1.x, y = circle1.y}, {x = circle2.x, y = circle2.y})
end


-- TODO: right now assuming we have a circle and a rectangle
function tools.getCollisionPoint(circle, rect)
	if tools.areCircleAndRectColliding(circle, rect) then
		local point = {x = tools.clamp(circle.x, rect.x - rect.sizeX/2, rect.x + rect.sizeX/2), y = tools.clamp(circle.y, rect.y - rect.sizeY/2, rect.y + rect.sizeY/2)}
		return point
	else
		return nil
	end
end

-- new: check for rotated rectangles
function tools.areCircleAndRotatedRectColliding(circle, rect)

	local rx, ry, dx, dy
	local cx, cy = circle.x, circle.y
	--if rect.rotation ~= 0 then
	--	cx, cy = tools.getRotatedPoint({x = circle.x, y = circle.y}, -rect.rotation, rect.center)
	--end
	
	rx = tools.clamp(cx, rect.x - rect.sizeX/2, rect.x + rect.sizeX/2)
	ry = tools.clamp(cy, rect.y - rect.sizeY/2, rect.y + rect.sizeY/2)
	dx = cx - rx
	dy = cy - ry
	return (dx * dx + dy * dy) < (circle.radius * circle.radius)

end

-- old: only used for default rectangles (no rotation)
function tools.areCircleAndRectColliding(circle, rect)

	assert(type(circle.x) == "number", "areCircleAndRectColliding needs circle.x")
	assert(type(circle.y) == "number", "areCircleAndRectColliding needs circle.y")
	assert(type(circle.radius) == "number", "areCircleAndRectColliding needs circle.radius")
	assert(type(rect.x) == "number", "areCircleAndRectColliding needs rect.x")
	assert(type(rect.y) == "number", "areCircleAndRectColliding needs rect.y")
	
	if rect.rotation then
		return tools.areCircleAndRotatedRectColliding(circle, rect)
	end
	
	local rx, ry, dx, dy
	rx = tools.clamp(circle.x, rect.x - rect.sizeX/2, rect.x + rect.sizeX/2)
	ry = tools.clamp(circle.y, rect.y - rect.sizeY/2, rect.y + rect.sizeY/2)
	dx = circle.x - rx
	dy = circle.y - ry
	return (dx * dx + dy * dy) < (circle.radius * circle.radius), rx, ry

end

-- does not actually change the properties
function tools.getRotatedPoint(point, angle, center)
	local oldX, oldY = point.x - center.x, point.y - center.y
	local newX = oldX * math.cos(angle) - oldY * math.sin(angle) + center.x
	local newY = oldY * math.cos(angle) + oldX * math.sin(angle) + center.y
	return newX, newY
end

-- does change the rectangle properties!
function tools.rotateRectangle(rect, angle)
	rect.A.x, rect.A.y = tools.getRotatedPoint(rect.A, angle, rect.center)
	rect.B.x, rect.B.y = tools.getRotatedPoint(rect.B, angle, rect.center)
	rect.C.x, rect.C.y = tools.getRotatedPoint(rect.C, angle, rect.center)
	rect.D.x, rect.D.y = tools.getRotatedPoint(rect.D, angle, rect.center)
end


function tools.getDistance(pos1, pos2)
	return math.sqrt((pos2.x - pos1.x) * (pos2.x - pos1.x) + (pos2.y - pos1.y) * (pos2.y - pos1.y))
end

-- a little less handy but faster as it does not require a root
function tools.getDistanceSquared(pos1, pos2)
	return (pos2.x - pos1.x) * (pos2.x - pos1.x) + (pos2.y - pos1.y) * (pos2.y - pos1.y)
end


function tools.vectorGetLength(vector)
	return math.sqrt(vector.x * vector.x + vector.y * vector.y)
end


function tools.setVectorLength(vector, length)
	local newLen = length or 1
	local currLen = tools.vectorGetLength(vector)
	
	if currLen == 0 then
		print("ERROR: tools.setVectorLength - vector length is 0")
		return false
	end
	
	local vx, vy
	vx = vector.x * newLen/currLen
	vy = vector.y * newLen/currLen
	return {x = vx, y = vy}
end


function tools.trimVector(vector, maximumLength)

	local maxLen = maximumLength or 1
	local currLen = tools.vectorGetLength(vector)
	
	if currLen <= maxLen then
		-- vector already short enough
		return vector
	else
		-- vector norm too big
		local vx, vy
		vx = math.floor(vector.x * maxLen/currLen)
		vy = math.floor(vector.y * maxLen/currLen)
		return {x = vx, y = vy}
	end
	
end


function tools.vectorSub(vec_1, vec_2)
	return {x = vec_2.x - vec_1.x, y = vec_2.y - vec_1.y}
end


function tools.vectorAdd(vec_1, vec_2)
	return {x = vec_2.x + vec_1.x, y = vec_2.y + vec_1.y}
end


-- returns true if a given value can be found inside the table, false otherwise
function tools.isValueInTable(_value, _table)
	for index, value in ipairs(_table) do
		if value == _value then
			return true
		end
	end

	return false
end


function tools.round(value)
	return math.floor(value + 0.5)
end


-- get RGB relative to given health: turn from green to yellow to red (form 100% to 0% health)
-- TODO: update this in settlers!(?)
function tools.getRGBbyHealth(health)
	local R, G, B
	--[[
	if health == 100 then
		R, G, B = 0, 255, 0
	elseif health > 50 then
		R = 255 - health * 2.55
		G = 255
		B = 0
	else
		R = 255
		G = health * 5.1
		B = 0
	end
	return R/255, G/255, B/255
	--]]
	
	if health > 0.5 then
		R = 1 - health + 0.5
		G = 1
		B = 0
	else
		R = 1
		G = health * 2
		B = 0
	end
	return R, G, B
end


function tools.getRandomFromTable(t)
	assert(type(t) == "table")
	local limit = #t
	if limit < 1 then return false end
	return t[math.random(1, limit)]
end

return tools

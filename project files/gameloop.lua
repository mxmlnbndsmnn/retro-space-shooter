local Gameloop = {}

function Gameloop:create()
	local gameloop = {}
	
	-- init game loop
	gameloop.items = {}
	
	-- add an object to the loop; from now on the object will call object.tick every update
	function gameloop:add(obj)
		table.insert(self.items, obj)
	end

	-- remove an object from the loop
	function gameloop:remove(obj)
		for i = #self.items, 1, -1 do
			if self.items[i] == obj then
				table.remove(self.items, i)
				return
			end
		end
	end

	-- update the game loop
	function gameloop:update(dt)
		for i = 1,#self.items do
			local obj = self.items[i]
			if obj ~= nil
			and (obj.runWhenPaused or not PAUSED) then
				obj:tick(dt)
			end
		end
	end
	
	return gameloop
end

return Gameloop
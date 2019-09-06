local randomBag = {}
local random = love.math.random

--[[
	randomly select an item from a list
	their chances of getting selected can be defined when adding an entry
	right now there is no removing or editing of items/their chances --> clear the bag and put everything back in...
--]]


function randomBag:create()
	local rb = { items = {}, sum = 0 }
	
	function rb:add(item, weight)
		self.sum = self.sum + weight
		table.insert(self.items, { object = item, weightedSum = self.sum })
	end
	
	function rb:getRandom()
		local randi = random(1, self.sum)
		for i = 1, #self.items do
			if self.items[i].weightedSum >= randi then
				return self.items[i].object
			end
		end
		return false
	end
	
	function rb:clear()
		self.items = {}
		self.sum = 0
	end
	
	return rb
end

return randomBag

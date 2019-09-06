local Renderer = {}

local lg = love.graphics

-- drawing layers:
local numLayers = 5
-- background (image, maybe moving stars etc?)
LAYER_BG = 1
-- player
LAYER_PLAYER = 2
-- enemies
LAYER_ENEMIES = 3
-- bullets/rockets
LAYER_BULLETS = 4
-- GUI
LAYER_GUI = 5

function Renderer:create()
	local renderer = {}
	
	renderer.screenSize = { height = lg.getHeight(), width = lg.getWidth() }
	
	renderer.layers = {}
	for i = 1, numLayers do
		renderer.layers[i] = {}
	end
	
	-- NOTE: we do not need getWorldPosition when we are not using a camera...
	renderer.screenWorldRect = { x = SCREEN.width * 0.5, y = SCREEN.height * 0.5 }	--tools.getWorldPosition( { x = SCREEN.width * 0.5, y = SCREEN.height * 0.5 } )
	renderer.screenWorldRect.shape = "rect"
	local topLeftCorner = { x = 0, y = 0 }	--tools.getWorldPosition( { x = 0, y = 0 } )
	renderer.screenWorldRect.sizeX = (renderer.screenWorldRect.x - topLeftCorner.x) * 2.2	-- experimental value; 2 = occupy exactly the entire SCREEN (not enought though)
	renderer.screenWorldRect.sizeY = (renderer.screenWorldRect.y - topLeftCorner.y) * 2.2
	
	function renderer:onScreenSizeChanged()
		self.screenSize.height = lg.getHeight()
		self.screenSize.width = lg.getWidth()
		
		self.screenWorldRect = { x = SCREEN.width * 0.5, y = SCREEN.height * 0.5 }	--tools.getWorldPosition( { x = SCREEN.width * 0.5, y = SCREEN.height * 0.5 } )
		self.screenWorldRect.shape = "rect"
		local topLeftCorner = { x = 0, y = 0 }	--tools.getWorldPosition( { x = 0, y = 0 } )
		self.screenWorldRect.sizeX = (self.screenWorldRect.x - topLeftCorner.x) * 2.2	-- experimental value; 2 = occupy exactly the entire SCREEN (not enought though)
		self.screenWorldRect.sizeY = (self.screenWorldRect.y - topLeftCorner.y) * 2.2
	end
	
	
	function renderer:add(obj, layer)
		local layer = layer or LAYER_BULLETS
		if obj.visible == nil then obj.visible = true end
		table.insert(self.layers[layer], obj)
	end
	
	
	function renderer:remove(obj)
		for layer = numLayers, 1, -1 do
			for i = #self.layers[layer], 1, -1 do
				if self.layers[layer][i] == obj then
					table.remove(self.layers[layer], i)
					return
				end
			end
		end
	end
	
	
	function renderer:draw()
		
		if PAUSED then
			lg.setColor(255, 255, 255, 55)
		else
			lg.setColor(255, 255, 255, 255)
		end
		
		-- simple borders (debug?)
		lg.setLineWidth(2)
		lg.line(0, SCREEN.height * 0.05, SCREEN.width, SCREEN.height * 0.05)
		lg.line(0, SCREEN.height * 0.65, SCREEN.width, SCREEN.height * 0.65)
		lg.setLineWidth(1)
		--lg.line(SCREEN.width * 0.05, 0, SCREEN.width * 0.05, SCREEN.height)
		--lg.line(SCREEN.width * 0.95, 0, SCREEN.width * 0.95, SCREEN.height)
		lg.setColor(20, 20, 30, 255)
		lg.rectangle("fill", 0, 0, SCREEN.width, SCREEN.height * 0.05)
		lg.rectangle("fill", 0, SCREEN.height * 0.65, SCREEN.width, SCREEN.height * 0.65)
		lg.setColor(255, 255, 255, 255)
		
		for layer = 1, numLayers - 1 do
			for i = 1, #self.layers[layer] do
				local obj = self.layers[layer][i]
				if obj.rendererDisableHide or obj.visible and obj.getPosition and tools.isPointInsideRect( obj:getPosition(), self.screenWorldRect ) then
					-- only draw when the object is on the SCREEN (rectangle)
					-- or when something should always be drawn (eg. background)
					obj:draw()
				end
			end
		end
		
		-- draw UI
		for i = 1, #self.layers[numLayers] do
			local obj = self.layers[numLayers][i]
			if obj.visible then
				obj:draw()
			end
		end
	end
	
	
	return renderer
end


return Renderer

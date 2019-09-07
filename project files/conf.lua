function love.conf(t)
	t.console = true
	t.externalstorage  = true	-- this must be true if we want to use love.filesystem.setIdentity
	
	t.window.vsync	= 1
	t.window.msaa	= 2
	
	-- disable modules that are not needed here
	t.modules.physics	= false
	t.modules.joystick 	= false
	t.modules.video		= false
end

local Soundmanager = {}
local la = love.audio

function Soundmanager:create()
	local sm = {}
	
	sm.sounds = {}
	-- music is loaded as stream
	sm.sounds["music"] = {
	
	}
	-- normal sounds are static
	sm.sounds["game"] = {
		shoot1 = love.audio.newSource("sounds/alien_shoot_1.mp3", "static"),
		shoot2 = love.audio.newSource("sounds/alien_shoot_2.mp3", "static"),
		shoot3 = love.audio.newSource("sounds/alien_shoot_3.mp3", "static"),
		explosion = love.audio.newSource("sounds/explosion.mp3", "static"),
		click1 = love.audio.newSource("sounds/click_1.mp3", "static"),
	}
	
	sm.sounds["game"].shoot1:setVolume(0.4)
	sm.sounds["game"].shoot2:setVolume(0.3)
	sm.sounds["game"].shoot3:setVolume(0.4)
	
	-- note: game sounds only (use another method for music)
	function sm:playSound(name)
		if not SOUNDS then
			return
		end
		
		local source = self.sounds["game"][name]
		if source then
			source:clone():play()
		else
			print("error: cannot find sound", name)
		end
	end
	
	return sm
end


return Soundmanager

RESOURCE_DIR = "sensibilia\\resources\\" 

menu_music = sfMusic()
menu_music:openFromFile(RESOURCE_DIR .. "menu.ogg")

level_music = sfMusic()
level_music:openFromFile(RESOURCE_DIR .. "pulsating.ogg")
level_music:setLoop(true)

button_clicked_snd = sfSoundBuffer()
button_clicked_snd:loadFromFile(RESOURCE_DIR .. "select.ogg")

global_sound_table = {}

function play_sound(what_buffer)
	new_sound = sfSound()
	new_sound:setBuffer(what_buffer)
	new_sound:setVolume(100)
	new_sound:play()
	
	local i = 1
	while i <= #global_sound_table do
		if has_sound_stopped_playing(global_sound_table[i]) then
			table.remove(global_sound_table, i)
		else
			i = i + 1
		end
	end
	
	table.insert(global_sound_table, new_sound)
end
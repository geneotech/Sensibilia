RESOURCE_DIR = "sensibilia\\resources\\" 


global_music_table = {}

function create_music(filename)
	local new_music = sfMusic()
	new_music:openFromFile(RESOURCE_DIR .. filename)
	new_music:setLoop(true)
	
	table.insert(global_music_table, new_music)
	
	return new_music
end

function create_sound(filename)
	local new_sound = sfSoundBuffer()
	new_sound:loadFromFile(RESOURCE_DIR .. filename)
	return new_sound
end

function stop_all_music()
	for i=1, #global_music_table do
		global_music_table[i]:stop()
	end
end

menu_music = create_music "menu.ogg"
level_music = create_music "pulsating.ogg"
level2_music = create_music "drone2.ogg"
level3_music = create_music "drone3.ogg"
clock_music = create_music "clock.wav"
button_clicked_snd = create_sound "select.ogg"

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
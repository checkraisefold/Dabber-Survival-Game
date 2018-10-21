#define MUSIC_CHANNEL 1
var/list/tension_low = list('sound/Peaceful.ogg',"sound/Epic.ogg","sound/Wario.ogg","sound/Mario64.ogg")
var/list/tension_high = list('sound/Raid.ogg',"sound/Raid2.ogg")
client
	var/tension = 0
	var/is_high_tension = 0
	var/music_timer = 0
	var/music_vol = 0
	var/sound/music = null
	proc/ProcessMusic()
		music_timer -= world.tick_lag/10
		if(music_timer < 0)
			if(music_vol > 0)
				music_vol -= world.tick_lag*5
			else
				src << sound(null,channel = MUSIC_CHANNEL)
				music_vol = 100
				music_timer = 120
				music = sound(is_high_tension ? pick(tension_high) : pick(tension_low),channel = MUSIC_CHANNEL,repeat = 1)
				src << music
				music.status = SOUND_UPDATE
		if(tension > 0)
			tension -= world.tick_lag/10
		if(tension > 50 && is_high_tension == 0)
			is_high_tension = 1
			music_timer = 0
		if(tension <= 50 && is_high_tension == 1)
			is_high_tension = 0
			music_timer = 0
		if(music)
			music.volume = music_vol*music_mult
		src << music
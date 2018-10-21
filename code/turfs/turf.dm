var/list/free_turfs = list()
turf
	icon = null
	mouse_opacity = 2
	var/health = 1
	proc/TakeDamageTurf(dmg)
		if(istype(src,/turf/wall))
			health -= dmg
			world << sound("sound/galvin1.ogg")
			if(health < 0)
				del src
	water
		alpha = 0
		density = 1
	dirt
		icon = 'icons/floors/dirt.dmi'
		icon_state = "0,0"
		layer = 1.5
		New()
			..()
			free_turfs += src
			icon_state = "[x % 16],[y % 16]"
			if(prob(50))
				var/image/G = new()
				G.icon = 'icons/floors/dirt.dmi'
				G.icon_state = "g[rand(1,2)]"
				var/matrix/M = matrix()
				M.Scale(0.5)
				M.Translate(-16,-16)
				G.transform = M
				G.pixel_x = rand(-32,64)
				G.pixel_y = rand(-32,64)
				G.layer = 1.75
				overlays += G
		Del()
			free_turfs -= src
			..()
	floor //rimworld uses 1024x1024 stuff for this, so we have to use a special method
		var/tilesize = 16
		New()
			..()
			icon_state = "[x % tilesize],[y % tilesize]"
		wood
			icon = 'icons/floors/wood.dmi'
		storage
			tilesize = 8
			icon = 'icons/floors/cement.dmi'
	wall
		density = 1
		layer = 2.5
		proc/auto_smooth(var/t = "")
			var/bit = 0
			for(var/d in list(NORTH,SOUTH,EAST,WEST))
				var/turf/wall/D = get_step(src,d)
				if(D.type == type)
					bit += d
			icon_state = "[t][bit]"
		granite
			icon = 'walls.dmi'
			icon_state = "granite"
			color = "#808080"
			health = 1000
			New()
				..()
				var/image/dirt = new()
				dirt.icon = 'icons/floors/dirt.dmi'
				dirt.icon_state =  "[x % 16],[y % 16]"
				dirt.layer = 1.5
				dirt.appearance_flags = RESET_COLOR
				underlays += dirt
				for(var/turf/wall/granite/G in range(1,src))
					G.auto_smooth("")
			Del()
				for(var/turf/wall/granite/G in range(1,src))
					G.auto_smooth("")
				..()
		wood
			icon = 'walls.dmi'
			icon_state = "0"
			color = rgb(82,60,41)
			health = 500
			New()
				..()
				var/image/dirt = new()
				dirt.icon = 'icons/floors/dirt.dmi'
				dirt.icon_state =  "[x % 16],[y % 16]"
				dirt.layer = 1.5
				dirt.appearance_flags = RESET_COLOR
				underlays += dirt
				for(var/turf/wall/wood/G in range(1,src))
					G.auto_smooth("")
			Del()
				for(var/turf/wall/wood/G in range(1,src))
					G.auto_smooth("")
				..()
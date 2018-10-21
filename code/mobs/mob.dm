mob
	var/health = 100
	var/maxhealth = 100
	var/dead = 0
	var/offs = 0
	var/nutrition = 100
	var/obj/overlay/nametag = null
	step_size = 4
	human
		sight = SEE_TURFS | SEE_OBJS | SEE_MOBS | SEE_THRU
		desc = "It's a Human." //Add_Alert(var/text,var/sound = 'Notification.wav',var/col)
		New()
			..()
			spawn()
				offs = rand(1,60)
				Land()
		proc/Nametag()
			if(!nametag)
				nametag = new()
			nametag.maptext = "<text align=center>[name]"
			nametag.maptext_width = 64*5
			nametag.maptext_x = 64*-2
			nametag.maptext_y = 60
			nametag.layer = 20
			overlays += nametag
		proc/Clothes()
			overlays = list()
			var/image/Clothing = new()
			Clothing.icon = 'icons/mobs/human.dmi'
			Clothing.icon_state = "overlay_s"
			var/image/Clothing2 = new()
			Clothing2.icon = 'icons/mobs/human.dmi'
			Clothing2.icon_state = "overlay2_s"
			var/matrix/M = matrix()
			M.Scale(2)
			M.Translate(33,32)
			Clothing2.transform = M
			Clothing.transform = M
			Clothing.color = list(null,null,null,rgb(rand(0,255),rand(0,255),rand(0,255)))
			overlays += Clothing
			overlays += Clothing2
		proc/TakeDamage(dmg)
			health -= dmg
			world << sound("sound/galvin1.ogg")
			if(health <= 0)
				if(dead == 0)
					dead = 1
					var/matrix/M = matrix()
					M.Turn(90)
					animate(src,transform = M, time = 10)
					density = 0
					for(var/client/i in clients)
						i.Add_Alert("Death : [name]",'AlarmUrgent.wav',"#FFFF80")
					spawn()
						if(client)
							sleep(20)
							Land()
		proc/Land()
			density = 0
			nutrition = 100
			health = maxhealth
			overlays = list()
			dead = 0
			transform = matrix()
			pixel_z = 17*64
			icon = null
			pixel_x = -32
			pixel_y = -32
			loc = find_free_turf()
			if(client)
				client.camera_x = x*64
				client.camera_y = y*64
			sleep(rand(1,20))
			src << 'Start.wav'
			sleep(20)
			icon = 'icons/mobs/pod.dmi'
			animate(src,pixel_z = 0, time = 15, easing = QUAD_EASING|EASE_OUT)
			sleep(20)
			density = 1
			Clothes()
			Nametag()
			world << 'DropPodOpen.wav'
			icon = 'icons/mobs/human.dmi'
			icon_state = "human"
			pixel_x = 0
			pixel_y = 0
		angery_ai
			name = "AI"
			desc = "It's angry at you."
			var/mob/human/enemy = null
			var/processi = 0
			New()
				..()
				AIs += src
				name = "[pick("Javier","Jose","Ikea","Martin")]"
			Del()
				AIs -= src
				..()
			process()
				spawn()
					if(health > 0)
						if(processi == 0)
							processi = 1
							if(icon_state == "human")
								SearchForEnemy()
								if(enemy)
									var/turf/T = get_step(enemy,enemy.dir)
									WalkTo(T.x,T.y)

							processi = 0
						else
							if(enemy)
								if(get_dist(src,enemy) <= 1 && (frame + offs) % 50 == 1)
									enemy.TakeDamage(5)
					else
						alpha -= 1
						if(alpha <= 0)
							del src
			proc/SearchForEnemy()
				if(!enemy)
					for(var/mob/human/G in orange(5,src))
						if(G.health > 0)
							enemy = G
				else
					if(enemy.health <= 0)
						enemy = null
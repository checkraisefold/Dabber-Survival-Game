var
	const
		ARROWS = "|west|east|north|south|"
		GAMEPAD = "|GamepadUp|GamepadDown|GamepadLeft|GamepadRight|GamepadUpRight|GamepadUpLeft|GamepadDownRight|GamepadDownLeft|GamepadFace1|GamepadFace2|GamepadFace3|GamepadFace4|GamepadSelect|"
		NUMPAD = "|west|east|north|south|northeast|southeast|northwest|southwest|center|numpad0|numpad1|numpad2|numpad3|numpad4|numpad5|numpad6|numpad7|numpad8|numpad9|divide|multiply|subtract|add|decimal|"
		EXTENDED = "|space|shift|ctrl||escape|return|tab|back|delete|insert|"
		PUNCTUATION = "|`|-|=|\[|]|;|'|,|.|/|\\|"
		FUNCTION = "|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|"
		LETTERS = "|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|"
		NUMBERS = "|0|1|2|3|4|5|6|7|8|9|"

		ALL_KEYS = NUMPAD + EXTENDED + FUNCTION + LETTERS + NUMBERS + PUNCTUATION + GAMEPAD

atom/proc/RightClicked(var/mob/M)
#define MULT_TIME 1/32
proc
	split(txt, d)

		var/pos = findtext(txt, d)
		var/start = 1
		var/dlen = length(d)

		. = list()

		while(pos > 0)
			. += copytext(txt, start, pos)
			start = pos + dlen
			pos = findtext(txt, d, start)

		. += copytext(txt, start)


obj
	screen_object
		plane = HUD_PLANE
		screen_loc = "1,1"
		icon = 'icons/hud/screen.dmi'
		appearance_flags = PIXEL_SCALE | TILE_BOUND
		mouse_opacity = 0
		hud_object
			icon_state = "no"
		select
			icon_state = "select"
		first_point
			icon_state = "first_point"
		white_selection
			icon_state = "white_select"

		hud_mob
			icon_state = "bg"
			see_player
				screen_loc = "1,1 to 5,3"
		text_object
			maptext_x = 10
			maptext_y = 10
			layer = 5
		hud_bar
			icon = 'bars.dmi'
			layer = 4.5
			icon_state = "bar"
			color = "#000000"
		plane_master_water
			appearance_flags = PIXEL_SCALE | TILE_BOUND | PLANE_MASTER
			plane = WATER_PLANE
			mouse_opacity = 0
		water
			plane = WATER_PLANE
			icon = 'icons/floors/water.dmi'
			mouse_opacity = 0
		lighting_master
			screen_loc 			= "1,1"
			plane 				= LIGHTING_PLANE
			blend_mode 			= BLEND_MULTIPLY
			appearance_flags 	= PLANE_MASTER | NO_CLIENT_COLOR
			mouse_opacity 		= 0
		lighting_cover
			icon			= 'lighting.dmi'
			icon_state		= "black"
			screen_loc		= "SOUTHWEST to NORTHEAST"
			plane			= LIGHTING_PLANE
			mouse_opacity 	= 0

#define INTERACT 0
#define ATTACK 1

client
	var
		atom/first_point = null
		atom/second_point = null
		mouse_x = 0
		mouse_y = 0
		mouse_d = 0
		camera_x = 64
		camera_y = 64

		last_attack = 0
		music_mult = 1

		mode = ATTACK

		list/keys = list() //list of pressed keys............
		obj/screen_object/select/selection = null
		obj/screen_object/first_point/first_po = null
		obj/screen_object/white_selection/right_click = null

		obj/screen_object/text_object/object_name = null
		obj/screen_object/text_object/object_desc = null

		obj/screen_object/text_object/hud_bar_num = null
		obj/screen_object/text_object/hud_bar_num_h = null
		obj/screen_object/plane_master_water/water_master = null
		obj/screen_object/lighting_master/lighting_master = null
		obj/screen_object/lighting_cover/cover = null

		list/alerts_hud = list()

		list/hud_bar_health = list()
		list/hud_bar_hunger = list()

		list/hud_mobs = list()

		list/hud_inv = list()

		list/materials_player = list()

		list/water_huds = list()

		current_selected_type = null
		atom/movable/focused_object = null
	//New() handles stuff when the clients join
	verb/Suicide()
		if(mob)
			if(mob.health > 0)
				mob:TakeDamage(mob.health)
	verb/Chat()
		var/t = input("Say something!") as null|text
		if(t)
			world << "<b>[key] : [t]"
			world << 'beep.wav'
	proc/Change_Building()
		current_selected_type = input("What do you want to build?") as null|anything in list("Destroy")+buildable
	New()
		..()
		if(!mouse_position)
			mouse_position = new(src)
		selection = new()
		first_po = new()
		right_click = new()
		object_name = CreateScreenText("1,3",64*5)
		object_desc = CreateScreenText("1,2:16",64*5)
		hud_bar_num = CreateScreenText("1:1,3:[-41+20]",64*4)
		hud_bar_num_h = CreateScreenText("1:[1+110],3:[-41+20]",64*4)
		CreateHudBar(hud_bar_health,100,"#232323",10,192-76)
		CreateHudBar(hud_bar_hunger,100,"#824700",10+110,192-76)
		for(var/i in typesof(/obj/screen_object/hud_mob)-/obj/screen_object/hud_mob)
			var/obj/screen_object/hud_mob/G = new i()
			hud_mobs += G
		var/offs = 2
		for(var/i in mob.owned_items)
			offs -= 1
			materials_player += i
			materials_player[i] = CreateScreenObject("1,NORTH:[offs*32]",'icons/obj/items.dmi',i)
			var/matrix/M = matrix()
			M.Scale(0.5)
			M.Translate(-16,-16)
			materials_player[i]:maptext_x = 64
			materials_player[i]:maptext_y = 8
			materials_player[i]:maptext_width = 128
			materials_player[i]:transform = M
			hud_inv += materials_player[i]
		water_master = new()
		lighting_master = new()
		cover = new()
		InitHud()
		set_macros()
		clients += src
		Generate_Parallax()
	//Del() handles stuff when the clients leave
	Del()
		if(src in clients)
			clients -= src
		..()
	//Procs
	verb
		KeyDown(k as text)
			set hidden = 1
			set instant = 1
			//src << "KEY DOWN : [k]"
			keys[k] = 1
			if(k == "b")
				Change_Building()
			if(k == "t")
				Chat()
			if(k == "l")
				camera_x = mob.x*64
				camera_y = mob.y*64
				focused_object = mob
			if(k == "m")
				music_mult = !music_mult
			if(k == "c")
				mode = !mode
				src << "You switch to [mode ? "attack" : "interact"] mode."
		KeyUp(k as text)
			set hidden = 1
			set instant = 1
			//src << "KEY UP : [k]"
			keys[k] = 0
	proc
		Generate_Parallax()
			for(var/x in 0 to 4)
				for(var/y in 0 to 3)
					var/matrix/M = matrix()
					M.Translate(x*512,y*512)
					var/obj/screen_object/water/G = new()
					G.transform = M
					water_huds += G

		Update_Materials()
			for(var/i in mob.owned_items)
				materials_player[i]:maptext = "<font size=8>[mob.owned_items[i]]"
		Add_Alert(var/text,var/sound = 'Notification.wav',var/col)
			var/matrix/M = matrix()
			M.Translate(0,64*17)
			var/obj/screen_object/text_object/G = CreateScreenText("EAST-4:-12,1",64*4)
			G.maptext = "<text align=right>[text]"
			G.maptext_y = 8
			G.maptext_x = 64
			G.transform = M
			var/image/let = new()
			let.icon = 'screen.dmi'
			let.icon_state = "letter"
			let.color = col
			let.pixel_x = 64*4
			G.underlays += let
			alerts_hud += G
			src << sound(sound)
			reorganize_alerts()
			spawn(100)
				alerts_hud -= G
				del G
				reorganize_alerts()
		reorganize_alerts()
			spawn()
				var/offs = -1
				for(var/obj/screen_object/g in alerts_hud)
					offs += 1
					var/matrix/M = matrix()
					M.Translate(0,12+(offs*42))
					animate(g,transform = M,time = 10,easing = QUAD_EASING | EASE_IN)
		set_macros()
			// this should get us the list of all macro sets that
			// are used by all windows in the interface.
			var/macros = params2list(winget(src, null, "macro"))
			var/list/Keys_To_Set = list()

			// if the keys var is a string, split it into key names
			if(istext(ALL_KEYS))
				Keys_To_Set = split(ALL_KEYS, "|")

			for(var/m in macros)
				for(var/k in Keys_To_Set)

					if(!k) continue

					keys[k] = 0

					var/escaped = list2params(list("[k]"))

					// Create the necessary macros for this key.
					winset(src, "[m][k]Down", "parent=[m];name=[escaped];command=KeyDown+[escaped]")
					winset(src, "[m][k]Up", "parent=[m];name=[escaped]+UP;command=KeyUp+[escaped]")
		CreateScreenObject(var/screen_loc,var/ico,var/icon_stat)
			var/obj/screen_object/hud_object/G = new()
			G.screen_loc = screen_loc
			G.icon = ico
			G.icon_state = icon_stat
			return G
		CreateScreenText(var/screen_loc,var/maptext_width)
			var/obj/screen_object/text_object/G = new()
			G.screen_loc = screen_loc
			G.maptext_width = maptext_width
			return G
		CreateHudBar(var/list/Hud_Bar_Complete,var/length = 0,var/bar_color = "#FFFFFF",var/xoff,var/yoff)
			var/matrix/M = matrix()
			length = max(0,length)
			M.Scale(length,1) //Epic Game
			M.Translate(length/2,0)
			var/obj/screen_object/hud_bar/G1 = new()
			G1.transform = M
			var/obj/screen_object/hud_bar/G2 = new()
			G2.transform = M
			G1.color = "#000000"
			G2.color = bar_color
			G1.screen_loc = "1:[xoff],1:[yoff]"
			G2.screen_loc = "1:[xoff],1:[yoff]"
			Hud_Bar_Complete += length
			Hud_Bar_Complete += G1
			Hud_Bar_Complete += G2
		AdjustHudBar(var/list/hud_bar,var/bar_amount = 0)
			var/length = max(0,min(hud_bar[1],bar_amount))
			var/matrix/M = matrix()
			M.Scale(length,1)
			M.Translate(length/2,0)
			hud_bar[3]:transform = M
		InitHud()
			screen += selection
			screen += first_po
			screen += right_click
			screen += alerts_hud
			screen += hud_inv
			screen += water_master
			screen += water_huds
			screen += lighting_master
			screen += cover
		ProcessClient()
			screen = list()
			InitHud()
			if(mouse_position)
				screen += mouse_position.MouseCatcher
			//255, 207, 158
			//31, 21, 91
			//sin(frame)*(255-31)
			//sin(frame)*(207-21)
			//sin(frame)*(158-91)
			cover.color = rgb(255-(sin(frame*MULT_TIME)*(255-31)),207-(sin(frame*MULT_TIME)*(207-21)),158-(sin(frame*MULT_TIME)*(158-91)))
			cover.alpha = 50+(sin(frame*MULT_TIME)*150)
			first_po.alpha = first_point ? 255 : 0
			right_click.alpha = 0 //focused_object ? 255 : 0
			camera_x += (keys["east"]+keys["d"]-keys["west"]-keys["a"])*(6+(keys["shift"]*6))
			camera_y += (keys["north"]+keys["w"]-keys["south"]-keys["s"])*(6+(keys["shift"]*6))
			camera_x = min((world.maxx*64)-608+32,max(608+32,camera_x))
			camera_y = min((world.maxy*64)-480+32,max(480+32,camera_y))
			if(mouse_position)
				mouse_position.Moved()
			if(mob)
				if(mob.nutrition > 0)
					mob.nutrition -= world.tick_lag/45
					if(mob.nutrition > 100)
						mob.nutrition = 100
					if(mob.nutrition > 75)
						mob.health += world.tick_lag/20
						if(mob.health > mob.maxhealth)
							mob.health = mob.maxhealth
				else
					if(frame % 10 == 1)
						mob:TakeDamage(10)

			ProcessMusic()
			Update_Materials()
			eye = locate(camera_x/64,camera_y/64,1)
			pixel_x = camera_x % 64
			pixel_y = camera_y % 64

			var/matrix/M = matrix()
			M.Translate(-bound_x % 512,-bound_y % 512)
			water_master.transform = M

			selection.alpha = current_selected_type ? 255 : 0
			selection.screen_loc = "1:[round(mouse_x-32,64)+1-bound_x],1:[round(mouse_y-32,64)+1-bound_y]"

			if(first_point)
				first_po.screen_loc = "1:[((first_point.x-1)*64)+1-bound_x],1:[((first_point.y-1)*64)+1-bound_y]"
			//if(focused_object)
				//right_click.screen_loc = "1:[((focused_object.x+(focused_object.step_x/64)-1)*64)+1-bound_x],1:[((focused_object.y+(focused_object.step_y/64)-1)*64)+1-bound_y]"
			if(focused_object)
				object_name.maptext = "<font size=8>The [focused_object.name]"
				object_desc.maptext = "<font size=2>[focused_object.desc]"
				screen += hud_mobs+object_name+object_desc
				if(istype(focused_object,/mob))
					//world << "Adjusting hud health"
					//hud_bar_hunger
					AdjustHudBar(hud_bar_hunger,(focused_object:nutrition/100)*hud_bar_hunger[1])
					screen += hud_bar_hunger[2]
					screen += hud_bar_hunger[3]
					hud_bar_num_h.maptext = "<font color=#FFFFFF>Hunger"
					screen += hud_bar_num_h

					AdjustHudBar(hud_bar_health,(focused_object:health/focused_object:maxhealth)*hud_bar_health[1])
					screen += hud_bar_health[2]
					screen += hud_bar_health[3]
					if(focused_object:health < 100)
						if(focused_object:health <= 0)
							hud_bar_num.maptext = "<font color=#E6E6E6>Dead"
						else
							hud_bar_num.maptext = "<font color=#E6E6E6>Injured"
					else
						hud_bar_num.maptext = "<font color=#E6E6E6>Healthy"
					screen += hud_bar_num
					//focused_object:health -= 1

	//Mouse stuff, will port to MC later.
	MouseDown(atom/object,location,control,params)
		..()
		params=params2list(params)
		if(params["right"])
			if(current_selected_type)
				if(istype(object,/atom/movable) && object.z != 0)
					focused_object = object
				else
					focused_object = null
			else
				if(istype(object,/obj))
					object.RightClicked(mob)
				else
					if(focused_object == mob)
						if(mob:health > 0 && mob:can_event == 1)
							spawn()
								focused_object:WalkTo(object.x, object.y)
		if(params["left"])
			mouse_d = 1
			if(current_selected_type)
				if(object)
					first_point = object
				else
					first_point = null
			else
				if(object != mob)
					if(mode == ATTACK)
						if(mob.slot_0)
							if(mob.slot_0.weapon_type == RANGED)
								//for ranged weapons, do not call the melee shit.
								world << "Firing"
								var/obj/projectile/to_shoot = new(mob.loc)
								to_shoot.owner = src
								to_shoot.dmg = mob.slot_0.attack_damage
								to_shoot.ang = atan2(mob,location)
								return
						if(istype(object,/mob))
							if(get_dist(mob,object) <= 1)
								if(world.time > last_attack + 2)
									object:TakeDamage(5+(mob.slot_0 ? mob.slot_0.attack_damage : 0))
									last_attack = world.time
	DblClick(atom/object,location,control,params)
		if(!current_selected_type)
			if(istype(object,/atom/movable) && object.z != 0)
				focused_object = object
			else
				focused_object = null
	MouseUp(atom/object,location,control,params)
		..()
		params = params2list(params)
		if(params["left"])
			mouse_d = 0
			if(current_selected_type)
				second_point = object
				if(second_point && first_point)
					spawn()
						var/x1 = first_point.x
						var/y1 = first_point.y
						var/x2 = second_point.x
						var/y2 = second_point.y
						if(!x1 || !y1 || !x2 || !y2)
							src << "<b><font color='red'>Error"
						first_point = null
						second_point = null
						if(current_selected_type == "Destroy")
							for(var/i in min(x1, x2) to max(x1, x2))
								for(var/e in min(y1, y2) to max(y1, y2))
									var/obj/build_project/proj = new(locate(i,e,1))
									proj.what_to_build = "Destroy"
									proj.Init()
									proj.owner = mob
									var/datum/game_event/start_project/PROJECT = Scheduler.Add_Event(/datum/game_event/start_project,mob)
									PROJECT.proj = proj
							return

						if(current_selected_type in buildable)
							for(var/i in min(x1, x2) to max(x1, x2))
								for(var/e in min(y1, y2) to max(y1, y2))
									if(locate(/obj/build_project) in locate(i,e,1))
										src << "You cannot build here! There's already a project."
										continue
									else
										var/obj/build_project/proj = new(locate(i,e,1))
										proj.what_to_build = current_selected_type
										proj.Init()
										proj.owner = mob
										var/datum/game_event/start_project/PROJECT = Scheduler.Add_Event(/datum/game_event/start_project,mob)
										PROJECT.proj = proj

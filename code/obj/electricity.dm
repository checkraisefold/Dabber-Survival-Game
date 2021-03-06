#define DIAGONALS list("5" = NORTHEAST,"9" = NORTHWEST,"6" = SOUTHEAST,"10" = SOUTHWEST)

/obj/electricity
	icon = 'icons/obj/electricity.dmi'
	var/power_stored = 0 //Amount of power stored
	var/power_max = 40 //Maximum
	New()
		..()
		electricity += src
	Del()
		electricity -= src
		..()
	proc
		spend_power(amount)
			if(power_stored >= amount)
				power_stored -= amount
				return 1
			else
				return 0 //most cases will shut off
	power
		name = "Powered Object"
	generator
		name = "Generator"
		icon = 'icons/obj/generator.dmi'
		process()
			for(var/d in list(NORTH,SOUTH,EAST,WEST))
				var/obj/electricity/pipe/G = locate(/obj/electricity/pipe) in get_step(src,d)
				if(istype(G,/obj/electricity/pipe))
					G.Beat(d,20)
	pipe
		name = "Electrical Pipe"
		icon_state = "0"
		var/connected_dirs = 0
		mouse_opacity = 2
		New()
			..()
			spawn(1)
				for(var/obj/electricity/pipe/G in range(1,src))
					G.AutoJoinInRange()
		proc
			AutoJoinInRange()
				overlays = null
				for(var/d in list(NORTH,SOUTH,EAST,WEST))
					var/obj/electricity/pipe/G = locate(/obj/electricity/pipe) in get_step(src,d)
					if(istype(G,/obj/electricity/pipe))
						var/image/ov = new()
						ov.icon = 'icons/obj/electricity.dmi'
						ov.icon_state = "[d]"
						connected_dirs += d
						overlays += ov
			Beat(direction,power)
				CHECK_TICK //This is a laggy.
				power_stored += power
				var/obj/electricity/power/pow = locate(/obj/electricity/power) in loc
				var/obj/electricity/pipe/G = locate(/obj/electricity/pipe) in get_step(src,direction)
				if(istype(pow,/obj/electricity/power))
					//powered object
					power = power/2
					pow.power_stored += power
					if(pow.power_stored > pow.power_max)
						pow.power_stored = pow.power_max
					power_stored -= power
				if(istype(G,/obj/electricity/pipe))
					G.power_stored += power
					power_stored -= power
					spawn(1)
						if("[G.connected_dirs]" in DIAGONALS)
							var/origdir = direction
							//world << "ELECTRICITY DEBUG : FOUND DIAGONAL - [dir2txt_3(direction)], MINUS [dir2txt_3(DIAGONALS["[G.connected_dirs]"])]"
							direction = DIAGONALS["[G.connected_dirs]"]-turn(origdir, 180)
						//color = "#0000FF"
						//world << "ELECTRICITY DEBUG : HEADING OVER FOR [dir2txt_3(direction)]"
						G.Beat(direction,power)
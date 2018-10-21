/obj/tree
	density = 1
	icon = 'trees.dmi'
	pixel_x = -64
	layer = MOB_LAYER+1
	var/health = 15
	RightClicked(mob/M)
		var/datum/game_event/cut_tree/EV = Scheduler.Add_Event(/datum/game_event/cut_tree,M)
		EV.proj = src

/datum/game_event/cut_tree
	//project, aka what makes the mob walk to a tile and start building crap.
	var/obj/tree/proj = null
	DoEvent()
		if(istype(owner,/mob))
			if(proj)
				var/turf/location = get_step(proj.loc,pick(NORTH,SOUTH,WEST,EAST))
				if(location)
					if(owner:WalkTo(location.x,location.y))
						while(proj && proj.health > 0)
							proj.health -= world.tick_lag
							if(frame % 20 == 1)
								world << sound("sound/woodBuild[rand(1,4)].wav")
							sleep(world.tick_lag)
						new /obj/item/material/wood(proj.loc)
						del proj
					else
						return 1
				else
					return 1
			else
				return 1
		else
			return 1
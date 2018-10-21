var/list/buildable = list(
"Wood Floor" = list(/turf/floor/wood,"wood",1,3),
"Wood Wall" = list(/turf/wall/wood,"wood",2,5),
"Granite Wall" = list(/turf/wall/granite,"granite",2,5),
"Lamp" = list(/obj/lamp,"granite",5,10),
"Red Lamp" = list(/obj/lamp/redlamp,"granite",5,10),
"Door" = list(/obj/door,"wood",5,10),
"Electricity Pipe" = list(/obj/electricity/pipe,"granite",2,7),
"Storage Floor" = list(/turf/floor/storage,"wood",0,1)
)
var/list/materials = list(
"wood",
"granite"
)

#define REQUIRED_DISTANCE 3
/atom
	var/ownerofthis = null
	var/built = 0
	Del()
		if(ownerofthis)
			ownerofthis:owned_stuff -= src
		..()
/turf/floor/storage
	Del()
		if(ownerofthis)
			ownerofthis:storages -= src
		..()
/obj/build_project
	//Build project.
	var
		build_progress = 0
		build_progress_required
		path_to_object
		material_cost
		material_type
		what_to_build
		old_ico = ""
		owner
	icon = 'screen.dmi'
	icon_state = "build4x4"
	plane = HUD_PLANE
	proc/Check_Finish()
		if(build_progress >= build_progress_required)
			if(path_to_object == /turf/dirt)
				for(var/obj/i in locate(x,y,z))
					if(i != src && i.built)
						del i
			if(path_to_object == /turf/dirt)
				del loc
			else
				var/g = new path_to_object(locate(x,y,z))
				if(path_to_object != /turf/dirt)
					g:built = 1
					g:ownerofthis = owner
					owner:owned_stuff += g
					if(istype(g,/turf/floor/storage))
						owner:storages += g
			del src
		else

			icon_state = "[round((((build_progress)/build_progress_required)*5))]"
			if(old_ico != icon_state)
				if(material_type)
					world << sound("sound/[material_type]Build[rand(1,4)].wav")
				old_ico = icon_state
			return -1
	proc/Init()
		if(what_to_build == "Destroy")
			path_to_object = /turf/dirt
			build_progress_required = 5
			material_type = "granite"
		else
			path_to_object = buildable[what_to_build][1]
			build_progress_required = buildable[what_to_build][4]
			material_cost = buildable[what_to_build][3]
			material_type = buildable[what_to_build][2]
	New()
		..()
		fast_process += src
	Del()
		fast_process -= src
		..()
/mob/var/list/storages = list()
/mob/var/list/owned_stuff = list()
/mob/verb/Clear_All_Projects()
	for(var/obj/build_project/G in world)
		if(G.owner == src)
			del G
/datum/game_event/start_project
	//project, aka what makes the mob walk to a tile and start building crap.
	var/obj/build_project/proj = null
	DoEvent()
		if(istype(owner,/mob))
			if(proj)
				if(owner:client)
					var/obj/item/material/found_resource = null
					for(var/turf/floor/storage/I in owner:storages)
						CHECK_TICK
						for(var/obj/item/material/resource in I)
							if(resource.name == proj.material_type)
								if(resource.amount >= proj.material_cost)
									found_resource = resource
									break
					if(found_resource || proj.material_cost <= 0)
						if(owner:WalkTo(proj.x,proj.y))
							var/cost = proj.material_cost
							var/typ = proj.material_type
							var/returning = 0
							//world << "a"
							while(proj && proj.build_progress < proj.build_progress_required)
								proj.build_progress += world.tick_lag
								returning = proj.Check_Finish()
								sleep(world.tick_lag)
							//world <<"finished"
							if(returning != -1)
								//world <<"Success"
								if(owner)
									if(typ != null)
										if(found_resource)
											found_resource.amount -= cost
											if(found_resource.amount <= 0)
												del found_resource
											owner:Update_Storage()
						else
							return 1
					else
						owner << 'sound/Beep.wav'
						owner << "<b>You don't have enough materials, or you haven't stacked your materials yet."
		return 1

	Del()
		if(proj)
			del proj
		..()

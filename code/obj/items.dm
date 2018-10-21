#define WEAPON 0
#define ARMOR 1
#define USABLE 2
#define FOOD 3
#define MATERIAL 4

#define THROWN 0
/mob
	var/obj/item/weapon/slot_0 = null
	var/obj/item/slot_1 = null
	var/obj/item/slot_2 = null
	var/obj/item/slot_3 = null //Food slot.
	var/obj/item/material/slot_4 = null
	var/list/owned_items = list(
	"wood" = 0,
	"granite" = 0,
	"meat" = 0,
	"club" = 0,
	"knife" = 0,
	"gun" = 0
	)
	proc/Update_Storage()
		for(var/i in owned_items)
			CHECK_TICK
			owned_items[i] = 0
		for(var/i in 0 to 4)
			var/obj/item/G = vars["slot_[i]"]
			if(G)
				//world << "Found item"
				if(G.name in owned_items)
					owned_items[G.name] += G.amount
					//world << "added"
		for(var/turf/floor/storage/T in storages)
			CHECK_TICK
			for(var/obj/item/IT in T)
				CHECK_TICK
				if(IT.name in owned_items)
					owned_items[IT.name] += IT.amount

/datum/game_event/pick_up
	//project, aka what makes the mob walk to a tile and start building crap.
	var/obj/item/proj = null
	var/what_to_do = "Transfer To Storage"
	DoEvent()
		if(istype(owner,/mob))
			if(proj)
				var/turf/location = proj.loc
				if(location)
					if(owner.vars["slot_[proj.typeW]"] == null)
						if(owner:WalkTo(location.x,location.y))
							if(owner.vars["slot_[proj.typeW]"] == null)
								var/mob/owner_of_it = proj.ownerofthis
								var/init_loc = proj.loc
								proj.loc = locate(0,0,0)
								owner.vars["slot_[proj.typeW]"] = proj
								switch(what_to_do)
									if("Equip")
										if(proj:weapon_type == RANGED)
											owner << "<font color='green'><b>Your ranged attacks will deal [proj:attack_damage] DMG now."
										else
											owner << "<font color='green'><b>Your attacks will deal [5+proj:attack_damage] DMG now."
										owner << 'beep.wav'
										if(proj.amount > 1)
											var/obj/item/tp = new proj.type(init_loc)
											tp.amount = proj.amount-1
											proj.amount = 1
									if("Eat")
										if(proj.typeW == FOOD)
											if(proj.on_use(owner) == "DID NOT")
												proj.loc = init_loc
												world << sound("sound/Eat[rand(1,3)].wav")
												owner.vars["slot_[proj.typeW]"] = null
									if("Transfer To Storage")
										if(owner_of_it && owner_of_it != owner)
											owner_of_it:client:Add_Alert("Robbery : [owner]",'RaidAlert.wav',"#FF0000")
											owner_of_it.Update_Storage()
										if(owner:storages.len > 0)
											var/obj/item/current_stack = null
											for(var/turf/floor/storage/STO in owner:storages)
												CHECK_TICK
												var/obj/item/GSt = locate(proj.type) in STO
												if(GSt)
													current_stack = GSt
													break
											if(current_stack)
												if(owner:WalkTo(current_stack.x,current_stack.y))
													current_stack.amount += proj.amount
													del proj
											else
												var/turf/floor/storage/T = null
												for(var/turf/floor/storage/STO in owner:storages)
													if(locate(/obj/item) in STO)
														continue
													else
														T = STO
												if(T)
													if(owner:WalkTo(T.x,T.y))
														proj.loc = T
														owner.vars["slot_[proj.typeW]"] = null
												else
													owner << 'beep.wav'
													owner << "<b>Your storage is full."
													proj.loc = init_loc
													owner.vars["slot_[proj.typeW]"] = null
										else
											owner << 'beep.wav'
											owner << "<b>No storage tiles found."
											proj.loc = init_loc
											owner.vars["slot_[proj.typeW]"] = null
								if(owner_of_it)
									owner_of_it.Update_Storage()
								if(proj)
									proj.ownerofthis = owner
									proj.on_equip(owner)

								owner:Update_Storage()
					else
						owner << 'beep.wav'
						owner << "<b>You are already carrying something of this type."
		return 1

/mob/verb/Drop_Object()
	var/options = list(
	"Weapon" = WEAPON,
	"Armor" = ARMOR,
	"Usable" = USABLE,
	"Food" = FOOD,
	"Material" = MATERIAL
	)
	var/inputP = input(src,"What should we drop?") as null|anything in options
	if(inputP)
		var/obj/item/G = vars["slot_[options[inputP]]"]
		if(G)
			G.loc = loc
			vars["slot_[options[inputP]]"] = null
		else
			src << 'beep.wav'
			src << "<b>We don't have anything equipped on this slot."
	Update_Storage()
/obj/item
	name = "Item"
	icon = 'items.dmi'
	health = 0
	var
		amount = 1
		typeW = USABLE
	RightClicked(mob/M)
		var/options = list("Transfer To Storage")
		if(typeW == USABLE)
			options += "Use"
		if(typeW == FOOD)
			options += "Eat"
		if(typeW == WEAPON)
			options += "Equip"
		if(type == ARMOR)
			options += "Wear"
		var/input = input(M,"What do you want to do with this?") as null|anything in options
		if(input)
			var/datum/game_event/pick_up/EV = Scheduler.Add_Event(/datum/game_event/pick_up,M)
			EV.what_to_do = input
			EV.proj = src
	proc
		on_use(mob/M)
		on_equip(mob/M)
	weapon
		var/attack_damage = 10
		var/weapon_type = MELEE
		typeW = WEAPON
		club
			name = "club"
			icon_state = "club"
		gun
			weapon_type = RANGED
			name = "gun"
			icon_state = "gun"
		knife
			name = "knife"
			icon_state = "knife"
			attack_damage = 20
	material
		typeW = MATERIAL
		wood
			name = "wood"
			icon_state = "wood"
			amount = 20
		granite
			name = "granite"
			icon_state = "granite"
			amount = 50
	food
		name = "Food"
		typeW = FOOD
		var/hunger_restoration = 10
		amount = 10
		on_use(mob/M)
			M.nutrition += hunger_restoration
			M << "You eat the [name]."
			if(amount > 0)
				amount -= 1
				return "DID NOT"
			else
				del src
		meat
			name = "meat"
			icon_state = "meat"
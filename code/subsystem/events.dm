/datum/event
	var/name = "Event Type"
	var/sfx = 'Notification.wav'
	var/alert_text = "Fuck you"
	var/col = "#FF8080"
	proc/On_Trigger()
		..()
		for(var/client/i in clients)
			i.Add_Alert(alert_text,sfx,col)

/datum/event/raid
	name = "Raid"
	alert_text = "Raid : Angry People"
	sfx = 'RaidAlert.wav'
	On_Trigger()
		..()
		for(var/client/i in clients)
			i.tension = 100
		for(var/i in 1 to rand(1,4))
			new /mob/human/angery_ai(find_free_turf())

/datum/event/drop
	name = "Loot Drop"
	alert_text = "Loot Drop!"
	sfx = 'NotificationGood.wav'
	col = "#8080FF"
	On_Trigger()
		..()
		for(var/i in 1 to rand(17,20))
			var/list/random_items = list(
			/obj/item/food/meat,
			/obj/item/material/granite,
			/obj/item/weapon/club,
			/obj/item/weapon/knife,
			/obj/item/weapon/gun
			)
			var/wep = pick(random_items)
			new wep(find_free_turf())

/datum/controller/events
	name = "Events"
	var/timer = 5
	var/purposed_event = /datum/event/drop
	Process()
		timer -= world.tick_lag/10
		if(timer < 0)
			var/datum/event/T
			var/p = pick((typesof(/datum/event)-/datum/event))
			if(purposed_event)
				T = new purposed_event()
				purposed_event = null
			else
				T = new p()
			T.On_Trigger()
			sleep(5)
			del T
			timer = 200
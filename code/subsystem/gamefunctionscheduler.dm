/datum/game_event
	var/name = "Event"
	var/atom/owner = null
	proc
		DoEvent()
			..()

/atom
	var/can_event = 1

var/datum/controller/GameScheduler/Scheduler = null

/datum/controller/GameScheduler
	name = "Game Function Scheduler"
	var/list/scheduled_events = list(
	//Put mobs in here by doing += then assign stuff to them by doing schedule_those_events[mob] += event
	)
	proc
		Add_Item(atom/A)
			if(!(A in scheduled_events))
				scheduled_events += A
				scheduled_events[A] = new /list
		Add_Event(event,atom/to_assign)
			Add_Item(to_assign)
			if(to_assign in scheduled_events)
				var/datum/game_event/G = new event()
				G.name = "[G.type] started at [world.time*10] by [to_assign]"
				G.owner = to_assign
				scheduled_events[to_assign] += G
				//world << "EVENT SCHEDULED : [event] at /list point [scheduled_events[to_assign]:len]"
				return G
	Get_Extra_Information()
		var/finaltext = ""
		for(var/a in scheduled_events)
			finaltext = "[finaltext]EVENT [a] - [jointext(scheduled_events[a],", ")] , "
		return finaltext
	Process()
		Scheduler = src
		for(var/a in scheduled_events)
			spawn() //how to multi thread in biond
				if(istype(a,/atom))
					var/atom/A = a
					if(A.can_event)
						if(scheduled_events[a]:len > 0)
							//world << "STARTING EVENT [scheduled_events[a][1]] at /list point 1"
							A.can_event = 0
							var/datum/game_event/event_to_do = scheduled_events[a][1] //schedule the next event
							if(scheduled_events[a][1]:DoEvent())
								scheduled_events[a] -= event_to_do
								A.can_event = 1
							else
								A.can_event = 1 //Failed to start event.

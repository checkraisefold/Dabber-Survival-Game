var/list/controllers = list()
var/list/fast_process = list()
var/list/AIs = list()
var/list/electricity = list()
var/frame = 0
world
	New()
		..()
		for(var/i in typesof(/datum/controller)-/datum/controller)
			var/datum/controller/G = new i()
			controllers += G
			spawn()
				G.StartProcessing()
/datum
	proc/process()
		..()
/datum/controller
	var/name = "Controller"
	var/wait = TICK_LAG
	var/processing = 0
	proc
		StartProcessing()
			while(1)
				processing = 1
				Process()
				processing = 0
				sleep(wait)
		Process()
			//Processes stuff
		Get_Extra_Information()
			return "CPU : [world.cpu]"

/datum/controller/AI
	name = "AI"
	Process()
		for(var/mob/D in AIs)
			D.process()

/datum/controller/FastProcess
	name = "Fast Processing"
	Process()
		frame += 1
		for(var/datum/D in fast_process)
			D.process()

/datum/controller/Electricity
	name = "Electricity"
	Process()
		for(var/datum/D in electricity)
			CHECK_TICK
			D.process()

/datum/controller/ClientProcesser
	name = "Client Processing"
	Process()
		for(var/client/C in clients)
			C.ProcessClient()

/client/Stat()
	..()
	if(key == world.host)
		if(statpanel("Stat"))
			stat("ass")
		if(statpanel("Controllers"))
			for(var/datum/controller/Cont in controllers)
				stat("[Cont.name]",null)
				stat(null,"WAIT : [Cont.wait]")
				stat(null,"PROCESSING : [Cont.processing ? "YES" : "NO"]")
				stat(null,"[Cont.Get_Extra_Information()]")
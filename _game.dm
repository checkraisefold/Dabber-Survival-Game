#define TICK_LAG (1/60)*10
#define HUD_PLANE 100
#define LIGHTING_PLANE 40
#define WATER_PLANE -100
#define DEBUG
#define CHECK_TICK if(world.tick_usage > 80) sleep(world.tick_lag)
#define MELEE 1
#define RANGED 2
var/list/clients = list()
var/webhook_url = "https://discordapp.com/api/webhooks/503242600845803540/ZjBKV7th3sQV-k9lMDcvseX6HDmJ4vTysU5kdZ3QhXDjjI0pjMZLcRfPabzzVntGz_xP"
world
	tick_lag = TICK_LAG 		// 25 frames per second
	icon_size = 64	// 32x32 icon size by default
	name = "Dabber Survival Game"
	view = "19x15"		// show up to 6 tiles outward from center (13x13 view)
	turf = /turf/dirt
	mob = /mob/human
	New()
		..()
		spawn(10)
			discord_relay("gamers... server up....... byond://[internet_address]:[port]")
	Del()
		discord_relay("im dead")
		..()

obj
	step_size = 2

atom
	appearance_flags = PIXEL_SCALE

client
	New()
		..()
		src << {"<font color='#00e5e5'>Welcome to <b>Dabber Survival Game</b>!!
Controls:<b>
	WASD - Move Camera
	Shift - Faster Camera Speed
	B - Build Menu (press cancel to stop building)
	T - Chat
	Left Click - Attack Someone
	Double Left Click - Select Object
	Right Click with player selected - Walk To
	Right Click - Interact"}
proc/distance(atom/movable/A, atom/B)
	return sqrt((B.x-A.x+(A.step_x/64))**2 + (B.y-A.y+(A.step_y/64))**2)

proc/atomdistance(atom/A, atom/B)
	return sqrt((B.x-A.x)**2 + (B.y-A.y)**2)

/proc/discord_relay(var/content)
	if(world.port != 0)
		spawn()
			call("ByondPOST.dll", "send_post_request")("[webhook_url]", " { \"content\" : \"[content]\" } ", "Content-Type: application/json")

proc
	dir2txt_3(d)
		switch(d)
			if(1)
				return "NORTH"
			if(2)
				return "SOUTH"
			if(3)
				return "NORTH+SOUTH"
			if(4)
				return "EAST"
			if(5)
				return "NORTH+EAST"
			if(6)
				return "SOUTH+EAST"
			if(7)
				return "NORTH+SOUTH+EAST"
			if(8)
				return "WEST"
			if(9)
				return "NORTH+WEST"
			if(10)
				return "SOUTH+WEST"
			if(11)
				return "NORTH+SOUTH+WEST"
			if(12)
				return "EAST+WEST"
			if(13)
				return "NORTH+EAST+WEST"
			if(14)
				return "SOUTH+EAST+WEST"
			if(15)
				return "NORTH+SOUTH+EAST+WEST"
			else
				return ""


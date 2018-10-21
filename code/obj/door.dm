/obj/door
	name = "Door"
	icon = 'icons/floors/door.dmi'
	density = 1
	mouse_opacity = 2
	var/obj/overlay/slider_1
	var/obj/overlay/slider_2
	New()
		..()
		icon = null
		slider_1 = new()
		slider_1.icon = 'icons/floors/door.dmi'
		var/matrix/M = matrix()
		M.Scale(-1,1)
		slider_2 = new()
		slider_2.icon = 'icons/floors/door.dmi'
		slider_2.transform = M

		slider_2.layer = TURF_LAYER
		slider_1.layer = TURF_LAYER
		vis_contents += slider_1
		vis_contents += slider_2
	RightClicked(mob/M)
		if(ownerofthis == M)
			if(density)
				density = 0
				world << 'DoorOpen.ogg'
				animate(slider_1,pixel_x = -33,time = 1)
				animate(slider_2,pixel_x = 33,time = 1)
			else
				density = 1
				world << 'DoorClose.ogg'
				animate(slider_1,pixel_x = 0,time = 1)
				animate(slider_2,pixel_x = 0,time = 1)
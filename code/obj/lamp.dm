/obj/lamp
	icon = 'icons/obj/light.dmi'
	icon_state = "lamp"
	New()
		..()
		Apply_Light(20,"#FFFFFF")
	redlamp
		icon_state = "lamp_red"
		New()
			..()
			Apply_Light(20,"#FF0000")
/obj/electricity/power/lamp
	icon = 'light.dmi'
	icon_state = "lamp"
	New()
		..()
		Apply_Light(20,"#FFFFFF")
	process()
		if(spend_power(2))
			if(l)
				l.alpha = 255
		else
			if(l)
				l.alpha = 0
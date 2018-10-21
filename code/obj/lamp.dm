/obj/electricity/power/lamp
	icon = 'light.dmi'
	icon_state = "lamp"
	var/lamp_light_color = "#FFFFFF"
	New()
		..()
		Apply_Light(20,lamp_light_color)
	process()
		if(spend_power(2))
			if(l)
				l.alpha = 255
		else
			if(l)
				l.alpha = 0
	redlamp
		icon_state = "lamp_red"
		lamp_light_color = "#FF0000"

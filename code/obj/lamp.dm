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
	RightClicked(mob/M)
		var/new_color = input(M,"What color") as null|color
		if(new_color)
			lamp_light_color = new_color
			Apply_Light(20,lamp_light_color)
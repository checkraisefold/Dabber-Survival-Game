obj
	light
		plane 			= LIGHTING_PLANE
		blend_mode 		= BLEND_ADD
		icon 			= 'lighting.dmi'  // a 96x96 white circle ; you can change this to whatever lighting aura you want.
		icon_state 		= "light"
		layer			= 1+EFFECTS_LAYER
		appearance_flags= RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM


atom/movable
	var/obj/light/l = null
	proc/Apply_Light(var/size,var/colorE)
		if(l in vis_contents)
			vis_contents -= l
			del l
		l = new()
		var/matrix/M = matrix()
		M.Scale(size)
		l.color = colorE
		l.transform = M
		vis_contents += l
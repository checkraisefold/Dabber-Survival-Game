/obj/projectile
	var/ang = 0
	var/speed = 15
	var/dmg = 0
	var/mob/human/bullet_owner = null
	icon = 'icons/obj/bullet.dmi'
	bound_x = 30
	bound_y = 30
	bound_width = 4
	bound_height = 4
	New()
		..()
		fast_process += src
	Del()
		fast_process -= src
		..()
	process()
		if(!PixelMove(cos(ang)*speed,sin(ang)*speed))
			del src
		for(var/atom/i in obounds(src))
			if(istype(i,/mob))
				if(i != bullet_owner)
					i:TakeDamage(dmg)
					del src
			if(istype(i,/turf))
				if(i.density)
					i:TakeDamageTurf(dmg)
					del src
			if(istype(i,/obj))
				if(i.density)
					i:TakeDamageObj(dmg,0)
					del src
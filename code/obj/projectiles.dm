/obj/projectile
	var/ang = 0
	var/speed = 4
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
		PixelMove(cos(ang)*speed,sin(ang)*speed)
		for(var/mob/human/i in obounds(src))
			if(i != bullet_owner)
				i.TakeDamage(dmg)
				del src
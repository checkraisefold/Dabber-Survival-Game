/obj
	var/health = 100
	proc/TakeDamageObj(dmg,forced = 0)
		if(ownerofthis || forced)
			health -= dmg
			world << sound("sound/galvin1.ogg")
			if(health <= 0)
				del src
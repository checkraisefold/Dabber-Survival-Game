world/New()
	..()
	if(port == 0)
		maxx = 20
		maxy = 20
	var/Noise/octave_1 = new(world.maxx, world.maxy)
	octave_1.frequency = 4
	octave_1.amplitude = 128
	octave_1.smoothness = 2
	octave_1.Randomize()
	var/Noise/octave_2 = new(world.maxx, world.maxy)
	octave_2.frequency = 8
	octave_2.amplitude = 64
	octave_2.smoothness = 2
	octave_2.Randomize()
	var/Noise/octave_3 = new(world.maxx, world.maxy)
	octave_3.frequency = 16
	octave_3.amplitude = 32
	octave_3.smoothness = 2
	octave_3.Randomize()
	var/Noise/perlin = new(world.maxx, world.maxy)
	perlin.Blend(octave_1,octave_2,octave_3)
	for(var/x in 1 to world.maxx)
		for(var/y in 1 to world.maxy)
			var/b = perlin.Noise(x,y)*4
			if(b < 100)
				new /turf/water(locate(x,y,1))
			else
				if(prob(1))
					new /obj/tree(locate(x,y,1))


Noise
	var
		// This matrix stores the amount of noise for each point in the block
		list/noise[][]

		// amount of a noise in one wavelength
		frequency

		// max value of noise
		amplitude

		// matrix size
		width
		height

		// ammount to smooth results
		smoothness
	New(Width, Height)
		width  = Width
		height = Height
		noise = new/list(width, height)
	proc/Noise(x, y)
		if(x > 0 && x <= width && y > 0 && y <= height)
			return noise[x][y]
	proc/SmoothPoint(x, y)
		var/corners = ( Noise(x-1, y-1)+Noise(x+1, y-1)+Noise(x-1, y+1)+Noise(x+1, y+1) ) / 16
		var/sides   = ( Noise(x-1, y)  +Noise(x+1, y)  +Noise(x, y-1)  +Noise(x, y+1) ) /  8
		var/center  =  Noise(x, y) / 4
		return corners + sides + center
	proc/Blend()
		var/Noise/n = args[1]
		for(var/x = 1 to width)
			for(var/y = 1 to height)
				noise[x][y] = n.noise[x][y]
		for(n in args - args[1])
			for(var/x = 1 to width)
				for(var/y = 1 to height)
					noise[x][y] =(noise[x][y] + n.noise[x][y])/2

	proc/Smooth()
		for(var/x = 1 to width)
			for(var/y = 1 to height)
				noise[x][y] = SmoothPoint(x, y)
	proc/Randomize(seed)
		if(seed) rand_seed(seed)
		var/wavelength = 1/frequency
		var/x
		var/y
		var/list/x_nodes = list()
		var/list/y_nodes = list()
		x = 1
		while(x < width)
			y=1
			while(y < height)
				var/rx = round(x)
				var/ry = round(y)
				noise[rx][ry] = rand(1,amplitude)
				x_nodes += rx
				y_nodes += ry
				y += wavelength*height
			x += wavelength*height
		x_nodes += height
		y_nodes += width
		var/px
		var/cx
		var/py
		var/cy
		for(x = 1, x <= x_nodes.len-1, x++)
			cx = x_nodes[x]
			px = x_nodes[x+1]
			for(y = 1, y <= y_nodes.len-1, y++)
				cy = y_nodes[y]
				py = y_nodes[y+1]
				if(px == width) px ++
				if(py == height) py ++
				for(var/tx = cx to px-1)
					for(var/ty = cy to py-1)
						noise[tx][ty] = noise[cx][cy]
		for(var/s = 1 to smoothness)
			Smooth()
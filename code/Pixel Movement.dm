proc/atan2(x, y)
	if(!x && !y) return 0
	return y >= 0 ? arccos(x / sqrt(x * x + y * y)) : -arccos(x / sqrt(x * x + y * y))

proc/get_angle(atom/a, atom/b)
	return atan2(b.x - a.x, b.y - a.y)
atom/movable
	var
		sub_step_x = 0
		sub_step_y = 0

	proc
		PixelMove(move_x, move_y)
			var
				whole_x = 0
				whole_y = 0

			if(move_x)
				sub_step_x += move_x
				whole_x = round(sub_step_x, 1)
				sub_step_x -= whole_x

			if(move_y)
				sub_step_y += move_y
				whole_y = round(sub_step_y, 1)
				sub_step_y -= whole_y

			if(whole_x || whole_y)
				step_size = max(abs(whole_x), abs(whole_y))
				Move(loc, dir, step_x + whole_x, step_y + whole_y)

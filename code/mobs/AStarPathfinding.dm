proc/find_free_turf()
	return pick(free_turfs)
mob/var/pathfinding = 0
var/turf/DESTINATION
mob/proc
	WalkTo(_x, _y)
		if(!pathfinding)
			DESTINATION = locate(_x,_y,1)
			pathfinding = 1
			var/path[] = AStar(loc,DESTINATION,/turf/proc/AdjacentTurfs,/turf/proc/Distance)
			for(var/turf/T in path)
				var/old_x = x
				var/old_y = y
				if(step_towards(src, T, 64))
					pixel_w = (old_x-x)*64
					pixel_z = (old_y-y)*64
					sleep(world.tick_lag)
					animate(src, pixel_w = 0, pixel_z = 0, time = 1-world.tick_lag)
					sleep (1-world.tick_lag)
			pathfinding = 0
			return 1

turf
	var
		pathweight = 1
	proc
		AdjacentTurfs()
			var/L[] = new()
			for(var/turf/t in oview(src,1))
				var/VALID = !t.density
				for(var/atom/movable/G in t)
					if(G.density)
						VALID = 0
						break
				if(VALID || t == DESTINATION)
					L.Add(t)
			return L
		Distance(turf/t)
			if(get_dist(src,t) == 1)
				var/cost = (src.x - t.x) * (src.x - t.x) + (src.y - t.y) * (src.y - t.y)
				//Multiply the cost by the average of the pathweights of the
				//tile being entered and tile being left
				cost *= (pathweight+t.pathweight)/2
				return cost
			else
				return get_dist(src,t)
PriorityQueue
	var
		L[]
		cmp
	New(compare)
		L = new()
		cmp = compare
	proc
		IsEmpty()
			return !L.len
		Enqueue(d)
			var/i
			var/j
			L.Add(d)
			i = L.len
			j = i>>1
			while(i > 1 &&  call(cmp)(L[j],L[i]) > 0)
				L.Swap(i,j)
				i = j
				j >>= 1

		Dequeue()
			ASSERT(L.len)
			. = L[1]
			Remove(1)

		Remove(i)
			ASSERT(i <= L.len)
			L.Swap(i,L.len)
			L.Cut(L.len)
			if(i < L.len)
				_Fix(i)
		_Fix(i)
			var/child = i + i
			var/item = L[i]
			while(child <= L.len)
				if(child + 1 <= L.len && call(cmp)(L[child],L[child + 1]) > 0)
					child++
				if(call(cmp)(item,L[child]) > 0)
					L[i] = L[child]
					i = child
				else
					break
				child = i + i
			L[i] = item
		List()
			var/ret[] = new()
			var/copy = L.Copy()
			while(!IsEmpty())
				ret.Add(Dequeue())
			L = copy
			return ret
		RemoveItem(i)
			var/ind = L.Find(i)
			if(ind)
				Remove(ind)
PathNode
	var
		datum/source
		PathNode/prevNode
		f
		g
		h
		nt		// Nodes traversed
	New(s,p,pg,ph,pnt)
		source = s
		prevNode = p
		g = pg
		h = ph
		f = g + h
		source.bestF = f
		nt = pnt

datum
	var
		bestF

proc
	PathWeightCompare(PathNode/a, PathNode/b)
		return a.f - b.f

	AStar(start,end,adjacent,dist,maxnodes,maxnodedepth,mintargetdist,minnodedist)
		var/PriorityQueue/open = new /PriorityQueue(/proc/PathWeightCompare)
		var/closed[] = new()
		var/path[]

		open.Enqueue(new /PathNode(start,null,0,call(start,dist)(end)))

		while(!open.IsEmpty() && !path)
		{
			CHECK_TICK
			var/PathNode/cur = open.Dequeue()
			closed.Add(cur.source)

			var/closeenough
			if(mintargetdist)
				closeenough = call(cur.source,dist)(end) <= mintargetdist

			if(cur.source == end || closeenough) //Found the path
				path = new()
				path.Add(cur.source)
				while(cur.prevNode)
					CHECK_TICK
					cur = cur.prevNode
					path.Add(cur.source)
				break

			var/L[] = call(cur.source,adjacent)()
			if(minnodedist && maxnodedepth)
				if(call(cur.source,minnodedist)(end) + cur.nt >= maxnodedepth)
					continue
			else if(maxnodedepth)
				if(cur.nt >= maxnodedepth)
					continue

			for(var/datum/d in L)
				CHECK_TICK
				//Get the accumulated weight up to this point
				var/ng = cur.g + call(cur.source,dist)(d)
				if(d.bestF)
					if(ng + call(d,dist)(end) < d.bestF)
						for(var/i = 1; i <= open.L.len; i++)
							CHECK_TICK
							var/PathNode/n = open.L[i]
							if(n.source == d)
								open.Remove(i)
								break
					else
						continue

				open.Enqueue(new /PathNode(d,cur,ng,call(d,dist)(end),cur.nt+1))
				if(maxnodes && open.L.len > maxnodes)
					open.L.Cut(open.L.len)
		}

		var/PathNode/temp
		while(!open.IsEmpty())
			CHECK_TICK
			temp = open.Dequeue()
			temp.source.bestF = 0
		while(closed.len)
			CHECK_TICK
			temp = closed[closed.len]
			temp.bestF = 0
			closed.Cut(closed.len)

		if(path)
			for(var/i = 1; i <= path.len/2; i++)
				CHECK_TICK
				path.Swap(i,path.len-i+1)

		return path
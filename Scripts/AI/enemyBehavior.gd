class_name EnemyBehavior


static func dumb_melee_behavior(map) -> bool:

	var enemy = CombatMapStatus.get_selected_character()
	var possibleTargets = check_players_in_range(map, enemy)
	
	if (possibleTargets.is_empty()): # currently doesnt take into account root or a unit being in those tiles, but it will do for basic testing
		melee_movement(map, enemy, 0)
		return false
	else:
		var finalTargetId = randi_range(1,len(possibleTargets))
		var finalTarget = possibleTargets[finalTargetId-1]
		return melee_enemy_attack(map, enemy, finalTarget)


static func smart_melee_behavior(map) -> bool:
	var enemy = CombatMapStatus.get_selected_character()
	var possibleTargets = check_players_in_range(map, enemy)
	
	if (possibleTargets.is_empty()): # currently doesnt take into account root or a unit being in those tiles, but it will do for basic testing
		melee_movement(map, enemy, 0)
		return false
	else:
		var finalTarget = smart_enemy_target_choice(enemy, possibleTargets)
		return melee_enemy_attack(map, enemy, finalTarget)


static func smart_enemy_target_choice(enemy, possibleTargets):
	var finalTarget
	var damageValue: int
	var precision: float
	var appetizingTarget: float
	var previousBest = 0.1
	var killRange: int
	
	for playerCharacter in possibleTargets:
		damageValue = enemy.get_attack()-playerCharacter.get_defense()
		precision = (50+enemy.get_dexterity()*5-playerCharacter.get_agility()*3)/100
		if damageValue >= playerCharacter.get_current_health():
			killRange = 5
		else:
			killRange = 0
		
		appetizingTarget = (damageValue+killRange)*precision
		
		if(previousBest<appetizingTarget):
			previousBest = appetizingTarget
			finalTarget = playerCharacter
		
	return finalTarget


static func melee_enemy_attack(map, enemy, finalTarget) -> bool:
	var rooted = enemy.is_rooted()
	var finalTargetX = finalTarget.get_map_coords()[0]
	var finalTargetY = finalTarget.get_map_coords()[1]
	
	if rooted or Utils.calc_distance(enemy.get_map_coords(),finalTarget.get_map_coords()) == 1:
		CombatMapStatus.set_selected_enemy(finalTarget)
		return true
	elif validate_movement(map, enemy, Vector2(finalTargetX+1, finalTargetY)):
		CombatMapStatus.set_selected_map_tile(map.get_tile_from_coords(Vector2(finalTargetX+1, finalTargetY)))
		CombatMapStatus.set_selected_enemy(finalTarget)
	elif validate_movement(map, enemy, Vector2(finalTargetX, finalTargetY+1)):
		CombatMapStatus.set_selected_map_tile(map.get_tile_from_coords(Vector2(finalTargetX, finalTargetY+1)))
		CombatMapStatus.set_selected_enemy(finalTarget)
	elif validate_movement(map, enemy, Vector2(finalTargetX-1, finalTargetY)):
		CombatMapStatus.set_selected_map_tile(map.get_tile_from_coords(Vector2(finalTargetX-1, finalTargetY)))
		CombatMapStatus.set_selected_enemy(finalTarget)
	elif validate_movement(map, enemy, Vector2(finalTargetX, finalTargetY-1)):
		CombatMapStatus.set_selected_map_tile(map.get_tile_from_coords(Vector2(finalTargetX, finalTargetY-1)))
		CombatMapStatus.set_selected_enemy(finalTarget)
	else:
		melee_movement(map, enemy, 1)
		return false
		
	map.move_character() #not final move, probably should go to the furthest non populated tile reachable that allows attack
	return true

static func check_players_in_range(map, enemy) -> Array:
	var possible_Targets: Array
	var rooted = false #enemy.is_rooted()
	for character in map.characterGroup.get_children():
		if(rooted):
			if (Utils.calc_distance(enemy.get_map_coords(), character.get_map_coords())<=enemy.get_range()): #add the validation from james
				possible_Targets.append(character)
			#enemy.set_is_rooted(false)
		elif(Utils.calc_distance(enemy.get_map_coords(), character.get_map_coords())<=(enemy.get_movement()+enemy.get_range())):
			possible_Targets.append(character)
	
	return possible_Targets

static func check_closest_player(map, enemy): #we can get everything in the mega if here if wanted and rename func to get_near_closest_player
	var closestTargetDist = 100
	var closestTarget
	for character in map.characterGroup.get_children():
		if (Utils.calc_distance(enemy.get_map_coords(), character.get_map_coords())<closestTargetDist):
			closestTargetDist = Utils.calc_distance(enemy.get_map_coords(), character.get_map_coords())
			closestTarget = character
			
	return closestTarget
	
static func melee_movement(map, enemy, reach): #reach is basically a movement penalty, it is used in the case that the enemy cant reach a valid attack target
	var closestTarget = check_closest_player(map, enemy)
	var rooted = enemy.is_rooted()
	var leftoverMov: int
	var posX: int
	var posY: int = enemy.get_map_coords()[1]
	
	if(rooted):
		posX = enemy.get_map_coords()[0]
	elif(abs(enemy.get_map_coords()[0]-closestTarget.get_map_coords()[0])<enemy.get_movement()-reach):
		posX = enemy.get_map_coords()[0] + (closestTarget.get_map_coords()[0]-enemy.get_map_coords()[0])
		leftoverMov = enemy.get_movement()-reach-abs(enemy.get_map_coords()[0]-closestTarget.get_map_coords()[0])
		if(enemy.get_map_coords()[1]<closestTarget.get_map_coords()[1]):
			posY = enemy.get_map_coords()[1] + leftoverMov
		else:
			posY = enemy.get_map_coords()[1] - leftoverMov
	else:
		if(enemy.get_map_coords()[0]<closestTarget.get_map_coords()[0]):
			posX = enemy.get_map_coords()[0] + enemy.get_movement() - reach
		else:
			posX = enemy.get_map_coords()[0] - enemy.get_movement() + reach
	
	CombatMapStatus.set_selected_map_tile(map.get_tile_from_coords(Vector2(posX,posY)))
	map.move_character()
	
static func validate_movement(map, enemy, finalCoords: Vector2) -> bool:
	var condition1 = Utils.calc_distance(enemy.get_map_coords(), finalCoords) <= enemy.get_movement()
	var condition2 = not map.get_tile_from_coords(finalCoords).is_populated()
	return condition1 and condition2

func _dijkstra(map, mapCoords: Vector2, maxRange: int) -> Array:
	var moveableCells = [mapCoords] # append the current cell to the array of tiles that can be moved to
	var visited = [] # bidimensional array that keeps track of which tiles have been traversed to
	var distances = [] # shows distance to each cell, might be useful for certain checks but ultimately not 100% necsessary as the distance is also the priority
	var previous = [] # bidimensional array that shows which cells you have to take to get there to get the shortest path
	const DIRECTIONS = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT] # array that will help us later to move to the adjacent tiles, goes in this order South, east, north, west (remember Y axis is toward player, thats why its reversed)
	var pQ = PriorityQueue.new()
	
	# Now we setup the bidimensional array, once populated, the visited and previous path will be set empty
	# and distance will be considered max to allow for better distances to be registered
	for y in range(CombatMapStatus.mapY): #substitute for map size y
		visited.append([])
		distances.append([])
		previous.append([])
		for x in range(CombatMapStatus.mapX): #substitute for map size x
			visited[y].append([false])
			distances[y].append([9999])
			previous[y].append([null])
	
	pQ.push(mapCoords, 0) # We create the priority queue with the starting tile (the tile the enemy is standing on
	distances[mapCoords.y][mapCoords.x] = 0
	
	var tileCost
	var distanceToNode
	var occupiedCells = []
	
	# start the search
	for i in range(10000):
		var current = pQ.pop()
		visited[current.value.y][current.value.x] = true
		
		for dir in DIRECTIONS:
			var coordinates =  current.value + dir
			if coords_within_bounds(coordinates) and map.get_tile_from_coords(coordinates).is_traversable(): # if it is traversable and it is within the map
				if visited[coordinates.y][coordinates.x]: # if it was already visited that means that the tile had a better/equal path to it due to the prio queue
					continue
				else:
					var extraCost = 0
					if map.get_tile_from_coords(coordinates).is_control_zone(): # reworkeado, la casilla que mira es en entrada y reduce en 1 el mov en lugar de 2, checkea que la zona de inicio de la unidad sea zona de control antes de llamarlo
						extraCost += 1
					elif map.get_tile_from_coords(coordinates).is_difficult_terrain():
						extraCost += 1
					tileCost = 1 + extraCost
					
					distanceToNode = current.priority + tileCost
					
					visited[coordinates.y][coordinates.x] = true
					distances[coordinates.y][coordinates.x] = distanceToNode
				
				if distanceToNode <= maxRange or current.priority + 1 <= maxRange: #the second part of the or should allwo for allowing moving a cost 2 with only 1 mov or a cost 3 with 1-2 mov left
					previous[coordinates.y][coordinates.x] = current.value
					moveableCells.append(coordinates)
					pQ.push(coordinates, distanceToNode)
				
			if pQ.is_empty():
				break
			
	return moveableCells

static func coords_within_bounds(coords: Vector2) -> bool:
	var maxX = CombatMapStatus.mapX
	var maxY = CombatMapStatus.mapY
	
	if coords.x < 0 or coords.x >= maxX or coords.y < 0 or coords.y >= maxY:
		return false
	else:
		return true

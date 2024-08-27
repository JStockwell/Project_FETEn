class_name EnemyBehavior


static func dumb_melee_behavior(map) -> bool:

	var enemy = CombatMapStatus.get_selected_character()
	var dijkstra = _dijkstra(map, enemy.get_map_coords(), enemy.get_movement())
	var possibleTargets = check_players_in_range(map, enemy, dijkstra[0])
	
	if (possibleTargets.is_empty()): # currently doesnt take into account root or a unit being in those tiles, but it will do for basic testing
		melee_movement(map, enemy, dijkstra[0])
		return false
	else:
		var finalTargetId = randi_range(1,len(possibleTargets))
		var finalTarget = possibleTargets[finalTargetId-1]
		return melee_enemy_attack(map, enemy, finalTarget, dijkstra)


static func smart_melee_behavior(map) -> bool:
	var enemy = CombatMapStatus.get_selected_character()
	var dijkstra = _dijkstra(map, enemy.get_map_coords(), enemy.get_movement())
	var possibleTargets = check_players_in_range(map, enemy, dijkstra[0])
	
	if (possibleTargets.is_empty()): # currently doesnt take into account root or a unit being in those tiles, but it will do for basic testing
		melee_movement(map, enemy, dijkstra[0])
		return false
	else:
		var finalTarget = smart_enemy_target_choice(enemy, possibleTargets)
		return melee_enemy_attack(map, enemy, finalTarget, dijkstra)


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


static func melee_enemy_attack(map, enemy, finalTarget, dijkstra) -> bool:
	var rooted = enemy.is_rooted()
	var finalTargetCoords = finalTarget.get_map_coords()
	var moveableCells = dijkstra[0]
	var distToCell = dijkstra[1]
	const DIRECTIONS = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	
	if rooted or Utils.calc_distance(enemy.get_map_coords(),finalTargetCoords) == 1:
		CombatMapStatus.set_selected_enemy(finalTarget)
		return true
	else:
		var attackPoint
		var furthestAP = 0
		for dir in DIRECTIONS:
			var coordsPlusDir = finalTargetCoords+dir
			if moveableCells.has(finalTargetCoords+dir) and not map.get_tile_from_coords(finalTargetCoords+dir).is_populated() and furthestAP < distToCell[coordsPlusDir.x][coordsPlusDir.y]: #maybe function for the not populated shiez
				attackPoint = finalTargetCoords+dir
				furthestAP = distToCell[coordsPlusDir.x][coordsPlusDir.y]
		
		CombatMapStatus.set_selected_map_tile(map.get_tile_from_coords(attackPoint)) #there is no else to check for inappropriate movement since its literally impossible for the algorythm to reach this point if a tile wasnt previously valid
		
	map.move_character()
	return true

static func check_players_in_range(map, enemy, tilesRange) -> Array:
	var possible_Targets: Array
	var rooted = enemy.is_rooted()
	
	const DIRECTIONS = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]
	for character in map.characterGroup.get_children():
		if(rooted):
			if (Utils.calc_distance(enemy.get_map_coords(), character.get_map_coords())<=enemy.get_range()):
				possible_Targets.append(character)
			
		else:
			var viable_target = false
			for dir in DIRECTIONS:
				if tilesRange.has(Vector2(character.get_map_coords()+dir) and not map.is_populated(character.get_map_coords()+dir)): #If the target has an adjacent tile that is accessible and is not populated and is in range then it is a valid target
					viable_target = true
					
			if viable_target == true:
				possible_Targets.append(character)
				
	enemy.set_is_rooted(false)
	return possible_Targets

static func check_closest_player(map, enemy): #we can get everything in the mega if here if wanted and rename func to get_near_closest_player
	var closestTargetDist = 100
	var closestTarget
	var dijkstra = _dijkstra(map, enemy.get_map_coords, 72) #traversing 1 corner to the other of a 16*16 map with all tiles being dif terrain and 8 zones of control in the path is about 72 movement cost, technically we can remove 4 since the enemy and player have to be within bounds
	var distances = dijkstra[1]
	for character in map.characterGroup.get_children():
		var characterPosition = character.get_map_coords()
		if (dijkstra[1][characterPosition[0]][characterPosition[1]]<closestTargetDist):
			closestTargetDist = dijkstra[1][characterPosition[0]][characterPosition[1]]
			closestTarget = character
			
	return [closestTarget, distances]
	
static func melee_movement(map, enemy, tilesInReach): #it is used in the case that the enemy cant reach a valid attack target
	var chosenTile = enemy.get_map_coords()
	var rooted = enemy.is_rooted()
	
	if(not rooted):
		var players = []
		var checkClosestPlayer = check_closest_player(map, enemy)
		var closestTarget = checkClosestPlayer[0] # closest player returns the closest player
		var distances = checkClosestPlayer[1] # and the distances that it calculated with a WAAAAY bigger range
		var closestMove = -100
		
		for character in map.characterGroup.get_children():
			for tile in tilesInReach:
				var movementFitness = distances[tile.x][tile.y] - Utils.calc_distance(character.get_map_coords(), tile)
				if movementFitness > closestMove and not map.get_tile_from_coords(tile).is_populated():
					closestMove = movementFitness
					chosenTile = tile
	
	CombatMapStatus.set_selected_map_tile(map.get_tile_from_coords(chosenTile))
	map.move_character()
	
static func validate_movement(map, finalCoords: Vector2) -> bool: #much vestigial, such wow
	var condition1 = map.get_tile_from_coords(finalCoords).is_traversable()
	var condition2 = not map.get_tile_from_coords(finalCoords).is_populated()
	return condition1 and condition2

static func _dijkstra(map, mapCoords: Vector2, maxRange: int) -> Array:
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
		print(current.get_coords())
		print(DIRECTIONS)
		visited[current.get_coords().x][current.get_coords().y] = true
		
		for dir in DIRECTIONS:
			var coordinates =  current.get_coords() + dir
			if valid_coordinates(map, coordinates): # if it is traversable and it is within the map, does not check if a player is in it, check later.
				var visitedTile = visited[coordinates.y][coordinates.x][0]
				if visitedTile: # if it was already visited that means that the tile had a better/equal path to it due to the prio queue
					continue
				else:
					var extraCost = 0
					var meVoyDeBirras = map.get_tile_from_coords(coordinates).is_control_zone()
					
					if meVoyDeBirras: # reworkeado, la casilla que mira es en entrada y reduce en 1 el mov en lugar de 2, checkea que la zona de inicio de la unidad sea zona de control antes de llamarlo
						extraCost += 1
					elif map.get_tile_from_coords(coordinates).is_difficult_terrain():
						extraCost += 1
					tileCost = 1 + extraCost
					
					distanceToNode = current.priority + tileCost
					
					visited[coordinates.y][coordinates.x] = true
					distances[coordinates.y][coordinates.x] = distanceToNode
				
				if distanceToNode <= maxRange or current.priority + 1 <= maxRange: #the second part of the or should allwo for allowing moving a cost 2 with only 1 mov or a cost 3 with 1-2 mov left
					previous[coordinates.y][coordinates.x] = current.get_coords()
					moveableCells.append(coordinates)
					pQ.push(coordinates, distanceToNode)
				
			if pQ.is_empty():
				break
			
	return [moveableCells, distances]

static func valid_coordinates(map, coords: Vector2) -> bool: #this function checks that the coords provided are in the map AND that the tile is not an obstacle
	var maxX = CombatMapStatus.mapX
	var maxY = CombatMapStatus.mapY
	
	if coords.x < 0 or coords.x >= maxX or coords.y < 0 or coords.y >= maxY:
		return false
	elif not map.get_tile_from_coords(coords).is_traversable():
		return false
	else:
		return true


class_name EnemyBehavior


static func dumb_melee_behavior(map) -> bool:

	var enemy = CombatMapStatus.get_selected_character()
	var dijkstra
	if map.get_tile_from_coords(enemy.get_map_coords()).is_checked():
		dijkstra = _dijkstra(map, enemy.get_map_coords(), enemy.get_movement()-1)
	else:
		dijkstra = _dijkstra(map, enemy.get_map_coords(), enemy.get_movement())
	
	var possibleTargets = check_players_in_range(map, enemy, dijkstra[0])
	
	if (possibleTargets.is_empty()):
		approach_enemy(map, enemy, dijkstra[0])
		return false
	else:
		var finalTargetId = randi_range(1,len(possibleTargets))
		var finalTarget = possibleTargets[finalTargetId-1]
		return melee_enemy_attack(map, enemy, finalTarget, dijkstra)

static func smart_melee_behavior(map) -> bool:
	var enemy = CombatMapStatus.get_selected_character()
	var dijkstra
	if map.get_tile_from_coords(enemy.get_map_coords()).is_checked():
		dijkstra = _dijkstra(map, enemy.get_map_coords(), enemy.get_movement()-1)
	else:
		dijkstra = _dijkstra(map, enemy.get_map_coords(), enemy.get_movement())
		
	var possibleTargets = check_players_in_range(map, enemy, dijkstra[0])
	
	if (possibleTargets.is_empty()): # currently doesnt take into account root or a unit being in those tiles, but it will do for basic testing
		approach_enemy(map, enemy, dijkstra[0])
		return false
	else:
		var finalTarget = smart_enemy_target_choice(map, enemy, possibleTargets, false)
		return melee_enemy_attack(map, enemy, finalTarget, dijkstra)

# melee only function
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
				if map.check_within_bounds(character.get_map_coords(),dir):
					if tilesRange.has(character.get_map_coords()+dir) and not map.get_tile_from_coords(character.get_map_coords()+dir).is_populated(): #If the target has an adjacent tile that is accessible and is not populated and is in range then it is a valid target
						viable_target = true
					
			if viable_target == true:
				possible_Targets.append(character)
				
	return possible_Targets

# melee only function
static func melee_enemy_attack(map, enemy, finalTarget, dijkstra) -> bool:
	var rooted = enemy.is_rooted()
	var finalTargetCoords = finalTarget.get_map_coords()
	var moveableCells = dijkstra[0]
	var distToCell = dijkstra[1]
	const DIRECTIONS = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	
	if rooted or Utils.calc_distance(enemy.get_map_coords(),finalTargetCoords) == 1:
		CombatMapStatus.set_selected_enemy(finalTarget)
		enemy.set_is_rooted(false) #once the AI has finished calculating everything for the turn set rooted false
		return true
	else:
		var attackPoint
		var furthestAP = 0
		for dir in DIRECTIONS:
			var coordsPlusDir = finalTargetCoords+dir
			var tileDistance = distToCell[coordsPlusDir.y][coordsPlusDir.x]
			var tileDistanceInt: int

			if typeof(tileDistance) == 28: # in case it randomly decides to make it a list or an int
				tileDistanceInt = tileDistance[0]
			else:
				tileDistanceInt = tileDistance
			
			if moveableCells.has(finalTargetCoords+dir) and not map.get_tile_from_coords(finalTargetCoords+dir).is_populated() and furthestAP < tileDistanceInt: #maybe function for the not populated shiez
				attackPoint = finalTargetCoords+dir
				furthestAP = distToCell[coordsPlusDir.y][coordsPlusDir.x]
			
		CombatMapStatus.set_selected_enemy(finalTarget)
		CombatMapStatus.set_selected_map_tile(map.get_tile_from_coords(attackPoint)) #there is no else to check for inappropriate movement since its literally impossible for the algorythm to reach this point if a tile wasnt previously valid
		
	map.move_character()
	return true


static func dumb_ranged_behavior(map) -> bool:
	var enemy = CombatMapStatus.get_selected_character()
	var dijkstra
	if map.get_tile_from_coords(enemy.get_map_coords()).is_checked():
		dijkstra = _dijkstra(map, enemy.get_map_coords(), enemy.get_movement()-1)
	else:
		dijkstra = _dijkstra(map, enemy.get_map_coords(), enemy.get_movement())
		
	var possibleTargets = check_players_in_range(map, enemy, dijkstra[0])
	
	if (possibleTargets.is_empty()):
		approach_enemy(map, enemy, dijkstra[0])
		return false
	else:
		var finalTargetId = randi_range(1,len(possibleTargets))
		var finalTarget = possibleTargets[finalTargetId-1]
		var optimalTile = find_optimal_shot(map, dijkstra, finalTarget)
		return ranged_enemy_attack(map, enemy, finalTarget, dijkstra, optimalTile)

static func smart_ranged_behavior(map) -> bool:
	var enemy = CombatMapStatus.get_selected_character()
	var dijkstra
	if map.get_tile_from_coords(enemy.get_map_coords()).is_checked():
		dijkstra = _dijkstra(map, enemy.get_map_coords(), enemy.get_movement()-1)
	else:
		dijkstra = _dijkstra(map, enemy.get_map_coords(), enemy.get_movement())
		
	var possibleTargets = check_players_in_range(map, enemy, dijkstra[0])
	
	if (possibleTargets.is_empty()):
		approach_enemy(map, enemy, dijkstra[0])
		return false
	else:
		var finalTarget = smart_enemy_target_choice(map, enemy, possibleTargets, enemy.get_id())
		var optimalTile = find_optimal_shot(map, dijkstra, finalTarget)
		return ranged_enemy_attack(map, enemy, finalTarget, dijkstra, optimalTile)

# ranged only function
static func find_optimal_shot(map, dijkstra, finalTarget) -> Vector2:
	var moveableTiles = dijkstra[0]
	var bestMod = -1000
	var bestModPosition: Vector2
	var heightPC = map.get_tile_from_coords(finalTarget.get_map_coords()).get_height()
	var difTerrain = 0
	if map.get_tile_from_coords(finalTarget.get_map_coords()).is_difficult_terrain():
		difTerrain = 10
	for y in range(moveableTiles.size()):
		for x in range(moveableTiles[y].size()):
			if moveableTiles[y][x] and not map.calc_los(Vector2(x,y), finalTarget.get_map_coords())[0]:
				var coverMod = map.calc_los(Vector2(x,y), finalTarget.get_map_coords())[1]
				var heightEnemy = map.get_tile_from_coords(Vector2(x,y)).get_height()
				var currentMod = 5*(heightEnemy-heightPC)-coverMod+difTerrain
				if bestMod < currentMod:
					bestModPosition = Vector2(x,y)
					bestMod = currentMod
					
	return bestModPosition

# ranged only function
static func ranged_enemy_attack(map, enemy, finalTarget, dijkstra, optimalTile) -> bool:
	var rooted = enemy.is_rooted()
	var finalTargetCoords = finalTarget.get_map_coords()
	var moveableCells = dijkstra[0]
	var distToCell = dijkstra[1]
	
	if rooted: #has line of sight and no movement, therefore just shoots:
		CombatMapStatus.set_selected_enemy(finalTarget)
		enemy.set_is_rooted(false)
		return true
	elif optimalTile == enemy.get_map_coords:
		CombatMapStatus.set_selected_enemy(finalTarget)
		return true # find a way to move after shooting 
	else:
		CombatMapStatus.set_selected_enemy(finalTarget)
		CombatMapStatus.set_selected_map_tile(map.get_tile_from_coords(optimalTile))
	
	map.move_character()
	return true

# ranged only function
static func check_players_in_range_ranged(map, enemy, tilesRange) -> Array:
	var possible_Targets: Array
	var rooted = enemy.is_rooted()
	
	const DIRECTIONS = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]
	for character in map.characterGroup.get_children():
		var target = character.get_map_coords()
		var attackCoords = enemy.get_map_coords()
		if(rooted):
			if Utils.calc_distance(attackCoords, target)<=enemy.get_range() and not map.get_los(attackCoords, target)[0]:
				possible_Targets.append(character)
			
		else:
			var viableTarget = viable_ranged_target(map, enemy, target, tilesRange) 
			if viableTarget == true:
				possible_Targets.append(character)
				
	return possible_Targets

# ranged only function
static func viable_ranged_target(map, enemy, target, tilesRange) -> bool: # ugly ahh function
	var viableTarget = false
	for y in range((tilesRange).size()):
		if viableTarget == false:
			for x in range((tilesRange[y]).size()):
				if tilesRange[y][x]:
					if not map.calc_los(Vector2(x,y), target)[0] and map.calc_distance(Vector2(x,y), target) <= enemy.get_range():
						viableTarget = true
		else:
			break
	return viableTarget

# generic for now but probably will stay as only melee unless we want to tweak the hell out of it to account for cover
static func smart_enemy_target_choice(map, enemy, possibleTargets, enemyType):
	var finalTarget
	var damageValue: int
	var precision: float
	var appetizingTarget: float
	var previousBest = 0.1
	var killRange: int
	
	for playerCharacter in possibleTargets:
		damageValue = enemy.get_attack()-playerCharacter.get_defense()
		var difTerrain = 0
		if map.get_tile_from_coords(playerCharacter.get_map_coords()).is_difficult_terrain():
			difTerrain = 10
			
		precision = 50+enemy.get_dexterity()*5-playerCharacter.get_agility()*3+difTerrain #missing map tile modifiers
		
		if enemyType == "mage":
			if 12 >= playerCharacter.get_current_health():
				killRange = 10
			else:
				killRange = 0
			
			var missingHp = playerCharacter.get_max_health()-playerCharacter.get_current_health()
			appetizingTarget = (12+killRange+playerCharacter.get_armor())*precision
			
		else:
			if damageValue >= playerCharacter.get_current_health():
				killRange = 5
			else:
				killRange = 0
			
			appetizingTarget = (damageValue+killRange)*precision
			
		if previousBest<appetizingTarget:
			previousBest = appetizingTarget
			finalTarget = playerCharacter
		
	return finalTarget

# generic across ranged and melee
static func check_closest_player(map, enemy): # gets closest target, used in approach enemy
	var closestTargetDist = 100
	var closestTarget
	var dijkstra = _dijkstra(map, enemy.get_map_coords(), 72) #traversing 1 corner to the other of a 16*16 map with all tiles being dif terrain and 8 zones of control in the path is about 72 movement cost, technically we can remove 4 since the enemy and player have to be within bounds
	var distances = dijkstra[1]
	for character in map.characterGroup.get_children():
		var characterPosition = character.get_map_coords()
		if distances[characterPosition.y][characterPosition.x]<closestTargetDist:
			closestTargetDist = distances[characterPosition.y][characterPosition.x]
			closestTarget = character
			
	return [closestTarget, distances]

# generic across ranged and melee
static func approach_enemy(map, enemy, tilesInReach): # if cant attack anyone, approaches closest target, both melee/ranged
	var chosenTile = enemy.get_map_coords()
	var rooted = enemy.is_rooted()
	
	if not rooted:
		var players = []
		var checkClosestPlayer = check_closest_player(map, enemy)
		var closestTarget = checkClosestPlayer[0] # closest player returns the closest player
		var distances = checkClosestPlayer[1] # and the distances that it calculated with a WAAAAY bigger range     change for dict new dijkstra
		var closestMove = -100
		
		for character in map.characterGroup.get_children():
			
			for tile in tilesInReach:
				var movementFitness = distances[tile.y][tile.x] - Utils.calc_distance(character.get_map_coords(), tile)
				if movementFitness > closestMove and not map.get_tile_from_coords(tile).is_populated():
					closestMove = movementFitness
					chosenTile = tile
	else:
		enemy.set_is_rooted(false) #once the AI has finished calculating everything for the turn set rooted false
		
	CombatMapStatus.set_selected_map_tile(map.get_tile_from_coords(chosenTile))
	map.move_character()

# generic across ranged and melee
static func valid_coordinates(map, coords: Vector2, tilesOccupiedOponents) -> bool: # we could do enemy collision on movement here very easy
	var maxX = CombatMapStatus.mapX
	var maxY = CombatMapStatus.mapY
	var activeCharacter = CombatMapStatus.get_selected_character()
	
	if coords.x < 0 or coords.x >= maxX or coords.y < 0 or coords.y >= maxY:
		return false
	elif not map.get_tile_from_coords(coords).is_traversable():
		return false
	elif tilesOccupiedOponents.has(coords):
		return false
	else:
		return true

# generic across ranged and melee
static func _dijkstra(map, mapCoords: Vector2, maxRange: int) -> Array: # we could include the half cover mov cost here and make it traversable
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
	var tilesOccupiedOponents = []
	var enemyAligned = CombatMapStatus.get_selected_character().is_enemy()
	
	if enemyAligned:
		for character in map.characterGroup.get_children():
			tilesOccupiedOponents.append(character.get_map_coords())
	else:
		for enemy in map.enemyGroup.get_children():
			tilesOccupiedOponents.append(enemy.get_map_coords())
	
	# start the search
	for i in range(1000):
		var current = pQ.pop()
		visited[current.get_coords().y][current.get_coords().x] = true
		for dir in DIRECTIONS:
			var coordinates =  current.get_coords() + dir
			if valid_coordinates(map, coordinates, tilesOccupiedOponents): # if it is traversable and it is within the map and if occupied is by an ally, does not check if a player is in it, check later.
				var visitedTile = visited[coordinates.y][coordinates.x]
				var visitedTileBool: bool
				var typeOfBullshit = typeof(visitedTile)
				if not typeof(visitedTile)==1:
					visitedTileBool = visitedTile[0]
				else:
					visitedTileBool = visitedTile
				
				if visitedTileBool: # if it was already visited that means that the tile had a better/equal path to it due to the prio queue
					continue
				else:
					var extraCost = 0
					var controlZone = map.get_tile_from_coords(coordinates).is_control_zone()
					#var allyControlZone = map.get_tile_from_coords(coordinates).is_ally_control_zone() #applies correct zones of control
					
					if controlZone and not enemyAligned: # mira entrada y el coste es 1, reduce el rango del dijkstra si empieza en una
						extraCost += 1
					#elif allyControlZone and enemyAligned:
						#extraCost += 1
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

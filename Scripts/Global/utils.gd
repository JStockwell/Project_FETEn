class_name Utils

static func reset_all():
	reset_gs()
	reset_cms()
	
static func reset_gs():
	GameStatus.playableCharacters = {}
	GameStatus.enemySet = {}
	GameStatus.skillSet = {}

	GameStatus.party = {}

static func reset_cms():
	CombatMapStatus.mapX = 0
	CombatMapStatus.mapY = 0

	CombatMapStatus.selectedCharacter = null
	CombatMapStatus.selectedEnemy = null
	CombatMapStatus.selectedAlly = null
	CombatMapStatus.selectedMapTile = null

	CombatMapStatus.attackerStats = {}
	CombatMapStatus.defenderStats = {}

	CombatMapStatus.mapMod = 0
	CombatMapStatus.attackRange = 0
	CombatMapStatus.attackSkill = ""

	CombatMapStatus.isStartCombat = true
	CombatMapStatus.initiative = []
	CombatMapStatus.currentIni = 0

	CombatMapStatus.hasAttacked = false
	CombatMapStatus.hasAttacked = false

	CombatMapStatus.mapTileMatrix = []

static func calc_distance(vect_1: Vector2, vect_2: Vector2) -> int:
	return abs(vect_1.x - vect_2.x) + abs(vect_1.y - vect_2.y)

static func read_json(jsonPath: String) -> Dictionary:
	if FileAccess.file_exists(jsonPath):
		var dataFile = FileAccess.open(jsonPath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		
		if parsedResult is Dictionary:
			return parsedResult
		else:
			push_error("Error reading file " + jsonPath)
			return {}
			
	else:
		push_error("File {path} doesn't exist!".format({"path": jsonPath}))
		return {}
		
static func generate_rolls() -> Array:
	# true_hit_flag, dice_1, dice_2, crit_roll
	return [randi_range(1, 2), randi_range(1, 100), randi_range(1, 100), randi_range(1, 100)]

static func string_to_vector2(vectorString:= "") -> Vector2:
	if vectorString:
		var new_string: String = vectorString
		new_string = new_string.erase(0, 1)
		new_string = new_string.erase(new_string.length() - 1, 1)
		var array: Array = new_string.split(",")

		return Vector2(int(array[0]), int(array[1]))

	return Vector2.ZERO


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
					
					if controlZone:
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


# generic across ranged and melee
static func valid_coordinates(map, coords: Vector2, tilesOccupiedOponents) -> bool:
	var maxX = CombatMapStatus.mapX
	var maxY = CombatMapStatus.mapY
	var activeCharacter = CombatMapStatus.get_selected_character()
	
	if coords.x < 0 or coords.x >= maxX or coords.y < 0 or coords.y >= maxY:
		return false
	elif not map.get_tile_from_coords(coords).is_traversable():
		return false
	elif tilesOccupiedOponents.has(coords): #we could make it so that the assassin can traverse enemies, may be interesting
		return false
	else:
		return true

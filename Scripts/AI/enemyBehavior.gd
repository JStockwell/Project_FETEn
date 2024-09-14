class_name EnemyBehavior

static func dumb_melee_behavior(map, dijkstra) -> bool:

	var enemy = CombatMapStatus.get_selected_character()	
	var possibleTargets = check_players_in_range(map, enemy, dijkstra[0])
	
	if (possibleTargets.is_empty()):
		approach_enemy(map, enemy, dijkstra[0])
		return false
	else:
		var finalTargetId = randi_range(1,len(possibleTargets))
		var finalTarget = possibleTargets[finalTargetId-1]
		return melee_enemy_attack(map, enemy, finalTarget, dijkstra)

static func smart_melee_behavior(map, dijkstra) -> bool:
	var enemy = CombatMapStatus.get_selected_character()
	var possibleTargets = check_players_in_range(map, enemy, dijkstra[0])
	
	if (possibleTargets.is_empty()): # currently doesnt take into account root or a unit being in those tiles, but it will do for basic testing
		approach_enemy(map, enemy, dijkstra[0])
		return false
	else:
		var finalTarget = smart_enemy_target_choice(map, enemy, possibleTargets, enemy.get_id())
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
					var tileInQuestion = map.get_tile_from_coords(character.get_map_coords()+dir)
					if tilesRange.has(character.get_map_coords()+dir) and not tileInQuestion.is_populated() and not tileInQuestion.get_obstacle_type() == 1: #If the target has an adjacent tile that is accessible and is not populated and is in range then it is a valid target
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
	var tilesOccupiedOpponents = []
	
	for character in map.characterGroup.get_children():
		tilesOccupiedOpponents.append(character.get_map_coords())
	
	if rooted or Utils.calc_distance(enemy.get_map_coords(),finalTargetCoords) == 1:
		CombatMapStatus.set_selected_enemy(finalTarget)
		enemy.set_is_rooted(false) #once the AI has finished calculating everything for the turn set rooted false
		return true
	else:
		var attackPoint
		var furthestAP = 0
		for dir in DIRECTIONS:
			if Utils.valid_coordinates(map, finalTargetCoords+dir, tilesOccupiedOpponents):
				var coordsPlusDir = finalTargetCoords+dir
				var tileDistance = distToCell[coordsPlusDir.y][coordsPlusDir.x]
				var tileDistanceInt: int

				if typeof(tileDistance) == 28: # in case it randomly decides to make it a list or an int
					tileDistanceInt = tileDistance[0]
				else:
					tileDistanceInt = tileDistance
				
				var tileInQuestion = map.get_tile_from_coords(finalTargetCoords+dir)
				if moveableCells.has(finalTargetCoords+dir) and not tileInQuestion.is_populated() and furthestAP < tileDistanceInt and not tileInQuestion.get_obstacle_type() == 1:
					attackPoint = finalTargetCoords+dir
					furthestAP = distToCell[coordsPlusDir.y][coordsPlusDir.x]
			
		CombatMapStatus.set_selected_enemy(finalTarget)
		CombatMapStatus.set_selected_map_tile(map.get_tile_from_coords(attackPoint)) #there is no else to check for inappropriate movement since its literally impossible for the algorythm to reach this point if a tile wasnt previously valid
		
	map.move_character()
	return true


static func dumb_ranged_behavior(map, dijkstra) -> bool:
	var enemy = CombatMapStatus.get_selected_character()
	var possibleTargets = check_players_in_range_ranged(map, enemy, dijkstra[0])
	
	if (possibleTargets.is_empty()):
		approach_enemy(map, enemy, dijkstra[0])
		return false
	else:
		var finalTargetId = randi_range(1,len(possibleTargets))
		var finalTarget = possibleTargets[finalTargetId-1]
		var viableShootingPositions = viable_ranged_positions(map, enemy, finalTarget, dijkstra[0])
		var optimalTile = find_optimal_shot(map, finalTarget, viableShootingPositions) # TODO check to include position of not only the shot but also safety of the mf taking it
		return ranged_enemy_attack(map, enemy, finalTarget, dijkstra, optimalTile)


static func smart_ranged_behavior(map, dijkstra) -> bool:
	var enemy = CombatMapStatus.get_selected_character()
	var possibleTargets = check_players_in_range_ranged(map, enemy, dijkstra[0])
	
	if (possibleTargets.is_empty()):
		approach_enemy(map, enemy, dijkstra[0])
		return false
	else:
		var finalTarget = smart_enemy_target_choice(map, enemy, possibleTargets, enemy.get_id())
		if typeof(finalTarget) == 28: #another russian roulette woooo
			finalTarget = finalTarget[0]
			
		CombatMapStatus.set_selected_enemy(finalTarget) # to allow recognition for the mage skill
		
		var viableShootingPositions = viable_ranged_positions(map, enemy, finalTarget, dijkstra[0])
		var optimalTile = find_optimal_shot(map, finalTarget, viableShootingPositions)
		return ranged_enemy_attack(map, enemy, finalTarget, dijkstra, optimalTile)

# ranged only function
static func find_optimal_shot(map, finalTarget, viableShootingPositions) -> Vector2:
	var moveableTiles = viableShootingPositions
	var bestMod = -1000
	var bestModPosition: Vector2
	var heightPC = map.get_tile_from_coords(finalTarget.get_map_coords()).get_height()
	var difTerrain = 0
	if map.get_tile_from_coords(finalTarget.get_map_coords()).is_difficult_terrain():
		difTerrain = 10
	for tile in range(moveableTiles.size()):
		if not map.calc_los(moveableTiles[tile], finalTarget)[0]:
			var coverMod = map.calc_los(moveableTiles[tile], finalTarget)[1]
			var heightEnemy = map.get_tile_from_coords(moveableTiles[tile]).get_height()
			var currentMod = 5*(heightEnemy-heightPC)-coverMod+difTerrain
			
			#if the tile selected was in zone of control of a player account for the negative
			if map.get_tile_from_coords(moveableTiles[tile]).is_control_zone():
				currentMod -= 30 #+5% to incite enemies to move away from melee range of other units
			
			if bestMod < currentMod:
				bestModPosition = moveableTiles[tile]
				bestMod = currentMod
			# in case multiple ranged shots are of same mod but one is further from the target stick to the furthest tile possible
			elif bestMod == currentMod and Utils.calc_distance(finalTarget.get_map_coords(), moveableTiles[tile]) > Utils.calc_distance(finalTarget.get_map_coords(), bestModPosition):
				bestModPosition = moveableTiles[tile]
				bestMod = currentMod
		
	return bestModPosition

# ranged only function
static func ranged_enemy_attack(map, enemy, finalTarget, dijkstra, optimalTile) -> bool:
	var rooted = enemy.is_rooted()
	var finalTargetCoords = finalTarget.get_map_coords()
	
	if rooted: #has line of sight and no movement, therefore just shoots:
		CombatMapStatus.set_selected_enemy(finalTarget)
		enemy.set_is_rooted(false)
		return true
	elif optimalTile == enemy.get_map_coords():
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
	
	const DIRECTIONS = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN] #delet this
	for character in map.characterGroup.get_children():
		var target = character.get_map_coords()
		if(rooted):
			var attackCoords = enemy.get_map_coords() # attack coordinates should only be moved in the if rooted
			if Utils.calc_distance(attackCoords, target)<=enemy.get_range() and not map.calc_los(attackCoords, character)[0]:
				possible_Targets.append(character)
			
		else:
			var viableTarget = viable_ranged_target(map, enemy, character, tilesRange)
			if viableTarget == true:
				possible_Targets.append(character)
				
	return possible_Targets

# ranged only function
static func viable_ranged_target(map, enemy, target, tilesRange) -> bool: # ugly ahh function
	var viableTarget = false
	for tile in tilesRange: #turn to tiles in tilesRange
		if viableTarget == false:			
			if not map.calc_los(tile, target)[0] and Utils.calc_distance(tile, target.get_map_coords()) <= enemy.get_range() and not map.get_tile_from_coords(tile).get_obstacle_type() == 1:
				viableTarget = true
		else:
			break
	return viableTarget
	

static func viable_ranged_positions(map, enemy, target, tilesRange) -> Array: # ugly ahh function
	var viableShootingPositions = []
	for tile in range(tilesRange.size()):
		if not map.calc_los(tilesRange[tile], target)[0]:
			var tileInQuestion = map.get_tile_from_coords(tilesRange[tile])
			if Utils.calc_distance(tilesRange[tile], target.get_map_coords()) <= enemy.get_range() and not tileInQuestion.is_populated() and not tileInQuestion.get_obstacle_type() == 1:
				viableShootingPositions.append(tilesRange[tile])
	return viableShootingPositions

# generic for now and will probably will stay unless we want to tweak the hell out of it to account for cover
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
			appetizingTarget = (12+killRange+playerCharacter.get_defense())*precision
			
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
	var dijkstra = Utils._dijkstra(map, enemy.get_map_coords(), 72) #traversing 1 corner to the other of a 16*16 map with all tiles being dif terrain and 8 zones of control in the path is about 72 movement cost, technically we can remove 4 since the enemy and player have to be within bounds
	var distances = dijkstra[1]
	for character in map.characterGroup.get_children():
		var characterPosition = character.get_map_coords()
		if distances[characterPosition.y][characterPosition.x][0]<closestTargetDist:
			closestTargetDist = distances[characterPosition.y][characterPosition.x][0]
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
				var tileInQuestion = map.get_tile_from_coords(tile)
				if movementFitness > closestMove and not tileInQuestion.is_populated() and not tileInQuestion.get_obstacle_type() == 1:
					closestMove = movementFitness
					chosenTile = tile
	else:
		enemy.set_is_rooted(false) #once the AI has finished calculating everything for the turn set rooted false
		
	CombatMapStatus.set_selected_map_tile(map.get_tile_from_coords(chosenTile))
	map.move_character()

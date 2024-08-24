class_name EnemyBehavior

static func dumb_melee_behavior(map) -> bool:
	var enemy = CombatMapStatus.get_selected_character()
	var possibleTargets = check_players_in_range(map, enemy)
	var rooted = enemy.is_rooted()
	
	if (possibleTargets.is_empty()): # currently doesnt take into account root or a unit being in those tiles, but it will do for basic testing
		melee_movement(map, enemy, 0)
		return false
	else:
		var finalTargetId = randi_range(1,len(possibleTargets))
		var finalTarget = possibleTargets[finalTargetId-1]
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
			if (Utils.calc_distance(enemy.get_map_coords(), character.get_map_coords())<=enemy.get_range()):
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
	var leftoverMov: int
	var posX: int
	var posY: int = enemy.get_map_coords()[1]
	
	if(abs(enemy.get_map_coords()[0]-closestTarget.get_map_coords()[0])<enemy.get_movement()-reach):
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

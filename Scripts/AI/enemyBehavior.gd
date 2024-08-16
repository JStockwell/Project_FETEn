class_name EnemyBehavior

static func dumb_melee_behavior(map) -> void:
	var enemy = CombatMapStatus.get_selected_character()
	var possibleTargets = check_players_in_range(map, enemy)
	if (possibleTargets.is_empty()): # currently doesnt take into account root or a unit being in those tiles, but it will do for basic testing
		var closestTarget = check_closest_player(map, enemy)
		var coordinates_x = [enemy.get_map_coords()[0], closestTarget.get_map_coords()[0]]
		var coordinates_y = [enemy.get_map_coords()[1], closestTarget.get_map_coords()[1]]
		var leftoverMov: int
		var posX: int
		var posY: int
		if (coordinates_x.max()-coordinates_x.min() <= coordinates_y.max()-coordinates_y.min() && coordinates_x.max()-coordinates_x.min() <= enemy.get_movement()):
			posX = closestTarget.get_map_coords()[0]
			leftoverMov = enemy.get_movement()-(coordinates_x.max()-coordinates_x.min())
			if(coordinates_y.max() == enemy.get_map_coords()[1]):
				posY = coordinates_y.min()+leftoverMov
			else:
				posY = coordinates_y.max()-leftoverMov
		elif (coordinates_x.max()-coordinates_x.min() <= coordinates_y.max()-coordinates_y.min()):
			if(coordinates_x.max() == enemy.get_map_coords()[0]):
				posX = coordinates_x.min()+enemy.get_movement()
			else:
				posX = coordinates_x.max()-enemy.get_movement()
		elif (coordinates_y.max()-coordinates_y.min() <= enemy.get_movement()):
			posY = closestTarget.get_map_coords()[1]
			leftoverMov = enemy.get_movement()-(coordinates_y.max()-coordinates_y.min())
			if(coordinates_x.max() == enemy.get_map_coords()[0]):
				posX = coordinates_x.min()+leftoverMov
			else:
				posX = coordinates_x.max()-leftoverMov
		else:
			if(coordinates_y.max() == enemy.get_map_coords()[1]):
				posY = coordinates_y.min()+enemy.get_movement()
			else:
				posY = coordinates_y.max()-enemy.get_movement()
			
	else:
		var finalTargetId = randi_range(1,possibleTargets.len())
		var finalTarget = possibleTargets[finalTargetId-1]
		enemy.set_map_coords(finalTarget.get_map_coords()[0], finalTarget.get_map_coords()[1]+1)
		
	
	
	pass

static func check_players_in_range(map, enemy) -> Array:
	var possible_Targets: Array
	for character in map.characterGroup.get_children():
		var coordinates_x = [enemy.get_map_coords()[0], character.get_map_coords()[0]]
		var coordinates_y = [enemy.get_map_coords()[1], character.get_map_coords()[1]]
		if ((coordinates_x.max()-coordinates_x.min())+(coordinates_y.max()-coordinates_y.min())<=8-(enemy.get_movement()+enemy.get_range())):
			possible_Targets.append(character)

	return possible_Targets

static func check_closest_player(map, enemy):
	var closestTargetDist = 100
	var closestTarget
	for character in map.characterGroup.get_children():
		var coordinates_x = [enemy.get_map_coords()[0], character.get_map_coords()[0]]
		var coordinates_y = [enemy.get_map_coords()[1], character.get_map_coords()[1]]
		if ((coordinates_x.max()-coordinates_x.min())+(coordinates_y.max()-coordinates_y.min())<closestTargetDist):
			closestTarget = character
			
	return closestTarget

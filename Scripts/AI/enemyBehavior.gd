class_name EnemyBehavior

static func dumb_melee_behavior(map) -> void:
	var enemy = CombatMapStatus.get_selected_character()
	var possibleTargets = check_players_in_range(map, enemy)
	
	pass

static func check_players_in_range(map, enemy) -> Array:
	var possible_Targets: Array
	for character in map.characterGroup.get_children():
		var coordinates_x = [enemy.get_map_coords()[0], character.get_map_coords()[0]]
		var coordinates_y = [enemy.get_map_coords()[1], character.get_map_coords()[1]]
		if ((coordinates_x.max()-coordinates_x.min())+(coordinates_y.max()-coordinates_y.min())<=8-(enemy.get_movement()+enemy.get_range())):
			possible_Targets.append(character)
			print(possible_Targets)
			print(coordinates_x.max()-coordinates_x.min())
			print(coordinates_y.max()-coordinates_y.min())
			print(enemy.get_movement()+enemy.get_range())
	
	print(possible_Targets)
	return possible_Targets

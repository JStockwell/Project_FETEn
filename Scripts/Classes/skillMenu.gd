class_name SkillMenu

static func handle_skill(skillName: String, character, target) -> String:
	var error = ""
	var skill = GameStatus.skillSet[skillName]
	
	if character.get_current_mana() < skill.get_cost():
		error = "Not enough mana"
		
	elif skill.get_range() == 0:
		return error
		
	elif target == null:
		error = "Select a target"
		
	elif Utils.calc_distance(character.get_map_coords(), target.get_map_coords()) > skill.get_range():
		error = "Skill out of range"
	
	return error

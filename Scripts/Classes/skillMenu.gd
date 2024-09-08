class_name SkillMenu

#TODO revisar
static func validate_skill(skillName: String, character, target) -> String:
	var error = ""
	var skill = GameStatus.skillSet[skillName]
	
	if character.get_current_mana() < skill.get_cost():
		error = "Not enough mana"
		
	#elif skill.get_range() == 0:	# unsure on why its here, there are skills that can target self
		#return error
	
	#TODO cap de 30 de curación recibida por personaje
	
	elif target == null and not skill.can_target_allies():
		error = "Select a target"
		
	elif Utils.calc_distance(character.get_map_coords(), target.get_map_coords()) > skill.get_range():
		error = "Skill out of range"
	
	return error

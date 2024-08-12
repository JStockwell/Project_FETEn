class_name CharacterFactory

const Character = preload("res://Scenes/Entities/character.tscn")

const stats_list = ["name", "max_health", "attack", "dexterity", "defense", "agility", "movement", "ini_mana", "max_mana", "reg_mana", "range", "skills", "is_ranged", "mesh_path"]

static func create(args: Dictionary):
	var validator = true
	var stats_set: Dictionary
	
	for key in stats_list:
		if key not in args.keys():
			validator = false
	
	if validator:
		var character = Character.instantiate()
		stats_set = args
		
		if "current_health" not in stats_set:
			stats_set["current_health"] = stats_set["max_health"]
			stats_set["current_mana"] = stats_set["ini_mana"]
		
		else:
			if stats_set["current_health"] > stats_set["max_health"]:
				stats_set["current_health"] = stats_set["max_health"]
				
			if stats_set["current_mana"] > stats_set["max_mana"]:
				stats_set["current_mana"] = stats_set["max_mana"]
				
			if stats_set["current_health"] < 0:
				stats_set["current_health"] = 0
				
			if stats_set["current_mana"] < 0:
				stats_set["current_mana"] = 0
		
		var mesh_path = args["mesh_path"]
		
		if args["mesh_path"] == null:
			mesh_path = "res://Assets/Characters/Placeholder/Placeholder_Char.glb"
			
		character.stats = stats_set
		character.add_child(load(mesh_path).instantiate())
		return character
		
	else:
		print("Incorrect stats set")

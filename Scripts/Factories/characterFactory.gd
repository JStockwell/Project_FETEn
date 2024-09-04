class_name CharacterFactory

const Character = preload("res://Scenes/Entities/character.tscn")

const stats_list = ["id", "name", "max_health", "attack", "dexterity", "defense", "agility", "movement", "ini_mana", "max_mana", "reg_mana", "range", "skills", "is_ranged", "mesh_path", "sprite_path"]

static func create(args: Dictionary, duplicateFlag: bool):
	var validator = true
	var stats_set: Dictionary
	
	for key in stats_list:
		if key not in args.keys():
			validator = false
	
	if validator:
		var character = Character.instantiate()
		stats_set = args
		
		if "current_health" not in stats_set:
			stats_set["current_health"] = stats_set["max_health"] #not necessarily max health, player could be damaged from prev encounter/event
			stats_set["current_mana"] = stats_set["ini_mana"]
			stats_set["is_rooted"] = false
			stats_set["healing_threshold"] = 30
		
		else:
			character.cap_current_stats(stats_set)
		
		var mesh_path = args["mesh_path"]
		var sprite_path = args["sprite_path"]
		
		if args["mesh_path"] == "":
			mesh_path = "res://Assets/Characters/Placeholder/Placeholder_Char.glb"
		
		if args["sprite_path"] == "":
			sprite_path = "res://Assets/Characters/Placeholder/sprite_placeholder.png"
		
		if duplicateFlag:
			character.stats = stats_set.duplicate()
		
		else:
			character.stats = stats_set
		
		character.add_child(load(mesh_path).instantiate())
		return character
		
	else:
		printerr(args)
		push_error("Incorrect stats set")

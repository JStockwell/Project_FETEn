extends Control

var playableCharacters = read_json("res://Assets/json/players.json")
var enemySet = read_json("res://Assets/json/enemies.json")
var skill_set = read_json("res://Assets/json/skills.json")
	
func _ready():
	GameStatus.set_playable_characters(playableCharacters)
	GameStatus.set_party(["dick", "edgar"])
	GameStatus.set_enemy_set(enemySet)
	GameStatus.set_enemies(["phys_fodder", "phys_fodder"])
	
	for skillName in skill_set:
		GameStatus.skillSet[skillName] = Factory.Skill.create(skill_set[skillName])
		
	combat_debug_test()
	debug_map_combat_test()

func combat_debug_test():
	GameStatus.set_active_characters(GameStatus.get_party_member("edgar").get_stats(), GameStatus.get_party_member("dick").get_stats())
		
func debug_map_combat_test():
	CombatMapStatus.set_map_size(4,4)

func _on_debug_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/3D/mapCombat.tscn")

func read_json(jsonPath: String):
	if FileAccess.file_exists(jsonPath):
		var dataFile = FileAccess.open(jsonPath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		
		if parsedResult is Dictionary:
			return parsedResult
		else:
			print("Error reading file " + jsonPath)
			
	else:
		print("File {path} doesn't exist!".format({"path": jsonPath}))

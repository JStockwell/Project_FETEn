extends Control

var playableCharacters = read_json("res://Assets/json/players.json")
var enemySet = read_json("res://Assets/json/enemies.json")
var skill_set = read_json("res://Assets/json/skills.json")
	
func _ready():
	GameStatus.set_playable_characters(playableCharacters)
	GameStatus.set_party(["dick", "edgar"])
	GameStatus.set_enemy_set(enemySet)
	CombatMapStatus.set_enemies(["goblin", "goblin"])
	
	for skillName in skill_set:
		GameStatus.skillSet[skillName] = Factory.Skill.create(skill_set[skillName])
	
	combat_debug_test()
	debug_map_combat_test()

func combat_debug_test():
	CombatMapStatus.set_active_characters(GameStatus.get_party_member("edgar"), GameStatus.get_party_member("dick"))
		
func debug_map_combat_test():
	CombatMapStatus.set_map_size(6, 6)
	CombatMapStatus.set_is_start_combat(true)

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

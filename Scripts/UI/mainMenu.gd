extends Control

var playableCharacters = read_json("res://Assets/json/players.json")
var enemySet = read_json("res://Assets/json/enemies.json")
var skillSet = read_json("res://Assets/json/skills.json")
	
func _ready():
	GameStatus.set_playable_characters(playableCharacters)
	GameStatus.set_enemy_set(enemySet)
	
	GameStatus.set_party(["dick", "edgar"])
	CombatMapStatus.set_enemies(["goblin", "goblin"])
	
	var i = 0
	for skillName in skillSet:
		GameStatus.skillSet[skillName] = Factory.Skill.create(skillSet[skillName])
		GameStatus.skillSet[skillName].set_skill_menu_id(i)
		i += 1
	
	combat_debug_test()
	debug_map_combat_test()
	

func combat_debug_test():
	CombatMapStatus.set_active_characters(GameStatus.get_party_member("edgar"), GameStatus.get_party_member("dick"))
		
func debug_map_combat_test():
	CombatMapStatus.set_map_size(8, 8)
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

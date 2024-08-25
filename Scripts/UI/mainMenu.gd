extends Control

var playableCharacters = Utils.read_json("res://Assets/json/players.json")
var enemySet = Utils.read_json("res://Assets/json/enemies.json")
var skillSet = Utils.read_json("res://Assets/json/skills.json")
	
func _ready():
	GameStatus.set_playable_characters(playableCharacters)
	GameStatus.set_enemy_set(enemySet)
	
	GameStatus.set_party(["dick", "edgar", "samael"])
	
	var i = 0
	for skillName in skillSet:
		GameStatus.skillSet[skillName] = Factory.Skill.create(skillSet[skillName])
		GameStatus.skillSet[skillName].set_skill_menu_id(i)
		i += 1
	
	CombatMapStatus.set_map_path("res://Assets/json/maps/map1.json")

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/3D/tavern.tscn")

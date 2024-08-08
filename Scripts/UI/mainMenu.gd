extends Control

var Character = preload("res://Scenes/Entities/character.tscn")

func _ready():
	combat_debug_test()

func combat_debug_test():
	var debug_attacker_stats = {
		"name": "Dick",
		"max_health": 50,
		"attack": 14,
		"dexterity": 10,
		"defense": 7,
		"agility": 2,
		"movement": 4,
		"ini_mana": 0,
		"max_mana": 0,
		"reg_mana": 0,
		"range": 0,
		"skills": [],
		"mesh_path": null
	}
	
	var debug_defender_stats = {
		"name": "Edgar",
		"max_health": 32,
		"attack": 9,
		"dexterity": 10,
		"defense": 3,
		"agility": 7,
		"movement": 5,
		"ini_mana": 6,
		"max_mana": 25,
		"reg_mana": 8,
		"range": 5,
		"skills": [],
		"mesh_path": "res://Assets/Characters/Party/Edgar/Edgar Idle 1.glb"
	}
	
	var debug_attacker = Character.instantiate()
	var debug_defender = Character.instantiate()
	
	debug_attacker.set_initial_stats(debug_attacker_stats)
	debug_defender.set_initial_stats(debug_defender_stats)
	
	GameStatus.set_characters(debug_attacker.get_stats(), debug_defender.get_stats())


func _on_debug_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/3D/combat.tscn")

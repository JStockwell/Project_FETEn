extends Node3D

var character = preload("res://Scenes/Character.tscn")

func _ready():
	var character_instance = character.instantiate()
	
	character_instance.set_initial_stats({
		"name": "missingno.",
		"max_health": 0,
		"attack": 0,
		"dexterity": 0,
		"defense": 0,
		"movement": 0,
		"ini_mana": 0,
		"max_mana": 0,
		"reg_mana": 0,
		"range": 0,
		"skills": [],
		"mesh_path": null
	})
	
	add_child(character_instance)

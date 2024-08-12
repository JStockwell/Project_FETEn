extends Control

var Character = preload("res://Scenes/Entities/character.tscn")

func _ready():
	combat_debug_test()

func combat_debug_test():
	var debug_attacker_stats = {
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
		"skills": ["shadow_ball", "nero_nero", "boost_1", "boost_2"],
		"is_ranged": true,
		"mesh_path": "res://Assets/Characters/Party/Edgar/Edgar Idle 1.glb"
	}
	
	var debug_defender_stats = {
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
		"is_ranged": false,
		"mesh_path": null
	}
	
	# Skill: skillName, range, cost, spa, sef, cta, imd
	var debug_skill_set = {
		"shadow_ball": {
			"skill_name": "Shadow Ball",
			"range": 5,
			"cost": 6,
			"spa": 7,
			"imd": 1
		},
		"nero_nero": {
			"skill_name": "Death Beam",
			"range": 5,
			"cost": 12,
			"spa": 11,
			"sef": true, # TODO Implement SEF
			"imd": 1
		},
		"boost_1": {
			"skill_name": "Boost Lv 2",
			"range": 1,
			"cost": 2,
			"spa": 4,
			"sef": true, # TODO Implement SEF
			"imd": 0
		},
		"boost_2": {
			"skill_name": "Boost Lv 2",
			"range": 1,
			"cost": 2,
			"spa": 4,
			"sef": true, # TODO Implement SEF
			"imd": 1
		}
	}
	
	var debug_attacker = Factory.Character.create(debug_attacker_stats)
	var debug_defender = Factory.Character.create(debug_defender_stats)
	
	GameStatus.set_characters(debug_attacker.get_stats(), debug_defender.get_stats())
	
	for skillName in debug_skill_set:
		GameStatus.skillSet[skillName] = Factory.Skill.create(debug_skill_set[skillName])
		
func _on_debug_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/3D/combat.tscn")

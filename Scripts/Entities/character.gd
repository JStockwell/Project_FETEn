extends RigidBody3D

@export
var stats = {
	"name": "missingno.",
	"max_health": 0,
	"attack": 0,
	"dexterity": 0,
	"defense": 0,
	"agility": 0,
	"movement": 0,
	"ini_mana": 0,
	"max_mana": 0,
	"reg_mana": 0,
	"range": 0,
	"skills": [],
	"is_ranged": false,
	"mesh_path": null
}

const variable_stats_keys = ["current_health", "current_mana"]

const INITIAL_STATS_NUM = 14

# General getters and Setters
func get_stats() -> Dictionary:
	return stats

func get_char_name() -> String:
	return stats["name"]

func get_max_health() -> int:
	return stats["max_health"]

func get_attack() -> int:
	return stats["attack"]
	
func get_dexterity() -> int:
	return stats["dexterity"]

func get_defense() -> int:
	return stats["defense"]

func get_agility() -> int:
	return stats["agility"]

func get_movement() -> int:
	return stats["movement"]

func get_ini_mana() -> int:
	return stats["ini_mana"]

func get_max_mana() -> int:
	return stats["max_mana"]

func get_reg_mana() -> int:
	return stats["reg_mana"]

func get_range() -> int:
	return stats["range"]

func get_skills() -> Array:
	return stats["skills"]

func is_ranged() -> bool:
	return stats["is_ranged"]

func get_mesh_path() -> String:
	return stats["mesh_path"]

func set_stats(stats_set: Dictionary) -> void:
	if validate_stats(stats_set):
		stats_set = cap_current_stats(stats_set)
		stats = stats_set
		
	else:
		print("Incorrect stats set")

func set_mesh(path) -> void:
	if path == null:
		path = "res://Assets/Characters/Placeholder/Placeholder_Char.glb"
			
	add_child(load(path).instantiate())
	
	
# Functions
func modify_health(hp_mod: int) -> void:
	stats["current_health"] += hp_mod
	cap_current_stats(stats)

# Validators
func validate_stats(stats_set) -> bool:
	var result = true
	
	for key in stats.keys():
		if key not in stats_set:
			result = false
	
	return result

func cap_current_stats(stats_set: Dictionary) -> Dictionary:
	if stats_set["current_health"] > stats_set["max_health"]:
		stats_set["current_health"] = stats_set["max_health"]
		
	if stats_set["current_mana"] > stats_set["max_mana"]:
		stats_set["current_mana"] = stats_set["max_mana"]
		
	if stats_set["current_health"] < 0:
		stats_set["current_health"] = 0
		
	if stats_set["current_mana"] < 0:
		stats_set["current_mana"] = 0
	
	return stats_set

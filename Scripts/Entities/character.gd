extends RigidBody3D

@onready
var mesh_instance = $MeshInstance3D

@export
var stats = {
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
	"skills": []
}

var variable_stats_keys = ["current_health", "current_mana"]

func _ready():
	add_child(set_mesh("res://Assets/Characters/Party/Edgar Idle 1.glb"))
	pass

func get_stats() -> Dictionary:
	return stats

func set_initial_stats(stats_set: Dictionary) -> void:
	if validate_stats(stats_set, false):
		stats = stats_set
		set_variable_stats()
		
	else:
		print("Incorrect stats set")
		
func validate_stats(stats_set: Dictionary, extended_stats: bool) -> bool:
	var result = true
	
	var complete_stats_key_list = stats_set.keys()
	
	if extended_stats:
		complete_stats_key_list.append(variable_stats_keys)
	
	for key in complete_stats_key_list:
		if key not in stats.keys():
			result = false
	
	return result and len(stats.keys()) == len(complete_stats_key_list)

func set_variable_stats() -> void:
	stats["current_health"] = stats["max_health"]
	stats["current_mana"] = stats["ini_mana"]

# Validate that current hp and mana cant be negative
func set_stats(stats_set: Dictionary) -> void:
	var test_bool = validate_stats(stats_set, true)
	if validate_stats(stats_set, true):
		stats_set = cap_current_stats(stats_set)
		stats = stats_set
		
	else:
		print("Incorrect stats set")
		
func cap_current_stats(stats_set: Dictionary) -> Dictionary:
	if stats_set["current_health"] > stats_set["max_health"]:
		stats_set["current_health"] = stats_set["max_health"]
		
	if stats_set["current_mana"] > stats_set["max_mana"]:
		stats_set["current_mana"] = stats_set["max_mana"]
		
	return stats_set

func set_mesh(path: String):
	return load(path)

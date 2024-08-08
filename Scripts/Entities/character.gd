extends RigidBody3D

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
	"skills": [],
	"mesh_path": null
}

var variable_stats_keys = ["current_health", "current_mana"]

# Getters and Setters
func get_stats() -> Dictionary:
	return stats

func set_initial_stats(stats_set: Dictionary) -> void:
	if validate_stats(stats_set):
		if stats_set["mesh_path"] == null:
			stats_set["mesh_path"] = "res://Assets/Characters/Placeholder/Placeholder_Char.glb"
			
		stats = stats_set
		set_variable_stats()
		set_mesh(stats["mesh_path"])
		
	else:
		print("Incorrect stats set")
		
func set_stats(stats_set: Dictionary) -> void:
	if validate_stats(stats_set):
		stats_set = cap_current_stats(stats_set)
		stats = stats_set
		
	else:
		print("Incorrect stats set")
		
func set_variable_stats() -> void:
	stats["current_health"] = stats["max_health"]
	stats["current_mana"] = stats["ini_mana"]
	
func set_mesh(path: String):
	add_child(load(path).instantiate())

# Validators
func validate_stats(stats_set) -> bool:
	var result = true
	
	for key in stats_set.keys():
		if key not in stats.keys():
			result = false
	
	return result and len(stats.keys()) == len(stats_set.keys())

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


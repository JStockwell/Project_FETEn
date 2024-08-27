extends RigidBody3D

@export
var stats = {
	"id": "msno.",
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
	"is_rooted": false,
	"mesh_path": null,
	"sprite_path": null
}

@onready
var selectedChar = $SelectedChar

@onready
var selectedEnemy = $SelectedEnemy

@onready
var selectedAlly = $SelectedAlly

# Getters
func get_stats() -> Dictionary:
	return stats
	
func get_id() -> String:
	return stats["id"]

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

func get_mesh_path() -> String:
	return stats["mesh_path"]
	
func is_rooted() -> bool:
	return stats["is_rooted"]
	
func set_is_rooted(val: bool) -> void:
	stats["is_rooted"] = val
	
func get_map_coords() -> Vector2:
	return stats["map_coords"]
	
func is_ranged() -> bool:
	return stats["is_ranged"]
	
func is_enemy() -> bool: 
	return stats["is_enemy"]
	
func get_current_health() -> int:
	return stats["current_health"]
	
func get_current_mana() -> int:
	return stats["current_mana"]
	
func set_map_id(val: int) -> void:
	stats["map_id"] = val
	
func get_map_id() -> int:
	return stats["map_id"]
	
func set_sprite(path: String) -> void:
	stats["sprite_path"] = path
	
func get_sprite() -> String:
	return stats["sprite_path"]

# Setters
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
	
func set_map_coords(coords: Vector2) -> void:
	if int(coords.x) in range(0, CombatMapStatus.get_map_x() + 1) and int(coords.y) in range(0, CombatMapStatus.get_map_y() + 1):
		stats["map_coords"] = coords
		
	else:
		print("invalid coords " + str(coords))
		
func set_is_enemy(flag: bool) -> void:
	stats["is_enemy"] = flag
	
# Functions
func modify_health(hp_mod: int) -> void:
	stats["current_health"] += hp_mod
	cap_current_stats(stats)

func modify_mana(mana_mod: int) -> void:
	stats["current_mana"] += mana_mod
	cap_current_stats(stats)
	
# Roll is a D20
func calculate_initiative(roll: int) -> float:
	return roll + ((stats["agility"] + stats["dexterity"]) / 2) * 1.1

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

signal character_selected(character)

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			character_selected.emit(self)

signal on_entry(character)
signal on_exit(character)

func _on_mouse_entered():
	on_entry.emit(self)

func _on_mouse_exited():
	on_exit.emit(self)

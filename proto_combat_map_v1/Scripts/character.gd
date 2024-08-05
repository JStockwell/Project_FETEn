extends RigidBody3D

var characterName
@export
var maxHealth = 30
var currentHealth
@export
var attack = 16
@export
var defense = 6
var mapPosition
var mapMode
var isPlayer
@export
var movement = 2

func set_is_player(val: bool) -> void:
	isPlayer = val
	
func get_is_player() -> bool:
	return isPlayer

func set_map_mode(val: bool) -> void:
	mapMode = val
	
func get_map_mode() -> bool:
	return mapMode

func get_map_position() -> Vector2:
	return mapPosition
	
func set_map_position(coords: Vector2) -> void:
	mapPosition = coords

func set_health(value):
	currentHealth = value

func get_health():
	return currentHealth

func get_attack():
	return attack

func get_defense():
	return defense
	
func set_stats(statsSet):
	characterName = statsSet["name"]
	maxHealth = statsSet["max_health"]
	currentHealth = statsSet["current_health"]
	attack = statsSet["attack"]
	defense = statsSet["defense"]
	movement = statsSet["movement"]
	mapPosition = null

func get_stats():
	return {
		"name": characterName,
		"max_health": maxHealth,
		"current_health": currentHealth,
		"attack": attack,
		"defense": defense,
		"movement": movement,
		"map_position": mapPosition
	}

func _ready():
	mass = 60

func death(damage):
	apply_impulse(Vector3(randf_range(-0.25,0.25),1,randf_range(-1,-2.5)) * 400 * (1 + 0.1 * (min(8,damage+1))), Vector3(0,0,0))

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		if mapMode:
			if isPlayer:
				var selectedName = "null"
				
				if MapStatus_map_v1.get_selected_player() != characterName:
					selectedName = characterName
				
				MapStatus_map_v1.set_selected_player(selectedName)
				
			if not isPlayer:
				var selectedName = "null"
				
				if MapStatus_map_v1.get_selected_enemy() != characterName:
					selectedName = characterName
				
				MapStatus_map_v1.set_selected_enemy(selectedName)

extends StaticBody3D

@onready
var highlighted = $Highlighted

@onready
var selected = $Selected

@onready
var enemy = $Enemy

var coords: Vector2
var height: int
var isDifficultTerrain: bool

var isPopulated: bool
var isTraversable: bool
var isObstacle: bool
var isControlZone: bool = false

var meshPath: String = ""

# Getters and setters
func get_variables() -> Dictionary:
	return {
		"coords": coords,
		"height": height,
		"idt": isDifficultTerrain,
		"isPopulated": isPopulated,
		"isTraversable": isTraversable,
		"isObstacle": isObstacle,
		"meshPath": meshPath
	}

func get_coords() -> Vector2:
	return coords

func is_populated() -> bool:
	return isPopulated

func is_traversable() -> bool:
	return isTraversable
	
func is_obstacle() -> bool:
	return isObstacle

func get_height() -> int:
	return height

func is_difficult_terrain() -> int:
	return isDifficultTerrain
	
func set_is_populated(value: bool) -> void:
	isPopulated = value
	
func set_is_control_zone(value: bool) -> void:
	isControlZone = value
	
func is_control_zone() -> bool:
	return isControlZone

signal tile_selected(mapTile)

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			tile_selected.emit(self)

func _on_hit_detection_area_entered(area):
	CombatMapStatus.set_hit_blocked(true)

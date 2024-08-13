extends StaticBody3D

@onready
var highlighted = $Highlighted

@onready
var selected = $Selected

var coords: Vector2
var height: int
var difficulty: int

var isPopulated: bool
var isTraversable: bool
var isObstacle: bool

var meshPath: String

# Getters and setters
func get_coords() -> Vector2:
	return coords

func is_populated() -> bool:
	return isPopulated

func get_is_traversable() -> bool:
	return isTraversable
	
func get_is_obstacle() -> bool:
	return isObstacle

func get_height() -> int:
	return height

func get_difficulty() -> int:
	return difficulty
	
func set_is_populated(value: bool) -> void:
	isPopulated = value

signal tile_selected(mapTile)

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			tile_selected.emit(self)

extends StaticBody3D

@onready
var highlighted = $Highlighted

@onready
var selected = $Selected

@onready
var enemy = $Enemy

@onready
var odz = $ObstacleDetectionZone/CollisionShape3D

var coords: Vector2
var height: int
var isDifficultTerrain: bool

var isPopulated: bool
var isTraversable: bool
var obstacleType: int # 0 None, 1 Semi, 2 Full
var isControlZone: bool = false
var isAllyControlZone: bool = false

var meshPath: String = ""

# Getters and setters
func get_variables() -> Dictionary:
	return {
		"coords": coords,
		"height": height,
		"idt": isDifficultTerrain,
		"isPopulated": isPopulated,
		"isTraversable": isTraversable,
		"obstacleType": obstacleType,
		"meshPath": meshPath
	}

func get_coords() -> Vector2:
	return coords

func is_populated() -> bool:
	return isPopulated

func is_traversable() -> bool:
	return isTraversable
	
func get_obstacle_type() -> int:
	return obstacleType

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

func set_is_ally_control_zone(value: bool) -> void:
	isAllyControlZone = value

func is_ally_control_zone() -> bool:
	return isControlZone

func init_odz() -> void:
	var shape = BoxShape3D.new()
	shape.size = Vector3(1, 1, 1)
	odz.shape = shape

func set_odz(value: bool) -> void:
	odz.disabled = value

signal tile_selected(mapTile)

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			tile_selected.emit(self)

func _on_hit_detection_area_entered(area):
	CombatMapStatus.set_hit_blocked(true)

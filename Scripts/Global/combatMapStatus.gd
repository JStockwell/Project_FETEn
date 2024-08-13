extends Node

@export
var mapX = 11
@export
var mapY = 11

# Getters and Setters
func get_map_x() -> int:
	return mapX
	
func get_map_y() -> int:
	return mapY

func get_map_dimensions() -> Vector2:
	return Vector2(mapX, mapY)

func set_map_size(x: int, y: int) -> void:
	mapX = x
	mapY = y

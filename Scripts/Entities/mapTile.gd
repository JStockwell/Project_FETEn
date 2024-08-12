extends Node3D

var coords: Vector2
var height: int
var difficulty: int

var isPopulated: bool
var isTraversable: bool
var isObstacle: bool

var meshPath: String

@onready
var placeholder = $Tile/Reference

# Getters and setters
func get_is_populated() -> bool:
	return isPopulated

func get_is_traversable() -> bool:
	return isTraversable
	
func get_is_obstacle() -> bool:
	return isObstacle

func get_height() -> int:
	return height

func get_difficulty() -> int:
	return difficulty

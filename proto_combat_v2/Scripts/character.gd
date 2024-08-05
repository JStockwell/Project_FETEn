extends RigidBody3D

@export
var max_health = 30
var current_health
@export
var attack = 16
@export
var defense = 6

func set_health(value):
	current_health = value

func get_health():
	return current_health

func get_attack():
	return attack

func get_defense():
	return defense

func _ready():
	current_health = max_health
	mass = 60

func death(damage):
	apply_impulse(Vector3(randf_range(-0.25,0.25),1,randf_range(-1,-2.5)) * 400 * (1 + 0.1 * (min(8,damage+1))), Vector3(0,0,0))

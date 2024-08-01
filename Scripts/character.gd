extends RigidBody3D

var characterName
@export
var maxHealth = 30
var currentHealth
@export
var attack = 16
@export
var defense = 6

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

func _ready():
	mass = 60

func death(damage):
	apply_impulse(Vector3(randf_range(-0.25,0.25),1,randf_range(-1,-2.5)) * 400 * (1 + 0.1 * (min(8,damage+1))), Vector3(0,0,0))

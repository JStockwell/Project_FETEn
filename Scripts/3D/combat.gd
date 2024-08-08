extends Node3D

@onready
var attacker = $Characters/Attacker

@onready
var defender = $Characters/Defender

@onready
var debugUI = $UI/Debug

var Character = preload("res://Scenes/Entities/character.tscn")

func _ready():
	if not GameStatus.debugMode:
		debugUI.hide()
		
	init_characters()

# Initialize characters
func init_characters():
	attacker.set_void_initial_stats()
	attacker.set_stats(GameStatus.get_attacker_stats())
	attacker.set_mesh(GameStatus.get_attacker_stats()["mesh_path"])
	
	defender.set_void_initial_stats()
	defender.set_stats(GameStatus.get_defender_stats())
	defender.set_mesh(GameStatus.get_defender_stats()["mesh_path"])

# Debug attacks
func _on_debug_melee_attack_pressed():
	pass # Replace with function body.

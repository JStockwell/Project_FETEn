extends Node3D

@onready
var particles = $GPUParticles3D

func _on_button_pressed():
	particles.restart()

extends Node3D

signal particleEnd(particle)

@onready
var healParticles = $HealParticles
@onready
var buffParticles = $BuffParticles
@onready
var label = $Label3D

func start(buffFlag: bool, text: String):
	label.text = text
	label.show()
	
	if buffFlag:
		buffParticles.restart()
		
	else:
		healParticles.restart()

func _on_particles_finished():
	label.hide()
	particleEnd.emit(self)

extends Node3D

@onready
var healParticles = $HealParticles
@onready
var buffParticles = $BuffParticles
@onready
var button = $Button
@onready
var label = $Label3D

func _on_button_pressed():
	
	button.disabled = true
	var mat = StandardMaterial3D
	
	if randi_range(0,2) == 0:
		healParticles.restart()
		label.text = "+" + str(randi_range(1,20))
		
	else:
		buffParticles.restart()
		label.text = "Blade Song"
		
	label.show()

func _on_particles_finished():
	button.disabled = false
	label.hide()

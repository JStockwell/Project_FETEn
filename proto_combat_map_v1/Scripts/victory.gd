extends Node3D

signal quitGame

@onready
var dick = $Characters/Dick

@onready
var samael = $Characters/Samael

@onready
var azrael = $Characters/Azrael

func _process(delta):
	dick.rotate(Vector3(0,1,0), 0.1)
	samael.rotate(Vector3(0,1,0), 0.1)
	azrael.rotate(Vector3(0,1,0), 0.1)

func _input(event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		emit_signal("quitGame")

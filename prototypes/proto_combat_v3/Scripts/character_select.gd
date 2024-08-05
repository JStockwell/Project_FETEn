extends Node3D

@onready
var dickLabel = $Characters/Dick/DickTitle

@onready
var samaelLabel = $Characters/Samael/SamaelTitle

@onready
var azraelLabel = $Characters/Azrael/AzraelTitle

@onready
var dickLight = $Characters/Dick/DickLight

@onready
var samaelLight = $Characters/Samael/SamaelLight

@onready
var azraelLight = $Characters/Azrael/AzraelLight

@onready
var ambientLight = $Lights/DirectionalLight3D

var inDick = false
var inSamael = false
var inAzrael = false

var dickLabelVel = 0
var samaelLabelVel = 0
var azraelLabelVel = 0

func _process(delta):
	dickLabel.rotate(Vector3(0,1,0), dickLabelVel)
	samaelLabel.rotate(Vector3(0,1,0), samaelLabelVel)
	azraelLabel.rotate(Vector3(0,1,0), azraelLabelVel)


func _input(event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not inDick and not inSamael and not inAzrael:
			return
		
		if inDick:
			GameStatus_v3.activePlayer = GameStatus_v3.playerList["Dick"]
			
		elif inSamael:
			GameStatus_v3.activePlayer = GameStatus_v3.playerList["Samael"]
			
		elif inAzrael:
			GameStatus_v3.activePlayer = GameStatus_v3.playerList["Azrael"]
			
		get_tree().change_scene_to_file("res://prototypes/proto_combat_v3/Scenes/combat_proto.tscn")


func _on_dick_mouse_entered():
	inDick = true
	dickLight.show()
	ambientLight.hide()
	dickLabelVel = 0.05

func _on_dick_mouse_exited():
	inDick = false
	dickLight.hide()
	ambientLight.show()
	dickLabelVel = 0
	dickLabel.set_rotation_degrees(Vector3(0,90,0))


func _on_samael_mouse_entered():
	inSamael = true
	samaelLight.show()
	ambientLight.hide()
	samaelLabelVel = 0.05


func _on_samael_mouse_exited():
	inSamael = false
	samaelLight.hide()
	ambientLight.show()
	samaelLabelVel = 0
	samaelLabel.set_rotation_degrees(Vector3(0,90,0))


func _on_azrael_mouse_entered():
	inAzrael = true
	azraelLight.show()
	ambientLight.hide()
	azraelLabelVel = 0.05


func _on_azrael_mouse_exited():
	inAzrael = false
	azraelLight.hide()
	ambientLight.show()
	azraelLabelVel = 0
	azraelLabel.set_rotation_degrees(Vector3(0,90,0))

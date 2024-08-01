extends Node3D

@onready
var dickLabel = $UI/DickTitle

@onready
var samaelLabel = $UI/SamaelTitle

@onready
var dickLight = $Lights/DickLight

@onready
var samaelLight = $Lights/SamaelLight

@onready
var ambientLight = $Lights/DirectionalLight3D

var inDick = false
var inSamael = false

func _process(delta):
	dickLabel.rotate(Vector3(0,1,0), 0.01)
	samaelLabel.rotate(Vector3(0,1,0), 0.01)


func _input(event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not inDick and not inSamael:
			return
		
		if inDick:
			GameStatus.activePlayer = GameStatus.playerList["Dick"]
			
		elif inSamael:
			GameStatus.activePlayer = GameStatus.playerList["Samael"]
			
		get_tree().change_scene_to_file("res://Scenes/combat_proto.tscn")


func _on_dick_mouse_entered():
	inDick = true
	dickLight.show()
	ambientLight.hide()

func _on_dick_mouse_exited():
	inDick = false
	dickLight.hide()
	ambientLight.show()


func _on_samael_mouse_entered():
	inSamael = true
	samaelLight.show()
	ambientLight.hide()


func _on_samael_mouse_exited():
	inSamael = false
	samaelLight.hide()
	ambientLight.show()

extends Node3D

signal start_campaign

@onready
var cameraPivot = $SelectPivot
@onready
var camera = $SelectPivot/Camera3D

@onready
var ui = $UI

@onready
var leftButton = $UI/LeftButton
@onready
var rightButton = $UI/RightButton
@onready
var selCharButton = $UI/SelCharButton
@onready
var remCharButton = $UI/RemCharButton
@onready
var startButton = $UI/StartButton

@onready
var char1 = $UI/Party/InitativeIcons/Ini1/TextureRect
@onready
var char2 = $UI/Party/InitativeIcons/Ini2/TextureRect
@onready
var char3 = $UI/Party/InitativeIcons/Ini3/TextureRect
@onready
var char4 = $UI/Party/InitativeIcons/Ini4/TextureRect

const CHARACTERS = ["salvador", "samael", "lystra", "dick", "edgar", "adran"]
var pointer: int = 3

var tempParty: Array = []

func setup() -> void:
	cameraPivot.rotation_degrees.y = 15
	pointer = 3
	tempParty = []
	ui.show()
	modify_status()

func modify_status() -> void:
	validate_pointer()
	move_camera()
	modify_buttons()
	modify_party_ui()
	
func validate_pointer() -> void:
	if pointer == 0:
		leftButton.disabled = true
	else:
		leftButton.disabled = false
		
	if pointer >= CHARACTERS.size() - 1:
		rightButton.disabled = true
	else:
		rightButton.disabled = false

func move_camera() -> void:
	cameraPivot.rotation_degrees.y = 75 - 30 * pointer

func modify_buttons() -> void:
	selCharButton.disabled = true
	if CHARACTERS[pointer] in tempParty:
		selCharButton.hide()
		remCharButton.show()
		
	else:
		if CHARACTERS[pointer] == "adran" or tempParty.size() >= 4:
			selCharButton.disabled = true
		else:
			selCharButton.disabled = false
		
		selCharButton.show()
		remCharButton.hide()
		
	if tempParty.size() >= 4:
		startButton.disabled = false
	else:
		startButton.disabled = true


func modify_party_ui() -> void:
	char1.texture = null
	char2.texture = null
	char3.texture = null
	char4.texture = null
	
	var i = 0
	for member in tempParty:
		var tempTex = load(GameStatus.get_playable_characters()[member]["sprite_path"])
		match i:
			0:
				char1.texture = tempTex
			1:
				char2.texture = tempTex
			2:
				char3.texture = tempTex
			3:
				char4.texture = tempTex
				
		i += 1

func _on_left_button_pressed() -> void:
	MusicPlayer.play_fx(MusicPlayer.SOUNDS.UI__CLICK)
	pointer -= 1
	modify_status()

func _on_right_button_pressed() -> void:
	MusicPlayer.play_fx(MusicPlayer.SOUNDS.UI__CLICK)
	pointer += 1
	modify_status()

func _on_sel_char_button_pressed() -> void:
	if tempParty.size() < 4 and CHARACTERS[pointer] not in tempParty:
		tempParty.append(CHARACTERS[pointer])
		
	elif CHARACTERS[pointer] in tempParty:
		tempParty.remove_at(tempParty.find(CHARACTERS[pointer]))
		
	MusicPlayer.play_fx(MusicPlayer.SOUNDS.UI__CLICK)
	modify_status()


func _on_start_button_pressed() -> void:
	ui.hide()
	var result = []
	for character in tempParty:
		result.append(character)
		
	GameStatus.set_party(result)
	MusicPlayer.play_fx(MusicPlayer.SOUNDS.UI__CLICK)
	start_campaign.emit()

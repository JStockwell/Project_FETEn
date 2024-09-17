extends Control

var charArray: Array
var pointer: int

@onready
var leftButton = $LeftButton
@onready
var rightButton = $RightButton

@onready
var ini1BG = $InitativeIcons/Ini1/CharIniBg
@onready
var ini1Tex = $InitativeIcons/Ini1/TextureRect
@onready
var ini2BG = $InitativeIcons/Ini2/CharIniBg
@onready
var ini2Tex = $InitativeIcons/Ini2/TextureRect
@onready
var ini3BG = $InitativeIcons/Ini3/CharIniBg
@onready
var ini3Tex = $InitativeIcons/Ini3/TextureRect
@onready
var ini4BG = $InitativeIcons/Ini4/CharIniBg
@onready
var ini4Tex = $InitativeIcons/Ini4/TextureRect

func set_initiative(combarCharArray: Array) -> void:
	charArray = combarCharArray
	pointer = 0

func modify_initiative():
	var charBG
	var charTex
	var currentCharacter
	
	if pointer > charArray.size() - 4:
		pointer = max(charArray.size() - 4, 0)
	
	for i in range(0,4):
		if i + pointer < charArray.size():
			match i:
				0:
					charBG = ini1BG
					charTex = ini1Tex
				1:
					charBG = ini2BG
					charTex = ini2Tex
				2:
					charBG = ini3BG
					charTex = ini3Tex
				3:
					charBG = ini4BG
					charTex = ini4Tex
				_:
					push_error("INITIATIVE POINTER OUT OF BOUNDS")
			
			currentCharacter = charArray[pointer + i]
			
			if currentCharacter.get_map_id() == CombatMapStatus.get_current_turn_char():
				charBG.texture = load("res://Assets/UI/gold_ini_bg.png")
				
			else:
				if currentCharacter.is_enemy():
					charBG.texture = load("res://Assets/UI/enem_ini_bg.png")
				else:
					charBG.texture = load("res://Assets/UI/char_ini_bg.png")
					
			if currentCharacter.get_sprite() == "":
				charTex.texture = load("res://Assets/Characters/Placeholder/sprite_placeholder.png")
			else:
				charTex.texture = load(currentCharacter.get_sprite())
			
	update_buttons()

func character_death(character) -> void:
	for arrayChar in charArray:
		if arrayChar.get_map_id() == character.get_map_id():
			charArray.remove_at(charArray.find(arrayChar))
			
	pointer = CombatMapStatus.get_current_ini()
	modify_initiative()

func _on_left_button_pressed():
	MusicPlayer.play_fx(MusicPlayer.SOUNDS.UI__CLICK)
	pointer -= 1
	modify_initiative()
	update_buttons()

func _on_right_button_pressed():
	MusicPlayer.play_fx(MusicPlayer.SOUNDS.UI__CLICK)
	pointer += 1
	modify_initiative()
	update_buttons()

func update_buttons():
	if pointer + 4 >= charArray.size():
		rightButton.disabled = true
		
	else:
		rightButton.disabled = false
		
	if pointer == 0:
		leftButton.disabled = true
		
	else:
		leftButton.disabled = false
		
	if charArray.size() <= 4:
		leftButton.disabled = true
		rightButton.disabled = true

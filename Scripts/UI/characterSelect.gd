extends Node

var tempParty = []

@onready
var charCard = $CharacterCard
@onready
var debugText = $UI/DebugText
@onready
var startButton = $UI/StartButton
@onready
var mapChoice = $UI/MapChoice

func _ready():
	setup_status()
		
	var i = 0
	var j = 0
	for partyMember in GameStatus.get_playable_characters():
		if not GameStatus.get_playable_characters()[partyMember]["id"] == "adran":
			var tempChar = Factory.Character.create(GameStatus.get_playable_characters()[partyMember], true)
			add_child(tempChar)
			
			tempChar.connect("on_entry", Callable(self, "_on_character_entry"))
			tempChar.connect("on_exit", Callable(self, "_on_character_exit"))
			tempChar.connect("character_selected", Callable(self, "_on_character_select"))
		
			tempChar.position = Vector3(-3.35 + (2.1) * i, 2.2 * j, 0)
			tempChar.set_gravity_scale(0)
			
			if i == 3:
				i = -1
				j = 1
			
			i += 1
			
		else:
			print("Adran sucks")

func _process(delta):
	if GameStatus.debugMode:
		debugText.text = str(tempParty)
		
	#if tempParty.size() < 4 or mapChoice.get_selected_id() == -1:
	if tempParty.size() < 4:
		startButton.disabled = true
		
	else:
		startButton.disabled = false

func setup_status() -> void:
	var playableCharacters = Utils.read_json("res://Assets/json/players.json")
	GameStatus.set_playable_characters(playableCharacters)
	
	var skillSet = Utils.read_json("res://Assets/json/skills.json")
	var i = 0
	for skillName in skillSet:
		GameStatus.skillSet[skillName] = Factory.Skill.create(skillSet[skillName])
		GameStatus.skillSet[skillName].set_skill_menu_id(i)
		i += 1

func _on_character_select(character) -> void:
	MusicPlayer.play_fx(MusicPlayer.SOUNDS.UI__CLICK)
	if character not in tempParty and tempParty.size() < 4:
		character.selectedAlly.show()
		tempParty.append(character)
		
	else:
		character.selectedAlly.hide()
		tempParty.remove_at(tempParty.find(character))

func _on_character_entry(character) -> void:
	charCard.set_character(character)
	charCard.show()

func _on_character_exit(character) -> void:
	charCard.hide()

func _on_start_button_pressed() -> void:
	MusicPlayer.play_fx(MusicPlayer.SOUNDS.UI__CLICK)
	var result = []
	for character in tempParty:
		result.append(character.get_id())
		
	GameStatus.set_party(result)
	get_tree().change_scene_to_file("res://Scenes/3D/newTavern.tscn")

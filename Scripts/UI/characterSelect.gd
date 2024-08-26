extends Node

var tempParty = []

@onready
var charCard = $CharacterCard

func _ready():
	if GameStatus.debugMode:
		setup_status()
		
	var i = 0
	var j = 0
	for partyMember in GameStatus.get_playable_characters():
		var tempChar = Factory.Character.create(GameStatus.get_playable_characters()[partyMember], true)
		add_child(tempChar)
		
		tempChar.connect("on_entry", Callable(self, "_on_character_entry"))
		tempChar.connect("on_exit", Callable(self, "_on_character_exit"))
		tempChar.connect("character_selected", Callable(self, "_on_character_select"))
	
		tempChar.position = Vector3(-3.35 + (2.1) * i, 2.2 * j, 0)
		if i == 3:
			i = -1
			j = 1
		
		i += 1

func setup_status() -> void:
	var playableCharacters = Utils.read_json("res://Assets/json/players.json")
	GameStatus.set_playable_characters(playableCharacters)
	
	var skillSet = Utils.read_json("res://Assets/json/skills.json")
	GameStatus.set_skill_set(skillSet)

func _on_character_select(character) -> void:
	if not character.selectedAlly.visible and character not in tempParty:
		if tempParty.size() >= 4:
			character.selectedAlly.show()
			tempParty.append(character)
		
	else:
		character.selectedAlly.hide()

func _on_character_entry(character) -> void:
	charCard.set_character(character)
	charCard.show()

func _on_character_exit(character) -> void:
	charCard.hide()

extends Node

var tempParty = []

const MAPS = [
	"res://Assets/json/maps/combatMap_lv1_1.json",
	"res://Assets/json/maps/combatMap_lv1_2.json",
	"res://Assets/json/maps/combatMap_lv2_1.json",
	"res://Assets/json/maps/combatMap_lv2_2.json",
	"res://Assets/json/maps/combatMap_lv2_3.json",
	"res://Assets/json/maps/combatMap_lv2_4.json",
	"res://Assets/json/maps/combatMap_lv3_1.json",
	"res://Assets/json/maps/combatMap_lv3_2.json",
	"res://Assets/json/maps/combatMap_lv3_3.json",
	"res://Assets/json/maps/combatMap_lv4_1.json"
]

@onready
var charCard = $CharacterCard
@onready
var debugText = $UI/DebugText
@onready
var startButton = $UI/StartButton
@onready
var mapChoice = $UI/MapChoice

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
		tempChar.set_gravity_scale(0)
		
		if i == 3:
			i = -1
			j = 1
		
		i += 1

func _process(delta):
	if GameStatus.debugMode:
		debugText.text = str(tempParty)
		
	if tempParty.size() < 4 or mapChoice.get_selected_id() == -1:
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
	var result = []
	for character in tempParty:
		result.append(character.get_id())
		
	GameStatus.set_party(result)
	CombatMapStatus.set_map_path(MAPS[mapChoice.get_selected_id()])
	get_tree().change_scene_to_file("res://Scenes/3D/tavern.tscn")

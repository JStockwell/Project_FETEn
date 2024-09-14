extends Node

var save: Dictionary
var settings: Dictionary

enum GameState {CAMPAIGN = 0, MAP = 1, COMBAT = 2}
var currentGameState = GameState.CAMPAIGN

var mapScale: float = 0.05
var stageCount: int = 4
var playableCharacters: Dictionary
var enemySet: Dictionary
var skillSet: Dictionary

var party: Dictionary

var autorunCombat: bool = true
var debugMode: bool = true
var testMode: bool = false

func get_playable_characters() -> Dictionary:
	return playableCharacters

func set_playable_characters(characterDict: Dictionary) -> void:
	playableCharacters = characterDict

func get_skill_set() -> Dictionary:
	return skillSet

func set_skill_set(skillDict: Dictionary) -> void:
	skillSet = skillDict 

func set_party(playerList: Array) -> void:
	for member in playerList:
		party[member] = playableCharacters[member]

func set_enemy_set(enemyDict: Dictionary) -> void:
	enemySet = enemyDict
	
func get_enemy_from_enemy_set(enemy: String) -> Dictionary:
	return enemySet[enemy]	

func get_party() -> Dictionary:
	return party
	
func get_party_member(charName: String):
	if charName in party.keys():
		return party[charName]
		
	else:
		print("character {n} not in party".format({"n": charName}))

func get_current_game_state() -> int:
	return currentGameState
	
func set_current_game_state(state: int) -> void:
	currentGameState = state

func set_autorun_combat(value: bool) -> void:
	autorunCombat = value
	
func get_stage_count() -> int:
	return stageCount
	
func get_settings() -> Dictionary:
	return settings
	
func load_settings() -> void:
	if not FileAccess.file_exists("user://settings.json"):
		save_settings(Utils.read_json("res://Assets/json/settings_reference.json"))
		return
		
	var file = FileAccess.open("user://settings.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	
	settings = data
	file.close()
	
func save_settings(tempSettings: Dictionary) -> void:
	var file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	
	file.store_line(JSON.stringify(tempSettings, "\t"))
	file.close()
	
	settings = tempSettings
	
func get_save() -> Dictionary:
	return save.duplicate()
	
func load_save() -> void:
	if not FileAccess.file_exists("user://save.json"):
		save_game(Utils.read_json("res://Assets/json/save_reference.json"))
		return
		
	var file = FileAccess.open("user://save.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	
	save = data
	file.close()

func save_game(tempSave: Dictionary) -> void:
	var file = FileAccess.open("user://save.json", FileAccess.WRITE)
	
	file.store_line(JSON.stringify(tempSave, "\t"))
	file.close()
	
	save = tempSave

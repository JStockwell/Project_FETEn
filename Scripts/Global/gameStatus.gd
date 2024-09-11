extends Node

var save: Dictionary

enum GameState {CAMPAIGN = 0, MAP = 1, COMBAT = 2}
var currentGameState = GameState.CAMPAIGN

var playableCharacters: Dictionary
var enemySet: Dictionary
var skillSet: Dictionary

var party: Dictionary

var autorunCombat: bool = true
var debugMode: bool = false
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
	
func load_save() -> void:
	save = Utils.read_json("res://Assets/json/saves/save.json")

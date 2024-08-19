extends Node

# Comes from the table in the tavern.tscn scene
var tavernTableHeight = 14.5

var playableCharacters: Dictionary
var enemySet: Dictionary
var skillSet: Dictionary

var party: Dictionary

var autorunCombat: bool = true
var debugMode = true

func set_playable_characters(characterDict: Dictionary) -> void:
	playableCharacters = characterDict

func set_party(playerList: Array) -> void:
	for member in playerList:
		party[member] = playableCharacters[member]

func set_enemy_set(enemyDict: Dictionary) -> void:
	enemySet = enemyDict

func get_party() -> Dictionary:
	return party
	
func get_party_member(charName: String):
	if charName in party.keys():
		return party[charName]
		
	else:
		print("character {n} not in party".format({"n": charName}))

func set_autorun_combat(value: bool) -> void:
	autorunCombat = value

func get_table_height() -> float:
	return tavernTableHeight

extends Node

var attackerStats: Dictionary
var defenderStats: Dictionary

var skillSet: Dictionary
var playableCharacters: Dictionary
var party: Dictionary

var highlightedNode

var debugMode = true

func set_active_characters(attack, defend) -> void:
	attackerStats = attack
	defenderStats = defend
	
func set_playable_characters(characterDict: Dictionary) -> void:
	playableCharacters = characterDict
	
func set_party(playerList: Array) -> void:
	for member in playerList:
		party[member] = Factory.Character.create(playableCharacters[member])
	
func get_attacker_stats() -> Dictionary:
	return attackerStats
	
func get_defender_stats() -> Dictionary:
	return defenderStats

func get_party() -> Dictionary:
	return party

func get_party_member(charName: String):
	if charName in party.keys():
		return party[charName]
		
	else:
		print("character {n} not in party".format({"n": charName}))
		
func set_highlighted_node(node):
	highlightedNode = node
	
func get_highlighted_node():
	return highlightedNode

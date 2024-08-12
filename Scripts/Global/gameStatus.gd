extends Node

var attackerStats
var defenderStats
var skillSet = {}

var debugMode = true

func set_characters(attack, defend) -> void:
	attackerStats = attack
	defenderStats = defend
	
func get_attacker_stats() -> Dictionary:
	return attackerStats
	
func get_defender_stats() -> Dictionary:
	return defenderStats

class_name skill extends Node

var skillName: String
# Range = 0 for self skill
var range: int
var cost: int
var spa: int = 0
# TODO Find way to execute functions from string that isnt a match using the ID name
var specialEffectFunc: bool = false
var canTargetAllies: bool = false
var isMagicDamage: int = 0
var isMelee: bool

func get_skill() -> Dictionary:
	return {
		"skill_name": skillName,
		"range": range,
		"cost": cost,
		"spa": spa,
		"sef": specialEffectFunc,
		"cta": canTargetAllies,
		"imd": isMagicDamage,
		"isMelee": isMelee
	}        

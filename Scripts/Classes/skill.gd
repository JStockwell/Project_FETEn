class_name skill extends Node

var skillName: String
var description: String
# Range = 0 for self skill
var range: int
var cost: int
var spa: int = 0
var specialEffectFunc: bool = false
var canTargetAllies: bool = false
var isMagicDamage: int = 0
var isInstantaneous: bool = false
var isBuff: bool = false
var skillMenuID: int
var skill_sfx_path: String

func get_skill() -> Dictionary:
	return {
		"skill_name": skillName,
		"description": description,
		"range": range,
		"cost": cost,
		"spa": spa,
		"sef": specialEffectFunc,
		"cta": canTargetAllies,
		"imd": isMagicDamage,
		"inst": isInstantaneous,
		"buff": isBuff,
		"skill_sfx_path": skill_sfx_path
	}        

func get_skill_name() -> String:
	return skillName

func get_description() -> String:
	return description

func get_skill_menu_id() -> int:
	return skillMenuID
	
func get_range() -> int:
	return range
	
func get_cost() -> int:
	return cost
	
func get_spa() -> int:
	return spa

func can_target_allies() -> bool:
	return canTargetAllies

func is_instantaneous() -> bool:
	return isInstantaneous

func is_buff() -> bool:
	return isBuff

func set_skill_menu_id(id: int) -> void:
	skillMenuID = id

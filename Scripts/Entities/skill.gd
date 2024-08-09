class_name skill extends Node

var skillName: String
# Range = 0 for self skill
var range: int
var cost: int
var spa: int = 0
# Find way to execute functions from string that isnt a match
var specialEffectFunc: String = null
var canTargetAllies: bool = false

func init_skill(args: Dictionary) -> void:
	var validator = true
	for variable in ["skill_name", "range", "cost"]:
		if variable not in args.keys():
			validator = false

	if validator:
		skillName = args["skill_name"]
		range = args["range"]
		cost = args["cost"]
	  
		if "spa" in args.keys():
			spa = args["spa"]
	  
		if "sef" in args.keys():
			specialEffectFunc = args["sef"]
		 
		if "cta" in args.keys():
			canTargetAllies = args["cta"] 
		 
func get_skill() -> Dictionary:
	return {
		"skill_name": skillName,
		"range": range,
		"cost": cost,
		"spa": spa,
		"sef": specialEffectFunc,
		"cta": canTargetAllies
	}        

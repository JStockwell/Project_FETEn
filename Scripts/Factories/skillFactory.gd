class_name SkillFactory

const Skill = preload("res://Scripts/Classes/skill.gd")

static func create(args: Dictionary):
	var validator = true
	for variable in ["skill_name", "description", "range", "cost"]:
		if variable not in args.keys():
			validator = false

	if validator:
		var mySkill = Skill.new()
		mySkill.skillName = args["skill_name"]
		mySkill.description = args["description"]
		mySkill.range = args["range"]
		mySkill.cost = args["cost"]
	  
		if "spa" in args.keys():
			mySkill.spa = args["spa"]
	  
		if "sef" in args.keys():
			mySkill.specialEffectFunc = args["sef"]
		 
		if "cta" in args.keys():
			mySkill.canTargetAllies = args["cta"]
			
		if "imd" in args.keys():
			mySkill.isMagicDamage = args["imd"]
		
		if "inst" in args.keys():
			mySkill.isInstantaneous = args["inst"]
		
		return mySkill
			
	else:
		push_error("invalid skill set")

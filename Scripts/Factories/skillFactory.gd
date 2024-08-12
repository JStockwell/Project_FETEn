class_name SkillFactory

const Skill = preload("res://Scripts/Entities/skill.gd")

static func create(args: Dictionary):
	var mySkill = Skill.new()
	
	var validator = true
	for variable in ["skill_name", "range", "cost"]:
		if variable not in args.keys():
			validator = false

	if validator:
		mySkill.skillName = args["skill_name"]
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
			
	else:
		print("invalid skill set")
	
	return mySkill

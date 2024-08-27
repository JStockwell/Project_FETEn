extends Node

@onready
var statsLabel = $Stats
@onready
var importantStatsLabel = $ImportantStats
@onready
var characterPic = $CharacterPicture

func set_character(character) -> void:
	if character.get_sprite() != "":
		characterPic.texture = load(character.get_sprite())
		
	else:
		characterPic.texture = null
		
	set_stats(character)
	set_important_stats(character)
	
func set_stats(character) -> void:
	var statsText = ""
	var statsSet = character.get_stats()
	
	# Max HP
	statsText += "Max HP: " + str(statsSet["max_health"])
	# Attack
	statsText += "\nAttack: " + str(statsSet["attack"])
	# Dexterity
	statsText += "\nDexterity: " + str(statsSet["dexterity"])
	# Defense
	statsText += "\nDefense: " + str(statsSet["defense"])
	# Agility
	statsText += "\nAgility: " + str(statsSet["agility"])
	
	# Movement
	match int(statsSet["movement"]):
		4:
			statsText += "\nMovement: Slow"
		5:
			statsText += "\nMovement: Normal"
		6:
			statsText += "\nMovement: Fast"
		_:
			statsText += "\nMovement: invalid"
		
	# Skills
	var skillText = ""
	for mySkill in statsSet["skills"]:
		skillText += GameStatus.get_skill_set()[mySkill].get_skill_name() + ", "
	
	if skillText == "":
		skillText = "None"
		
	else:
		skillText = skillText.left(-2)
		
	statsText += "\nSkills: " + skillText
	
	statsLabel.text = statsText

func set_important_stats(character) -> void:
	var statsText = ""
	var statsSet = character.get_stats()
	
	# Name
	statsText += "Name: " + statsSet["name"]
	# Class
	statsText += "\nClass: "
	match statsSet["name"]:
		"Dick":
			statsText += "Frontline Tank"
		"Edgar":
			statsText += "Backline Mage"
		_:
			statsText += "invalid character"
	
	importantStatsLabel.text = statsText
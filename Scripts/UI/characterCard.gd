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
	## Max Mana
	#statsText += "\nMax Mana: " + str(statsSet["max_mana"])
	## Initial Mana
	#statsText += "\nInitial Mana: " + str(statsSet["ini_mana"])
	## Mana Regen
	#statsText += "\nMana Regen: " + str(statsSet["reg_mana"])
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
			statsText += "\nMovement: 4 tiles"
		5:
			statsText += "\nMovement: 5 tiles"
		6:
			statsText += "\nMovement: 6 tiles"
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
		"Samael":
			statsText += "Frontline DPR"
		"Lystra":
			statsText += "Backline healer"
		"Salvador":
			statsText += "Backline DPR"
		_:
			statsText += "invalid character"
	
	importantStatsLabel.text = statsText

extends Control

var attacker
var defender

var skillName: String = ""
var skillResult: String = ""

signal combat_start(comPred, skillName, skillResult)
signal close(comPred)

@onready
var attackerSprite = $Attacker/Sprite
@onready
var attackerHPBar = $Attacker/HPBar
@onready
var attackerHPText = $Attacker/HPText

@onready
var defenderSprite = $Defender/Sprite
@onready
var defenderHPBar = $Defender/HPBar
@onready
var defenderHPText = $Defender/HPText

@onready
var attackGroup = $Attack
@onready
var attackPredictionText = $Attack/Label

@onready
var retaliateGroup = $Retaliate
@onready
var retaliatePredictionText = $Retaliate/Label

func _ready():
	# DEBUG
	#if GameStatus.debugMode:
		#debug_setup()
		
	attacker = CombatMapStatus.get_selected_character()
	defender = CombatMapStatus.get_selected_enemy()
	
	attackerSprite.texture = load(attacker.get_sprite())
	defenderSprite.texture = load(defender.get_sprite())
	
	attackerHPBar.max_value = attacker.get_max_health()
	defenderHPBar.max_value = defender.get_max_health()
	
	attackerHPBar.set_value_no_signal(attacker.get_current_health())
	defenderHPBar.set_value_no_signal(defender.get_current_health())
	
	attackerHPText.text = str(attacker.get_current_health()) + "/" + str(attacker.get_max_health())
	defenderHPText.text = str(defender.get_current_health()) + "/" + str(defender.get_max_health())
	
	attackPredictionText.text = predict_combat(attacker, defender)
	
	if Utils.calc_distance(attacker.get_map_coords(), defender.get_map_coords()) == 1:
		retaliateGroup.show()
		retaliatePredictionText.text = predict_combat(defender, attacker)
		attackGroup.set_position(Vector2(328, 72))
		
	else:
		retaliateGroup.hide()
		attackGroup.set_position(Vector2(328, 128))
	
# TODO Implement crit mod
func predict_combat(att, def) -> String:
	var result = ""
	
	if CombatMapStatus.attackSkill == "" or att.get_map_id() != CombatMapStatus.get_selected_character().get_map_id():
		result += "Hit Chance: " + str(Utils.predict_hit_chance(att.get_dexterity(), def.get_agility(), CombatMapStatus.mapMod)) + "%"
		result += "\nDamage: " + str(Utils.predict_damage(att.get_attack(), def.get_defense())) + " HP"
		result += "\nCritical Hit Chance: " + str(Utils.predict_crit_chance(att.get_dexterity(), att.get_agility(), def.get_agility(), 0)) + "%"
		
	else:
		var skillSet = GameStatus.skillSet[CombatMapStatus.attackSkill].get_skill()
		
		if skillSet["sef"]:
			result = SEF.predict(CombatMapStatus.attackSkill, attacker, defender, CombatMapStatus.mapMod, 0, skillSet["spa"], skillSet["imd"])
		
		else:
			result += "Hit Chance: " + str(Utils.predict_hit_chance(att.get_dexterity(), def.get_agility(), CombatMapStatus.mapMod)) + "%"
			result += "\nDamage: " + str(Utils.predict_damage(att.get_attack(), def.get_defense(), skillSet["spa"], skillSet["imd"])) + " HP"
			result += "\nCritical Hit Chance: " + str(Utils.predict_crit_chance(att.get_dexterity(), att.get_agility(), def.get_agility(), 0)) + "%"
		
	return result

func _on_attack_button_pressed():
	combat_start.emit(self)

func _on_cancel_button_pressed():
	close.emit(self)
	
func debug_setup():
	var playableCharacters = Utils.read_json("res://Assets/json/players.json")
	var enemySet = Utils.read_json("res://Assets/json/enemies.json")
	var skillSet = Utils.read_json("res://Assets/json/skills.json")
	
	var i = 0
	for skillName in skillSet:
		GameStatus.skillSet[skillName] = Factory.Skill.create(skillSet[skillName])
		GameStatus.skillSet[skillName].set_skill_menu_id(i)
		i += 1
		
	var tempAtt = Factory.Character.create(playableCharacters["dick"], true)
	var tempEne = Factory.Character.create(enemySet["orc"], true)
	
	tempAtt.set_map_id(0)
	tempEne.set_map_id(1)
	
	CombatMapStatus.set_map_size(Vector2(15,15))
	
	tempAtt.set_map_coords(Vector2(0,0))
	tempEne.set_map_coords(Vector2(0,1))
	
	CombatMapStatus.set_attack_skill("")
	
	CombatMapStatus.set_selected_character(tempAtt)
	CombatMapStatus.set_selected_enemy(tempEne)

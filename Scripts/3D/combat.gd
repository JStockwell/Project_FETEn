extends Node3D

@onready
var attackerSpawn = $Characters/AttackerSpawn

@onready
var defenderSpawn  = $Characters/DefenderSpawn 

@onready
var damageNumber = $UI/DamageNumber

var attacker
var defender

func _ready():
	if not GameStatus.debugMode:
		debugUI.hide()
		
	else:
		setup_debug_skill_options()
		
	# Create Attacker
	attacker = Factory.Character.create(GameStatus.attackerStats)
	defender = Factory.Character.create(GameStatus.defenderStats)
	
	add_child(attacker)
	add_child(defender)
	
	attacker.translate(attackerSpawn.get_position())
	defender.translate(defenderSpawn.get_position())

	# TODO Times and UI once Map is being used
	#combat_round(type)

func _process(delta):
	if GameStatus.debugMode:
		update_debug_text()

# 4 types: melee, ranged, skill and mag
func combat_round(type: String, rolls: Array, rolls_retaliate: Array, mapMod: int, skillName: String = "") -> void:
	# TODO return to map
	# TODO implement character acc and crit modifiers
	match type:
		"melee":
			attack(attacker, defender, rolls, mapMod)
			await wait(1)
			if defender.get_stats()["current_health"] != 0:
				attack(defender, attacker, rolls_retaliate, mapMod)
				await wait(1)
			
		"ranged":
			attack(attacker, defender, rolls, mapMod)
			await wait(1)

		"skill":
			# TODO Melee skill retaliation
			var skillSet = GameStatus.skillSet[skillName].get_skill()
			if skillSet["sef"]:
				SEF.run(self, skillName, attacker, defender, mapMod, 0, skillSet["spa"], skillSet["imd"])
			else:
				attack(attacker, defender, rolls, mapMod, skillSet["spa"], skillSet["imd"])
				await wait(1)
				
				if skillSet["isMelee"] and defender.get_stats()["current_health"] != 0:
					attack(defender, attacker, rolls_retaliate, mapMod)
					await wait(1)

# Attack functions
# TODO Map modifier
# t_ -> temporary
func attack(t_attacker, t_defender, rolls: Array, mapMod: int, spa: int = 0, imd: int = 0) -> void:
	# TODO Char mod
	if calc_hit_chance(t_attacker.get_stats()["dexterity"], t_defender.get_stats()["agility"], mapMod, rolls):
		var crit = calc_crit(t_attacker.get_stats()["dexterity"], t_attacker.get_stats()["agility"], t_defender.get_stats()["agility"], 0, rolls[3])
		var dmg = calc_damage(t_attacker.get_stats()["attack"], t_defender.get_stats()["defense"], spa, imd)
			
		deal_damage(dmg, crit, t_defender)
		
	else:
		update_damage_text("MISS")
		
func deal_damage(dmg: int, crit: float, t_defender):
	if dmg >= 0:
		t_defender.modify_health(-int(dmg * crit))
		update_damage_text(str(-int(dmg * crit)))
	else:
		update_damage_text("0")
	
	await wait(1.5)
	damageNumber.hide()

# Attack Calculations
func calc_hit_chance(att_dex: int, def_agi: int, accMod: int, rolls: Array) -> bool:
	var chance = 50 + 5 * att_dex - 3 * def_agi + accMod
	# 1: True hit, 2: Bloated hit
	if rolls[0] == 1:
		return rolls[1] <= chance
	else:
		var roll = int((rolls[1] + rolls[2]) / 2)
		return roll <= chance

func calc_crit(att_dex: int, att_agi: int, def_agi: int, critMod: int, crit_roll: int) -> float:
	if crit_roll <= ((att_dex + att_agi) - def_agi / 2) + critMod:
		return 1.5
	else:
		return 1

func calc_damage(att: int, def: int, spa: int = 0, imd: int = 0) -> int:
	return att + spa - (def * (1 - imd))

# Utility
func update_damage_text(text: String) -> void:
	damageNumber.text = text
	damageNumber.show()
	
func generate_rolls() -> Array:
	# true_hit_flag, dice_1, dice_2, crit_roll
	return [randi_range(1, 2), randi_range(1, 100), randi_range(1, 100), randi_range(1, 100)]

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

# Debug
@onready
var debugUI = $UI/Debug

@onready
var debugText = $UI/Debug/DebugText

@onready
var debugMeleeAttackButton = $UI/Debug/DebugButtons/DebugMeleeAttackButton

@onready
var debugRangedAttackButton = $UI/Debug/DebugButtons/DebugRangedAttackButton

@onready
var debugSkillAttackButton = $UI/Debug/DebugButtons/DebugSkillAttackButton

@onready
var debugButtonTimer = $UI/Debug/DebugButtons/DebugButtonTimer

@onready
var debugSkillOptions = $UI/Debug/DebugSkillOptions

func _on_debug_phys_attack_pressed() -> void:
	combat_round("melee", generate_rolls(), generate_rolls() , 0)
	update_debug_buttons(true)
	debugButtonTimer.start()
	
func _on_debug_ranged_attack_button_pressed():
	combat_round("ranged", generate_rolls(), generate_rolls(), 0)
	update_debug_buttons(true)
	debugButtonTimer.start()

func _on_debug_skill_attack_button_pressed():
	combat_round("skill", generate_rolls(), generate_rolls(), 0, debugSkillOptions.get_item_text(debugSkillOptions.get_selected_id()))
	update_debug_buttons(true)
	debugButtonTimer.start()
	
# Debug utilities
func update_debug_text() -> void:
	debugText.text = "attacker_hp: {att_hp}\ndefender_hp: {def_hp}".format({"att_hp": attacker.get_stats()["current_health"], "def_hp": defender.get_stats()["current_health"]})

func update_debug_buttons(value: bool) -> void:
	debugMeleeAttackButton.disabled = value
	debugRangedAttackButton.disabled = value
	debugSkillAttackButton.disabled = value
	
func setup_debug_skill_options() -> void:
	for skillName in GameStatus.attackerStats["skills"]:
		debugSkillOptions.add_item(skillName)

func _on_debug_button_timer_timeout():
	update_debug_buttons(false)

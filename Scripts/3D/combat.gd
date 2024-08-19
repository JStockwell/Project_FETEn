extends Node3D

@onready
var attackerSpawn = $Characters/AttackerSpawn

@onready
var defenderSpawn  = $Characters/DefenderSpawn 

@onready
var damageNumber = $UI/DamageNumber

@onready
var camera = $Utility/CameraPivot/Camera3D

var attacker
var defender

signal combat_end

var debug: bool = false

func _ready():
	if not debug:
		debugUI.hide()
		
	else:
		setup_debug_skill_options()
		
	# Create Attacker
	attacker = Factory.Character.create(CombatMapStatus.attackerStats)
	defender = Factory.Character.create(CombatMapStatus.defenderStats)
	
	add_child(attacker)
	add_child(defender)
	
	attacker.position = CombatMapStatus.get_combat_spawn()
	attacker.translate(attackerSpawn.get_position())
	
	defender.position = CombatMapStatus.get_combat_spawn()
	defender.translate(defenderSpawn.get_position())
	
	damageNumber.global_position = CombatMapStatus.get_combat_spawn() + Vector3(0, 3.75, 0)

	# TODO Times and UI once Map is being used
	if GameStatus.autorunCombat:
		combat_round(generate_rolls(), generate_rolls(), CombatMapStatus.mapMod, CombatMapStatus.attackRange, CombatMapStatus.attackSkill)

#func _process(delta):
	#if GameStatus.debugMode:
		#update_debug_text()

# 4 types: melee, ranged, skill and mag
func combat_round(rolls: Array, rolls_retaliate: Array, mapMod: int, range: int, skillName: String = "") -> void:
	# TODO implement character acc and crit modifiers
	if skillName == "":
		await attack(attacker, defender, rolls, mapMod)
	else:
		var skillSet = GameStatus.skillSet[skillName].get_skill()
		if skillSet["sef"]:
			await SEF.run(self, skillName, attacker, defender, mapMod, 0, skillSet["spa"], skillSet["imd"])
		else:
			await attack(attacker, defender, rolls, mapMod, skillSet["spa"], skillSet["imd"])
	
	if range == 1 and defender.get_stats()["current_health"] != 0:
		# TODO check mapMod for enemy? No mapMod?
		await attack(defender, attacker, rolls_retaliate, mapMod)
		
	elif defender.get_stats()["current_health"] == 0:
		CombatMapStatus.remove_character_ini(defender.get_map_id())
		
		if CombatMapStatus.get_current_ini() > len(CombatMapStatus.get_initiative()) - 1:
			CombatMapStatus.set_current_ini(CombatMapStatus.get_current_ini() - 1)
		
	CombatMapStatus.set_has_attacked(true)
	combat_end.emit()
	#get_tree().change_scene_to_file("res://Scenes/3D/tavern.tscn")

# Attack functions
# TODO Map modifier
# t_ -> temporary
func attack(t_attacker, t_defender, rolls: Array, mapMod: int, spa: int = 0, imd: int = 0) -> void:
	# TODO Char mod
	if calc_hit_chance(t_attacker.get_stats()["dexterity"], t_defender.get_stats()["agility"], mapMod, rolls):
		var crit = calc_crit(t_attacker.get_stats()["dexterity"], t_attacker.get_stats()["agility"], t_defender.get_stats()["agility"], 0, rolls[3])
		var dmg = calc_damage(t_attacker.get_stats()["attack"], t_defender.get_stats()["defense"], spa, imd)
			
		await deal_damage(dmg, crit, t_defender)
		
	else:
		await update_damage_text("MISS")
		
func deal_damage(dmg: int, crit: float, t_defender):
	var dmgText: String
	if dmg >= 0:
		t_defender.modify_health(-int(dmg * crit))
		dmgText = str(-int(dmg * crit))
	else:
		dmgText = "0"
		
	damageNumber.text = dmgText
	
	damageNumber.show()
	await wait(0.75)
	
	damageNumber.hide()
	await wait(0.3)

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
	await wait(0.75)
	
	damageNumber.hide()
	await wait(0.3)
	
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

#func _on_debug_phys_attack_pressed() -> void:
	#combat_round("melee", generate_rolls(), generate_rolls() , 0)
	#update_debug_buttons(true)
	#debugButtonTimer.start()
	#
#func _on_debug_ranged_attack_button_pressed():
	#combat_round("ranged", generate_rolls(), generate_rolls(), 0)
	#update_debug_buttons(true)
	#debugButtonTimer.start()
#
#func _on_debug_skill_attack_button_pressed():
	#combat_round("skill", generate_rolls(), generate_rolls(), 0, debugSkillOptions.get_item_text(debugSkillOptions.get_selected_id()))
	#update_debug_buttons(true)
	#debugButtonTimer.start()
	
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

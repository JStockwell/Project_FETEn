extends Node3D

@onready
var attacker = $Characters/Attacker

@onready
var defender = $Characters/Defender

@onready
var damageNumber = $UI/DamageNumber

var Character = preload("res://Scenes/Entities/character.tscn")

func _ready():
	if not GameStatus.debugMode:
		debugUI.hide()
		
	init_characters()
	# TODO Times and UI once Map is being used
	#combat_round(type)
	
func _process(delta):
	if GameStatus.debugMode:
		update_debug_text()

# Initialize characters
func init_characters():
	attacker.set_stats(GameStatus.get_attacker_stats())
	attacker.set_mesh(GameStatus.get_attacker_stats()["mesh_path"])
	
	defender.set_stats(GameStatus.get_defender_stats())
	defender.set_mesh(GameStatus.get_defender_stats()["mesh_path"])
	#defender.rotate_y(PI/4)

# 4 types: melee, ranged, skill and mag
func combat_round(type: String, rolls: Array, spa: int = 0, sef: String = "") -> void:
	# TODO return to map
	match type:
		"melee":
			attack(attacker, defender, "phys", rolls)
			await wait(1)
			attack(defender, attacker, "phys", rolls)
			await wait(1)
			
		"ranged":
			attack(attacker, defender, "phys", rolls)
			await wait(1)
			if defender.is_ranged() and defender.get_stats()["range"] >= attacker.get_stats()["range"]:
				attack(defender, attacker, "phys", rolls)
				await wait(1)

		"skill":
			attack(attacker, defender, type, rolls, spa, sef)
			await wait(1)

		"mag":
			attack(attacker, defender, type, rolls, spa)
			await wait(1)
	

# Attack functions
# TODO Map modifier
# t_ -> temporary
func attack(t_attacker, t_defender, type: String, rolls: Array, spa: int = 0, sef: String = ""):
	if calc_hit_chance(t_attacker.get_stats()["dexterity"], t_defender.get_stats()["agility"], 0, rolls):
		var crit = calc_crit(t_attacker.get_stats()["dexterity"], t_attacker.get_stats()["agility"], t_defender.get_stats()["agility"], rolls[3])
		var dmg = 0
		match type:
			"phys":
				dmg = calc_phys_damage(t_attacker.get_stats()["attack"], t_defender.get_stats()["defense"])
			"skill":
				dmg = calc_skill_damage(t_attacker.get_stats()["attack"], t_defender.get_stats()["defense"], spa, sef)
			"mag":
				dmg = calc_mag_damage(t_attacker.get_stats()["attack"], spa)
		
		t_defender.modify_health(-int(dmg * crit))
		update_damage_text(str(int(dmg * crit)))
		
		await wait(1.5)
		damageNumber.hide()
		
	else:
		update_damage_text("MISS")
		
# Attack Calculations
func calc_hit_chance(att_dex: int, def_agi: int, map_mod: int, rolls: Array) -> bool:
	var chance = 50 + 5 * att_dex - 3 * def_agi - map_mod
	# 1: True hit, 2: Bloated hit
	if rolls[0] == 1:
		return rolls[1] <= chance
	else:
		var roll = int((rolls[1] + rolls[2]) / 2)
		return roll <= chance
		
func calc_crit(att_dex: int, att_agi: int, def_agi: int, crit_roll: int) -> int:
	if crit_roll <= (att_dex + att_agi) / 2 - def_agi / 2:
		return 1.5
	else:
		return 1

func calc_phys_damage(att: int, def: int) -> int:
	return att - def
	
func calc_skill_damage(att: int, def: int, spa: int, sef: String) -> int:
	if sef != "":
   # TODO Execute sef
		pass
	return att + spa - def
	
func calc_mag_damage(att: int, spa: int) -> int:
	return att + spa

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
var debugMeleeAttackButton = $UI/Debug/DebugMeleeAttackButton

@onready
var debugRangedAttackButton = $UI/Debug/DebugRangedAttackButton

@onready
var debugSkillAttackButton = $UI/Debug/DebugSkillAttackButton

@onready
var debugMagAttackButton = $UI/Debug/DebugMagAttackButton

# TODO disable all buttons every time you press an attack
func _on_debug_phys_attack_pressed() -> void:
	combat_round("melee", generate_rolls())
	
func _on_debug_ranged_attack_button_pressed():
	combat_round("ranged", generate_rolls())

# TODO test with sef aswell
func _on_debug_skill_attack_button_pressed():
	combat_round("skill", generate_rolls(), 6)

func _on_debug_mag_attack_button_pressed():
 # TODO implement with skills
	combat_round("mag", generate_rolls(), 6)
	
# Debug utilities
func update_debug_text() -> void:
	debugText.text = "attacker_hp: {att_hp}\ndefender_hp: {def_hp}".format({"att_hp": attacker.get_stats()["current_health"], "def_hp": defender.get_stats()["current_health"]})

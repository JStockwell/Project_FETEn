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
	update_debug_text()

# Initialize characters
func init_characters():
	attacker.set_stats(GameStatus.get_attacker_stats())
	attacker.set_mesh(GameStatus.get_attacker_stats()["mesh_path"])
	
	defender.set_stats(GameStatus.get_defender_stats())
	defender.set_mesh(GameStatus.get_defender_stats()["mesh_path"])
	#defender.rotate_y(PI/4)

# 4 types: melee, ranged, skill and mag
func combat_round(type: String) -> void:
	# TODO return to map
	match type:
		"melee":
			attack(attacker, defender, "phys")
			await wait(1)
			attack(defender, attacker, "phys")
			await wait(1)
			
		"ranged":
			attack(attacker, defender, "phys")
			await wait(1)
			if defender.is_ranged():
				attack(defender, attacker, "phys")
				await wait(1)

# Attack functions
# TODO Map modifier
# t_ -> temporary
func attack(t_attacker, t_defender, type: String):
	if calc_hit_chance(t_attacker.get_stats()["dexterity"], t_defender.get_stats()["agility"], 0):
		var crit = calc_crit(t_attacker.get_stats()["dexterity"], t_attacker.get_stats()["agility"], t_defender.get_stats()["agility"])
		var dmg = 0
		match type:
			"phys":
				dmg = calc_phys_damage(t_attacker.get_stats()["attack"], t_defender.get_stats()["defense"])
			"skill":
				dmg = calc_skill_damage(t_attacker.get_stats()["attack"], 0, t_defender.get_stats()["defense"])
			"mag":
				dmg = calc_mag_damage(t_attacker.get_stats()["attack"], 0)
		
		t_defender.recieve_damage(int(dmg * crit))
		update_damage_text(str(int(dmg * crit)))
		
		await wait(1.5)
		damageNumber.hide()
		
	else:
		update_damage_text("MISS")
		
# Attack Calculations
func calc_hit_chance(att_dex: int, def_agi: int, map_mod: int) -> bool:
	var chance = 50 + 5 * att_dex - 3 * def_agi - map_mod
	# 1: True hit, 2: Bloated hit
	if randi_range(1,2) == 1:
		return randi_range(1,100) <= chance
	else:
		var roll = int((randi_range(1,100) + randi_range(1,100)) / 2)
		return roll <= chance
		
func calc_crit(att_dex: int, att_agi: int, def_agi: int) -> int:
	if randi_range(1,100) <= (att_dex + att_agi) / 2 - def_agi / 2:
		return 1.5
	else:
		return 1

func calc_phys_damage(att: int, def: int) -> int:
	return att - def
	
func calc_skill_damage(att: int, def: int, spa: int) -> int:
	return att + spa - def
	
func calc_mag_damage(att: int, spa: int) -> int:
	return att + spa

# Utility
func update_damage_text(text: String) -> void:
	damageNumber.text = text
	damageNumber.show()
	
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

func _on_debug_phys_attack_pressed() -> void:
	debugMeleeAttackButton.disabled = true
	combat_round("melee")
	debugMeleeAttackButton.disabled = false
	
func _on_debug_ranged_attack_button_pressed():
	debugRangedAttackButton.disabled = true
	combat_round("ranged")
	debugRangedAttackButton.disabled = false
	
# Debug utilities
func update_debug_text() -> void:
	debugText.text = "attacker_hp: {att_hp}\ndefender_hp: {def_hp}".format({"att_hp": attacker.get_stats()["current_health"], "def_hp": defender.get_stats()["current_health"]})

class_name SEF extends Node

var Character = preload("res://Scenes/Entities/character.tscn")

static func run(Combat, sefName:String, attacker, defender, accMod: int, critMod: int, spa: int = 0, imd = 0):
	match sefName:
		"hello_world":
			hello_world()
		"nero_nero":
			await nero_nero(Combat, attacker, defender, spa, imd)
		"mend_flesh":
			healing_spell(attacker, defender, spa)
		"boost_1":
			await boost(Combat, attacker, defender, accMod, critMod, spa, imd, 1)
		"boost_2":
			await boost(Combat, attacker, defender, accMod, critMod, spa, imd, 2)
		"bestow_life":
			healing_spell(attacker, defender, spa)
		"creators_touch":
			healing_spell(attacker, defender, spa)
		"anchoring_strike":
			await anchoring_strike(Combat, attacker, defender, accMod, spa, imd)

static func hello_world():
	print("Hello World!")

static func nero_nero(Combat, attacker, defender, spa: int, imd: int):
	var dmg = Combat.calc_damage(attacker.get_stats()["attack"], defender.get_stats()["defense"], spa, imd)
	await Combat.deal_damage(dmg, 1, defender)

static func boost(Combat, attacker, defender, accMod: int, critMod: int, spa: int, imd: int, level: int):
	var rolls = Combat.generate_rolls()
	var rolls_retaliate = Combat.generate_rolls()
	
	if Combat.calc_hit_chance(attacker.get_dexterity(), defender.get_agility(), accMod + (15 * level), rolls):
		var crit = Combat.calc_crit(attacker.get_dexterity(), attacker.get_agility(), defender.get_agility(), critMod + (3 * level), rolls[3])
		var dmg = Combat.calc_damage(attacker.get_attack(), defender.get_defense(), spa, imd)
		
		await Combat.deal_damage(dmg, crit, defender)
		
	else:
		await Combat.update_damage_text("MISS")
		

static func healing_spell(attacker, defender, spa:int):
	var amount_healed = attacker.get_attack() + spa
	defender.modify_health(amount_healed)
	
static func anchoring_strike(Combat, attacker, defender, accMod: int, spa, imd):

	var rolls = Combat.generate_rolls()
	var rolls_retaliate = Combat.generate_rolls()
	
	await Combat.attack(attacker, defender, rolls, accMod, spa, imd)
		
	if defender.get_stats()["current_health"] != 0:
		defender.set_is_rooted(true)


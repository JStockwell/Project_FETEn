class_name SEF extends Node

var Character = preload("res://Scenes/Entities/character.tscn")

static func run(Combat, sefName:String, attacker, defender, accMod: int, critMod: int, spa: int = 0, imd = 0):
	match sefName:
		"hello_world":
			hello_world()
		"nero_nero":
			nero_nero(Combat, attacker, defender, spa, imd)
		"mend_flesh":
			healing_spell(attacker, defender, spa)
		"boost_1":
			boost(Combat, attacker, defender, accMod, critMod, spa, imd, 1)
		"boost_2":
			boost(Combat, attacker, defender, accMod, critMod, spa, imd, 2)
		"healing_light":
			healing_spell(attacker, defender, spa)
		"radiant_restoration":
			healing_spell(attacker, defender, spa)

static func hello_world():
	print("Hello World!")

static func nero_nero(Combat, attacker, defender, spa: int, imd: int):
	var dmg = Combat.calc_damage(attacker.get_stats()["attack"], defender.get_stats()["defense"], spa, imd)
	Combat.deal_damage(dmg,1,defender)

static func boost(Combat, attacker, defender, accMod: int, critMod: int, spa: int, imd: int, level: int):
	var rolls = Combat.generate_rolls()
	var rolls_retaliate = Combat.generate_rolls()
	
	if Combat.calc_hit_chance(attacker.get_dexterity(), defender.get_agility(), accMod + (15 * level), rolls):
		var crit = Combat.calc_crit(attacker.get_dexterity(), attacker.get_agility(), defender.get_agility(), critMod + (3 * level), rolls[3])
		var dmg = Combat.calc_damage(attacker.get_attack(), defender.get_defense(), spa, imd)
		
		Combat.deal_damage(dmg, crit, defender)
		
	else:
		Combat.update_damage_text("MISS")
		
	if defender.get_stats()["current_health"] != 0:
		Combat.attack(defender, attacker, rolls_retaliate, accMod)
		await Combat.wait(1)

static func healing_spell(attacker, defender, spa:int): # The range comes from a previous check from what I understand from nero nero?
	var amount_healed = attacker.get_attack() + spa
	defender.modify_health(amount_healed)


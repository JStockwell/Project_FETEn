class_name SEF extends Node

var Character = preload("res://Scenes/Entities/character.tscn")

static func run(Combat, sefName:String, attacker, defender, accMod: int, critMod: int, spa: int = 0, imd = 0):
	match sefName:
		"hello_world":
			hello_world()
		"nero_nero":
			nero_nero(Combat, attacker, defender, spa, imd)
		"boost_2":
			boost_2(Combat, attacker, defender, accMod, critMod, spa, imd)

static func hello_world():
	print("Hello World!")

static func nero_nero(Combat, attacker, defender, spa: int, imd: int):
	var dmg = Combat.calc_damage(attacker.get_stats()["attack"], defender.get_stats()["defense"], spa, imd)
	Combat.deal_damage(dmg,1,defender)

static func boost_2(Combat, attacker, defender, accMod: int, critMod: int, spa: int, imd: int):
	var rolls = Combat.generate_rolls()
	if Combat.calc_hit_chance(attacker.get_dexterity(), defender.get_agility(), accMod + 30, rolls):
		var crit = Combat.calc_crit(attacker.get_dexterity(), attacker.get_agility(), defender.get_agility(), critMod + 6, rolls[3])
		var dmg = Combat.calc_damage(attacker.get_attack(), defender.get_defense(), spa, imd)
		
		Combat.deal_damage(dmg, crit, defender)
		
	else:
		Combat.update_damage_text("MISS")

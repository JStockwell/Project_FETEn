class_name SEF extends Node

var Character = preload("res://Scenes/Entities/character.tscn")

static func run(Combat, sefName:String, rolls, attacker, defender, accMod: int, critMod: int, spa: int = 0, imd = 0):
	match sefName:
		"hello_world":
			hello_world()
		"nero_nero":
			await nero_nero(Combat, attacker, defender, spa, imd)
		"boost_1":
			await boost(Combat, rolls, attacker, defender, accMod, critMod, spa, imd, 1)
		"boost_2":
			await boost(Combat, rolls, attacker, defender, accMod, critMod, spa, imd, 2)
		"anchoring_strike":
			await anchoring_strike(Combat, rolls, attacker, defender, accMod, critMod, spa, imd)

static func hello_world():
	print("Hello World!")

static func nero_nero(Combat, attacker, defender, spa: int, imd: int):
	var dmg = Combat.calc_damage(attacker.get_stats()["attack"], defender.get_stats()["defense"], spa, imd)
	await Combat.deal_damage(dmg, 1, defender)

static func boost(Combat, rolls, attacker, defender, accMod: int, critMod: int, spa: int, imd: int, level: int):
	if Combat.calc_hit_chance(attacker.get_dexterity(), defender.get_agility(), accMod + (15 * level), rolls):
		var crit = Combat.calc_crit(attacker.get_dexterity(), attacker.get_agility(), defender.get_agility(), critMod + (3 * level), rolls[3])
		var dmg = Combat.calc_damage(attacker.get_attack(), defender.get_defense(), spa, imd)
		
		await Combat.deal_damage(dmg, crit, defender)
		
	else:
		await Combat.update_damage_text("MISS")
		

static func anchoring_strike(Combat, rolls, attacker, defender, accMod: int, critMod: int, spa: int, imd: int):
	if Combat.calc_hit_chance(attacker.get_dexterity(), defender.get_agility(), accMod, rolls):
		var crit = Combat.calc_crit(attacker.get_dexterity(), attacker.get_agility(), defender.get_agility(), critMod, rolls[3])
		var dmg = Combat.calc_damage(attacker.get_attack(), defender.get_defense(), spa, imd)
		
		await Combat.deal_damage(dmg, crit, defender)
		if defender.get_current_health() > 0:
			defender.set_is_rooted(true)
		
	else:
		await Combat.update_damage_text("MISS")


static func run_out_of_combat(sefName:String, caster, target, spa: int = 0):
	match sefName:
		"mend_flesh":
			healing_spell(caster, target, spa)
		"bestow_life":
			healing_spell(caster, target, spa)
		"creators_touch":
			healing_spell(caster, target, spa)
		"action_surge":
			action_surge()


static func action_surge():
	CombatMapStatus.set_has_attacked(false)

static func healing_spell(caster, target, spa:int):
	var amountHealed = caster.get_attack() + spa
	if target.get_max_health() - target.get_current_health() < amountHealed:
		amountHealed = target.get_max_health - target.get_current_health()
	
	if target.get_healing_threshold() - amountHealed < 0:
		amountHealed = target.get_healing_threshold()
		target.modify_healing_threshold(0)
	else:
		var currentThreshold = target.get_healing_threshold() - amountHealed
		target.modify_healing_threshold(currentThreshold)
	
	target.modify_health(amountHealed)


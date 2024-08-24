extends GdUnitTestSuite

var Character = preload("res://Scenes/Entities/character.tscn")
var Combat = load("res://Scenes/3D/combat.tscn")

var test_players = Utils.read_json("res://Assets/json/test_players.json")
var test_enemies = Utils.read_json("res://Assets/json/test_enemies.json")
var skillSet = Utils.read_json("res://Assets/json/skills.json")

var attacker
var defender
var test_combat 

var stats_atk
var stats_def

func before():
	GameStatus.debugMode = false
	

func before_test():
	attacker = Character.instantiate()
	add_child(attacker)
	defender = Character.instantiate()
	add_child(defender)
	
	var i = 0
	for skillName in skillSet:
		GameStatus.skillSet[skillName] = Factory.Skill.create(skillSet[skillName])
		GameStatus.skillSet[skillName].set_skill_menu_id(i)
		i += 1
	
	stats_atk = test_players["attacker"]

	stats_def = test_enemies["defender"]
	
	attacker = Factory.Character.create(stats_atk, true)
	defender = Factory.Character.create(stats_def, true)
	
	CombatMapStatus.set_active_characters(attacker.get_stats(), defender.get_stats())
	GameStatus.set_autorun_combat(false)
	
	test_combat = Combat.instantiate()
	add_child(test_combat)
	
	
func after_test():
	attacker.free()
	defender.free()
	test_combat.free()
	for test_skill_combat in GameStatus.skillSet:
		GameStatus.skillSet[test_skill_combat].free()
	Utils.reset_all()


##############
# Unit Tests #
##############

func test_not_null():
	assert_that(attacker).is_not_null()
	assert_that(defender).is_not_null()
	assert_that(test_combat).is_not_null()
	
	
func test_calc_hit_chance_true_hit():
	var attDex = CombatMapStatus.get_attacker_stats().get("dexterity")
	var defAgi = CombatMapStatus.get_defender_stats().get("agility")
	var rolls = [1, 71, 1, 1]
	
	var test_res = test_combat.calc_hit_chance(attDex, defAgi, 0, rolls)
	
	assert_bool(test_res).is_true()
	
	
func test_calc_hit_chance_true_hit_fail():
	var attDex = CombatMapStatus.get_attacker_stats().get("dexterity")
	var defAgi = CombatMapStatus.get_defender_stats().get("agility")
	var rolls = [1, 72, 1, 1]
	
	var test_res = test_combat.calc_hit_chance(attDex, defAgi, 0, rolls)
	
	assert_bool(test_res).is_false()
	
	
func test_calc_hit_chance_bloated_hit():
	var attDex = CombatMapStatus.get_attacker_stats().get("dexterity")
	var defAgi = CombatMapStatus.get_defender_stats().get("agility")
	var rolls = [2, 43, 100, 1]
	
	var test_res = test_combat.calc_hit_chance(attDex, defAgi, 0, rolls)
	
	assert_bool(test_res).is_true()
	
	
func test_calc_hit_chance_bloated_hit_fail():
	var attDex = CombatMapStatus.get_attacker_stats().get("dexterity")
	var defAgi = CombatMapStatus.get_defender_stats().get("agility")
	var rolls = [2, 44, 100, 1]
	
	var test_res = test_combat.calc_hit_chance(attDex, defAgi, 0, rolls)
	
	assert_bool(test_res).is_false()
	
	
func test_calc_crit():
	var attDex = CombatMapStatus.get_attacker_stats().get("dexterity")
	var attAgi = CombatMapStatus.get_attacker_stats().get("agility")
	var defAgi = CombatMapStatus.get_defender_stats().get("agility")
	var rolls = [1, 1, 1, 13]
	
	var test_res = test_combat.calc_crit(attDex, attAgi, defAgi, 0, rolls[3])
	
	assert_that(test_res).is_equal(1.5)
	
	
func test_calc_crit_no():
	var attDex = CombatMapStatus.get_attacker_stats().get("dexterity")
	var attAgi = CombatMapStatus.get_attacker_stats().get("agility")
	var defAgi = CombatMapStatus.get_defender_stats().get("agility")
	var rolls = [1, 1, 1, 14]
	
	var test_res = test_combat.calc_crit(attDex, attAgi, defAgi, 0, rolls[3])
	
	assert_that(test_res).is_equal(1.)
	
	
func test_calc_damage_no_magic():
	var attack = CombatMapStatus.get_attacker_stats().get("attack")
	var defense = CombatMapStatus.get_defender_stats().get("defense")
	var should_dmg = attack - defense
	
	var test_res = test_combat.calc_damage(attack, defense, 0, 0)
	
	assert_int(test_res).is_equal(int(should_dmg))
	
	
func test_calc_damage_magic():
	var should_dmg = stats_atk.get("attack")
	
	var attack = CombatMapStatus.get_attacker_stats().get("attack")
	var defense = CombatMapStatus.get_defender_stats().get("defense")
	var test_res = test_combat.calc_damage(attack, defense, 0, 1)
	
	assert_that(test_res).is_equal(int(should_dmg))
	
	
func test_calc_damage_no_magic_SPA():
	var should_dmg = stats_atk.get("attack") + 5 - stats_def.get("defense")
	
	var attack = CombatMapStatus.get_attacker_stats().get("attack")
	var defense = CombatMapStatus.get_defender_stats().get("defense")
	var spa = 5
	var test_res = test_combat.calc_damage(attack, defense, spa, 0)
	
	assert_that(test_res).is_equal(int(should_dmg))
	
	
func test_calc_damage_magic_no_SPA():
	var should_dmg = stats_atk.get("attack") + 5
	var attack = CombatMapStatus.get_attacker_stats().get("attack")
	var defense = CombatMapStatus.get_defender_stats().get("defense")
	var spa = 5
	
	var test_res = test_combat.calc_damage(attack, defense, spa, 1)
	
	assert_that(test_res).is_equal(int(should_dmg))
	
	
func test_generate_rolls_1_2_and_1_100():
	var dices = test_combat.generate_rolls()
	
	for  i in range(10):
		for j in range(3):
			var dice = dices[j]
			if j == 0:
				assert_int(dice).is_between(1,2)
			else:
				assert_int(dice).is_between(1,100)
	
	
func test_generate_rolls_random():
	var dices1 = []
	var dices2 = []
	
	for i in range(8000):
		dices1.append_array(test_combat.generate_rolls())
		dices2.append_array(test_combat.generate_rolls())
	
	assert_that(dices1).is_not_equal(dices2)


#####################
# Integration Tests #
#####################

func test_combat_round_melee():
	await test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 1,"")

	assert_int(defender.get_current_health()).is_less(defender.get_max_health())
	assert_int(attacker.get_current_health()).is_less(attacker.get_max_health())

	
func test_combat_round_ranged():
	test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 4,"")

	assert_int(defender.get_current_health()).is_less(defender.get_max_health())
	
	
func test_combat_round_skill_no_SEF_retaliation():
	attacker.get_stats()["attack"] = 5
	
	await test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 1,"shadow_ball")

	assert_int(defender.get_current_health()).is_less(defender.get_max_health())
	assert_int(attacker.get_current_health()).is_less(attacker.get_max_health())
	

func test_combat_round_skill_no_SEF_no_retaliation():
	test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 4,"shadow_ball")

	assert_int(defender.get_current_health()).is_less(defender.get_max_health())
	
	
func test_combat_round_skill_SEF_retaliation():
	attacker.get_stats()["attack"] = 2
	
	await test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 1,"nero_nero")
	
	assert_int(defender.get_current_health()).is_less(defender.get_max_health())
	assert_int(attacker.get_current_health()).is_less(attacker.get_max_health())
	

func test_combat_round_skill_SEF_no_retaliation():
	test_combat.combat_round([1, 100, 1, 100], [1, 1, 1, 100], 0, 4,"nero_nero")

	assert_int(defender.get_current_health()).is_less(defender.get_max_health())
	
	
func test_combat_round_kill_no_retaliation():
	attacker.get_stats()["attack"] = 50
	attacker.get_stats()["map_id"] = 0
	defender.get_stats()["map_id"] = 1
	CombatMapStatus.set_initiative([0, 1])

	await test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 1,"")

	assert_int(defender.get_current_health()).is_less(defender.get_max_health())
	assert_int(attacker.get_current_health()).is_equal(attacker.get_max_health())
	
	
func test_attack_hit():
	var rolls = [1, 1, 1, 1]
	
	test_combat.attack(attacker, defender, rolls, 0, 0, 0)

	assert_int(defender.get_current_health()).is_less(defender.get_max_health())


func test_attack_miss():
	var rolls = [1, 100, 1, 1]
	
	test_combat.attack(attacker, defender, rolls, 0, 0, 0)
	
	assert_that(defender.get_current_health()).is_equal(defender.get_max_health())
	assert_that(test_combat.damageNumber.text).is_equal("MISS")


func test_deal_damage_positive_no_crit():
	test_combat.deal_damage(2, 1., defender)
	
	assert_that(defender.get_current_health()).is_equal(20)
	assert_that(test_combat.damageNumber.text).is_equal("-2")


func test_deal_damage_positive_crit():
	test_combat.deal_damage(2, 1.5, defender)
	
	assert_that(defender.get_current_health()).is_equal(19)
	assert_that(test_combat.damageNumber.text).is_equal("-3")
	
	
func test_deal_damage_0():
	test_combat.deal_damage(0, 1., defender)
	
	assert_that(defender.get_current_health()).is_equal(defender.get_max_health())
	assert_that(test_combat.damageNumber.text).is_equal("0")
	
func test_deal_damage_negative():
	test_combat.deal_damage(-1, 1., defender)
	
	assert_that(defender.get_current_health()).is_equal(defender.get_max_health())
	assert_that(test_combat.damageNumber.text).is_equal("0")

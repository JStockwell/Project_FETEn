extends GdUnitTestSuite

var Character = preload("res://Scenes/Entities/character.tscn")
var Combat = preload("res://Scenes/3D/combat.tscn")

var test_players = Utils.read_json("res://Assets/json/test_players.json")
var test_enemies = Utils.read_json("res://Assets/json/test_enemies.json")
var skillSet = Utils.read_json("res://Assets/json/skills.json")

var attacker
var defender
var ally
var test_combat 

var stats_atk
var stats_def
var stats_ally

func before_test():
	attacker = Character.instantiate()
	add_child(attacker)
	defender = Character.instantiate()
	add_child(defender)
	ally = Character.instantiate()
	add_child(ally)
	
	var i = 0
	for skillName in skillSet:
		GameStatus.skillSet[skillName] = Factory.Skill.create(skillSet[skillName])
		GameStatus.skillSet[skillName].set_skill_menu_id(i)
		i += 1
	
	stats_atk = {
		"name": "Attacker",
		"max_health": 24,
		"attack": 9,
		"dexterity": 9,
		"defense": 6,
		"agility": 8,
		"movement": 5,
		"ini_mana": 5,
		"max_mana": 20,
		"reg_mana": 5,
		"range": 4,
		"skills": ["shadow_ball", "nero_nero", "mend_flesh", "boost_1", "boost_2", "bestow_life", "creators_touch", "anchoring_strike", "flaming_daggers"], # GameStatus.get_ability_by_id("SKILL_ID_1") -> instance ability.gd
		"is_ranged": false,
		"is_rooted": false,
		"mesh_path": "res://Assets/Characters/Placeholder/Placeholder_Char.glb",
		"current_health": 24,
		"current_mana": 5,
		"is_enemy": false,
		"map_id": 0
	}
	
	stats_ally = {
		"name": "Ally",
		"max_health": 50,
		"attack": 16,
		"dexterity": 9,
		"defense": 6,
		"agility": 8,
		"movement": 5,
		"ini_mana": 5,
		"max_mana": 20,
		"reg_mana": 5,
		"range": 4,
		"skills": [],
		"is_ranged": false,
		"is_rooted": false,
		"mesh_path": "res://Assets/Characters/Placeholder/Placeholder_Char.glb",
		"current_health": 25,
		"current_mana": 5,
		"is_enemy": false,
		"map_id": 0
	}

	stats_def = {
		"name": "Defender",
		"max_health": 40,
		"attack": 14,
		"dexterity": 10,
		"defense": 6,
		"agility": 10,
		"movement": 5,
		"ini_mana": 5,
		"max_mana": 20,
		"reg_mana": 5,
		"range": 4,
		"skills": [], # GameStatus.get_ability_by_id("SKILL_ID_1") -> instance ability.gd
		"is_ranged": false,
		"is_rooted": false,
		"mesh_path": "res://Assets/Characters/Placeholder/Placeholder_Char.glb",
		"current_health": 40,
		"current_mana": 5,
		"is_enemy": true,
		"map_id": 2
	}
	
	stats_atk = test_players["attacker_skillTests"]
	stats_ally = test_players["ally_skillTests"]
	stats_def = test_enemies["defender_skillTests"]
	
	attacker = Factory.Character.create(stats_atk, false)
	defender = Factory.Character.create(stats_def, false)
	ally = Factory.Character.create(stats_ally, false)
	CombatMapStatus.set_active_characters(attacker.get_stats(), defender.get_stats())
	GameStatus.set_autorun_combat(false)
	
	test_combat = Combat.instantiate()
	add_child(test_combat)
	
	
func after_test():
	attacker.free()
	defender.free()
	ally.free()
	test_combat.free()
	for test_skill in GameStatus.skillSet:
		GameStatus.skillSet[test_skill].free()
	Utils.reset_all()


##############
# Unit Tests #
##############

func test_not_null():
	assert_that(attacker).is_not_null()
	assert_that(defender).is_not_null()
	assert_that(ally).is_not_null()
	assert_that(test_combat).is_not_null()

	
#####################
# Integration Tests #
#####################

func test_combat_round_shadow_ball():
	test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 4, "shadow_ball")
	
	var spa = GameStatus.skillSet["shadow_ball"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-(attacker.get_attack()+spa)) # No crit or miss, should dela normal damage
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]


func test_combat_round_flaming_daggers():
	test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 4, "flaming_daggers")
	
	var spa = GameStatus.skillSet["flaming_daggers"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-(attacker.get_attack()+spa)) # No crit or miss, should dela normal damage

	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	
	
func test_combat_round_nero_nero():
	test_combat.combat_round([2, 100, 100, 0], [1, 1, 1, 100], 0, 4, "nero_nero") # double roll, double 100 to hit (cant hit) 0 to crit (always crit) but shouldnt deal 1.5 damage since it doesnt check for crits
	
	var spa = GameStatus.skillSet["nero_nero"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-(attacker.get_attack()+spa)) # Should deal normal dmg despite the previous pre and crit

	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	
	
func test_combat_round_boost1():
	test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 1, "boost_1")
	
	var spa = GameStatus.skillSet["boost_1"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-(attacker.get_attack()+spa-defender.get_defense()))
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	
	
func test_combat_round_boost1_acc_crit():
	var barelyHit: int = 65+attacker.get_dexterity()*5-defender.get_agility()*3 # = 80% as of writing this test 50 base 15 boosted acc 45 from dex - 30 enemy agi cast to int to avoid inconsistencies
	var barelyCrit: int = 3+attacker.get_agility()+attacker.get_dexterity()-defender.get_agility()/2 # = 3+17-10/2 => 20-5 => 15% cast to int to avoid, inconsistencies regular formulae +3 for boost lv1
	
	test_combat.combat_round([1, barelyHit, barelyCrit, 0], [1, 1, 1, 100], 0, 1, "boost_1") #base hit chance is 65% 80 should miss, however due to boost actual acc is 80 base crit chance is
	
	var spa = GameStatus.skillSet["boost_1"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-int((attacker.get_attack()+spa-defender.get_defense())*1.5))
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	
	
func test_combat_round_boost1_miss():
	var barelyMiss: int = 66+attacker.get_dexterity()*5-defender.get_agility()*3 # = same chance as last test, setting 1 higher on the roll to make sure the hit chance is working properly
	
	test_combat.combat_round([1, barelyMiss, 1, 100], [1, 1, 1, 100], 0, 1, "boost_1") #boost_1 hit chance is 80% 81 should miss
	
	var spa = GameStatus.skillSet["boost_1"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health())
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]


func test_combat_round_boost1_not_crit():
	var barelyNotCrit: int = 4+attacker.get_agility()+attacker.get_dexterity()-defender.get_agility()/2 # = 3+17-10/2 => 20-5 => 15% cast to int to avoid inconsistencies, regular formulae +3 for boost lv1

	test_combat.combat_round([1, 1, 1, barelyNotCrit], [1, 1, 1, 100], 0, 1, "boost_1") #boost_1 crit chance is 20% 21 should miss

	var spa = GameStatus.skillSet["boost_1"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-(attacker.get_attack()+spa-defender.get_defense()))
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	
	
func test_combat_round_boost2():
	test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 1, "boost_2")
	
	var spa = GameStatus.skillSet["boost_2"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-(attacker.get_attack()+spa))
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	
	
func test_combat_round_boost2_acc_crit():
	var barelyHit: int = 80+attacker.get_dexterity()*5-defender.get_agility()*3 # = 95% as of writing this test 50 base 30 boosted acc 45 from dex - 30 enemy agi cast to int to avoid inconsistencies
	var barelyCrit: int = 6+attacker.get_agility()+attacker.get_dexterity()-defender.get_agility()/2 # = 6+17-10/2 => 23-5 => 18% cast to int to avoid, inconsistencies regular formulae +3 for boost lv1
	
	test_combat.combat_round([1, barelyHit, barelyCrit, 0], [1, 1, 1, 100], 0, 1, "boost_2") #base hit chance is 65% 95 should miss, however due to boost actual acc is 80 base crit chance is
	
	var spa = GameStatus.skillSet["boost_2"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-int((attacker.get_attack()+spa)*1.5))
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	
	
func test_combat_round_boost2_miss():
	var barelyMiss: int = 81+attacker.get_dexterity()*5-defender.get_agility()*3 # = same chance as last test, setting 1 higher on the roll to make sure the hit chance is working properly
	
	test_combat.combat_round([1, barelyMiss, 1, 100], [1, 1, 1, 100], 0, 1, "boost_2") #boost_2 hit chance is 95% 96 should miss
	
	var spa = GameStatus.skillSet["boost_1"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health())
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]


func test_combat_round_boost2_not_crit():
	var barelyNotCrit: int = 7+attacker.get_agility()+attacker.get_dexterity()-defender.get_agility()/2 # = 6+17-10/2 => 23-5 => 18% cast to int to avoid inconsistencies, regular formulae +3 for boost lv1
	
	test_combat.combat_round([1, 1, 1, barelyNotCrit], [1, 1, 1, 100], 0, 1, "boost_2") #boost_2 crit chance is 23% 24 should miss
	
	var spa = GameStatus.skillSet["boost_2"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-(attacker.get_attack()+spa))
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	
	
func test_combat_round_anchoring_strike():
	await test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 1, "anchoring_strike")
	
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-attacker.get_attack()+defender.get_defense())
	assert_bool(defender.is_rooted()).is_true()
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	defender.get_stats()["is_rooted"] = false
	
	
func test_combat_round_anchoring_strike_miss():
	await test_combat.combat_round([1, 100, 1, 100], [1, 1, 1, 100], 0, 1, "anchoring_strike")
	
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health())
	assert_bool(defender.is_rooted()).is_false()
	
	
func test_combat_round_anchoring_strike_dead_target():
	await defender.modify_health(-defender.get_max_health()+1)
	await test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 1, "anchoring_strike")
	
	assert_int(defender.get_current_health()).is_equal(0)
	assert_bool(defender.is_rooted()).is_false()
	
	
#func test_combat_round_bestow_life():
	#CombatMapStatus.set_active_characters(attacker.get_stats(), ally.get_stats())
	#test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 4, "bestow_life")
	#var spa = GameStatus.skillSet["bestow_life"].get_spa()
	#assert_int(ally.get_current_health()).is_equal(ally.get_max_health()-25+(attacker.get_attack()+spa))
#
#func test_combat_round_creators_touch():
	#CombatMapStatus.set_active_characters(attacker.get_stats(), ally.get_stats())
	#test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 1, "creators_touch")
	#var spa = GameStatus.skillSet["creators_touch"].get_spa()
	#assert_int(ally.get_current_health()).is_equal(ally.get_max_health()-25+(attacker.get_attack()+spa))
#
#func test_combat_round_mend_flesh():
	#CombatMapStatus.set_active_characters(attacker.get_stats(), ally.get_stats())
	#test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, , "mend_flesh")
	#var spa = GameStatus.skillSet["mend_flesh"].get_spa()
	#assert_int(ally.get_current_health()).is_equal(ally.get_max_health()-25+(attacker.get_attack()+spa))

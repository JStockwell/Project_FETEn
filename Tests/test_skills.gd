extends GdUnitTestSuite

var Character = preload("res://Scenes/Entities/character.tscn")
var Combat = preload("res://Scenes/3D/combat.tscn")
#var Mapcombat = preload("res://Scenes/3D/mapCombat.tscn")

var test_players = Utils.read_json("res://Assets/json/test_players.json")
var test_enemies = Utils.read_json("res://Assets/json/test_enemies.json")
var test_skillSet = Utils.read_json("res://Assets/json/skills.json")

var attacker
var defender
var ally
var combat 
#var mapcombat

var stats_atk
var stats_def
var stats_ally

func before():
	GameStatus.testMode = true

func before_test():
	attacker = Character.instantiate()
	add_child(attacker)
	defender = Character.instantiate()
	add_child(defender)
	ally = Character.instantiate()
	add_child(ally)
	
	var i = 0
	for test_skillName in test_skillSet:
		GameStatus.skillSet[test_skillName] = Factory.Skill.create(test_skillSet[test_skillName])
		GameStatus.skillSet[test_skillName].set_skill_menu_id(i)
		i += 1
	
	stats_atk = test_players["attacker_skillTests"]
	stats_ally = test_players["ally_skillTests"]
	stats_def = test_enemies["defender_skillTests"]
	
	attacker = Factory.Character.create(stats_atk, false)
	defender = Factory.Character.create(stats_def, false)
	ally = Factory.Character.create(stats_ally, false)
	CombatMapStatus.set_active_characters(attacker.get_stats(), defender.get_stats())
	GameStatus.set_autorun_combat(false)
	
	#mapcombat = Mapcombat.instantiate()
	#add_child(mapcombat)
	
	combat = Combat.instantiate()
	add_child(combat)
	
	
func after_test():
	attacker.free()
	defender.free()
	ally.free()
	combat.free()
	#mapcombat.free()
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
	assert_that(combat).is_not_null()

	
#####################
# Integration Tests #
#####################

func test_combat_round_shadow_ball():
	CombatMapStatus.attackRange = 4
	CombatMapStatus.set_attack_skill("shadow_ball")
	
	combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100])
	
	var spa = GameStatus.skillSet["shadow_ball"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-(attacker.get_attack()+spa)) # No crit or miss, should dela normal damage
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]


func test_combat_round_flaming_daggers():
	CombatMapStatus.attackRange = 4
	CombatMapStatus.set_attack_skill("flaming_daggers")
	
	combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100])
	
	var spa = GameStatus.skillSet["flaming_daggers"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-(attacker.get_attack()+spa)) # No crit or miss, should dela normal damage

	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	
	
func test_combat_round_nero_nero():
	CombatMapStatus.attackRange = 4
	CombatMapStatus.set_attack_skill("nero_nero")
	
	combat.combat_round([2, 100, 100, 0], [1, 1, 1, 100]) # double roll, double 100 to hit (cant hit) 0 to crit (always crit) but shouldnt deal 1.5 damage since it doesnt check for crits
	
	var spa = GameStatus.skillSet["nero_nero"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-(attacker.get_attack()+spa)) # Should deal normal dmg despite the previous pre and crit

	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	

func test_combat_round_boost1():
	CombatMapStatus.attackRange = 1
	CombatMapStatus.set_attack_skill("boost_1")
	
	combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100])
	
	var spa = GameStatus.skillSet["boost_1"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-(attacker.get_attack()+spa-defender.get_defense()))
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	
	
func test_combat_round_boost1_acc_crit():
	CombatMapStatus.attackRange = 1
	CombatMapStatus.set_attack_skill("boost_1")
	var barelyHit: int = 65+attacker.get_dexterity()*5-defender.get_agility()*3 # = 80% as of writing this test 50 base 15 boosted acc 45 from dex - 30 enemy agi cast to int to avoid inconsistencies
	var barelyCrit: int = 3+attacker.get_agility()+attacker.get_dexterity()-defender.get_agility()/2 # = 3+17-10/2 => 20-5 => 15% cast to int to avoid, inconsistencies regular formulae +3 for boost lv1
	
	combat.combat_round([1, barelyHit, barelyCrit, 0], [1, 1, 1, 100]) #base hit chance is 65% 80 should miss, however due to boost actual acc is 80 base crit chance is
	
	var spa = GameStatus.skillSet["boost_1"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-int((attacker.get_attack()+spa-defender.get_defense())*1.5))
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	

func test_combat_round_boost1_miss():
	CombatMapStatus.attackRange = 1
	CombatMapStatus.set_attack_skill("boost_1")
	var barelyMiss: int = 66+attacker.get_dexterity()*5-defender.get_agility()*3 # = same chance as last test, setting 1 higher on the roll to make sure the hit chance is working properly
	
	combat.combat_round([1, barelyMiss, 1, 100], [1, 1, 1, 100]) #boost_1 hit chance is 80% 81 should miss
	
	var spa = GameStatus.skillSet["boost_1"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health())
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]


func test_combat_round_boost1_not_crit():
	CombatMapStatus.attackRange = 1
	CombatMapStatus.set_attack_skill("boost_1")
	var barelyNotCrit: int = 4+attacker.get_agility()+attacker.get_dexterity()-defender.get_agility()/2 # = 3+17-10/2 => 20-5 => 15% cast to int to avoid inconsistencies, regular formulae +3 for boost lv1

	combat.combat_round([1, 1, 1, barelyNotCrit], [1, 1, 1, 100]) #boost_1 crit chance is 20% 21 should miss

	var spa = GameStatus.skillSet["boost_1"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-(attacker.get_attack()+spa-defender.get_defense()))
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	
	
func test_combat_round_boost2():
	CombatMapStatus.attackRange = 1
	CombatMapStatus.set_attack_skill("boost_2")
	
	combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100])
	
	var spa = GameStatus.skillSet["boost_2"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-(attacker.get_attack()+spa))
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	

func test_combat_round_boost2_acc_crit():
	CombatMapStatus.attackRange = 1
	CombatMapStatus.set_attack_skill("boost_2")
	var barelyHit: int = 80+attacker.get_dexterity()*5-defender.get_agility()*3 # = 95% as of writing this test 50 base 30 boosted acc 45 from dex - 30 enemy agi cast to int to avoid inconsistencies
	var barelyCrit: int = 6+attacker.get_agility()+attacker.get_dexterity()-defender.get_agility()/2 # = 6+17-10/2 => 23-5 => 18% cast to int to avoid, inconsistencies regular formulae +3 for boost lv1
	
	combat.combat_round([1, barelyHit, barelyCrit, 0], [1, 1, 1, 100]) #base hit chance is 65% 95 should miss, however due to boost actual acc is 80 base crit chance is
	
	var spa = GameStatus.skillSet["boost_2"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-int((attacker.get_attack()+spa)*1.5))
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	


func test_combat_round_boost2_miss():
	CombatMapStatus.attackRange = 1
	CombatMapStatus.set_attack_skill("boost_2")
	var barelyMiss: int = 81+attacker.get_dexterity()*5-defender.get_agility()*3 # = same chance as last test, setting 1 higher on the roll to make sure the hit chance is working properly
	
	combat.combat_round([1, barelyMiss, 1, 100], [1, 1, 1, 100]) #boost_2 hit chance is 95% 96 should miss
	
	var spa = GameStatus.skillSet["boost_1"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health())
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]


func test_combat_round_boost2_not_crit():
	CombatMapStatus.attackRange = 1
	CombatMapStatus.set_attack_skill("boost_2")
	var barelyNotCrit: int = 7+attacker.get_agility()+attacker.get_dexterity()-defender.get_agility()/2 # = 6+17-10/2 => 23-5 => 18% cast to int to avoid inconsistencies, regular formulae +3 for boost lv1
	
	combat.combat_round([1, 1, 1, barelyNotCrit], [1, 1, 1, 100]) #boost_2 crit chance is 23% 24 should miss
	
	var spa = GameStatus.skillSet["boost_2"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-(attacker.get_attack()+spa))
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	
	
func test_combat_round_anchoring_strike():
	CombatMapStatus.attackRange = 1
	CombatMapStatus.set_attack_skill("anchoring_strike")
	await combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100])
	
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-attacker.get_attack()+defender.get_defense())
	assert_bool(defender.is_rooted()).is_true()
	
	defender.get_stats()["current_health"] = defender.get_stats()["max_health"]
	defender.get_stats()["is_rooted"] = false
	
	
func test_combat_round_anchoring_strike_miss():
	CombatMapStatus.attackRange = 1
	CombatMapStatus.set_attack_skill("anchoring_strike")
	
	await combat.combat_round([1, 100, 1, 100], [1, 1, 1, 100])
	
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health())
	assert_bool(defender.is_rooted()).is_false()
	
	
func test_combat_round_anchoring_strike_dead_target():
	CombatMapStatus.attackRange = 1
	CombatMapStatus.set_attack_skill("anchoring_strike")
	
	await defender.modify_health(-defender.get_max_health()+1)
	await combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100])
	
	assert_int(defender.get_current_health()).is_equal(0)
	assert_bool(defender.is_rooted()).is_false()
	
	
func test_combat_round_bestow_life_myself():
	attacker.get_stats()["current_health"] = 1
	
	var skill_name = "bestow_life"
	var spa = GameStatus.skillSet[skill_name]["spa"]
	var should_heal = attacker.get_attack() + spa
	var magic_number_heal = 14
	
	SEF.run_out_of_combat(skill_name, attacker, attacker, spa)
	
	assert_int(attacker.get_current_health()).is_equal(1 + should_heal)
	assert_int(attacker.get_current_health()).is_equal(1 + magic_number_heal)
	
	
	attacker.get_stats()["current_health"] = attacker.get_stats()["max_health"]
	attacker.get_stats()["healing_threshold"] = 30
	
	
func test_combat_round_bestow_life_ally():
	ally.get_stats()["current_health"] = 1
	
	var skill_name = "bestow_life"
	var spa = GameStatus.skillSet[skill_name]["spa"]
	var should_heal = attacker.get_attack() + spa
	var magic_number_heal = 14
	
	SEF.run_out_of_combat(skill_name, attacker, ally, spa)
	
	assert_int(ally.get_current_health()).is_equal(1 + should_heal)
	assert_int(ally.get_current_health()).is_equal(1 + magic_number_heal)
	
	ally.get_stats()["current_health"] = ally.get_stats()["max_health"]
	ally.get_stats()["healing_threshold"] = 30
	
	
func test_combat_round_bestow_life_limited_threshold():
	attacker.get_stats()["current_health"] = 1
	attacker.get_stats()["healing_threshold"] = 1
	
	var skill_name = "bestow_life"
	var spa = GameStatus.skillSet[skill_name]["spa"]
	var magic_number_heal = 1
	
	SEF.run_out_of_combat(skill_name, attacker, attacker, spa)
	
	assert_int(attacker.get_current_health()).is_equal(1 + magic_number_heal)
	
	attacker.get_stats()["current_health"] = attacker.get_stats()["max_health"]
	attacker.get_stats()["healing_threshold"] = 30
	
	
func test_combat_round_bestow_life_no_threshold():
	attacker.get_stats()["current_health"] = 1
	attacker.get_stats()["healing_threshold"] = 0
	
	var skill_name = "bestow_life"
	var spa = GameStatus.skillSet[skill_name]["spa"]
	
	SEF.run_out_of_combat(skill_name, attacker, attacker, spa)
	
	assert_int(attacker.get_current_health()).is_equal(1)
	
	attacker.get_stats()["current_health"] = attacker.get_stats()["max_health"]
	attacker.get_stats()["healing_threshold"] = 30
	

func test_combat_round_creators_touch_myself():
	attacker.get_stats()["current_health"] = 1
	
	var skill_name = "creators_touch"
	var spa = GameStatus.skillSet[skill_name]["spa"]
	var should_heal = attacker.get_attack() + spa
	var magic_number_heal = 21
	
	SEF.run_out_of_combat(skill_name, attacker, attacker, spa)
	
	assert_int(attacker.get_current_health()).is_equal(1 + should_heal)
	assert_int(attacker.get_current_health()).is_equal(1 + magic_number_heal)
	
	
	attacker.get_stats()["current_health"] = attacker.get_stats()["max_health"]
	attacker.get_stats()["healing_threshold"] = 30
	
	
func test_combat_round_creators_touch_ally():
	ally.get_stats()["current_health"] = 1
	
	var skill_name = "creators_touch"
	var spa = GameStatus.skillSet[skill_name]["spa"]
	var should_heal = attacker.get_attack() + spa
	var magic_number_heal = 21
	
	SEF.run_out_of_combat(skill_name, attacker, ally, spa)
	
	assert_int(ally.get_current_health()).is_equal(1 + should_heal)
	assert_int(ally.get_current_health()).is_equal(1 + magic_number_heal)
	
	ally.get_stats()["current_health"] = ally.get_stats()["max_health"]
	ally.get_stats()["healing_threshold"] = 30
	
	
func test_combat_round_creators_touch_limited_threshold():
	attacker.get_stats()["current_health"] = 1
	attacker.get_stats()["healing_threshold"] = 1
	
	var skill_name = "creators_touch"
	var spa = GameStatus.skillSet[skill_name]["spa"]
	var magic_number_heal = 1
	
	SEF.run_out_of_combat(skill_name, attacker, attacker, spa)
	
	assert_int(attacker.get_current_health()).is_equal(1 + magic_number_heal)
	
	attacker.get_stats()["current_health"] = attacker.get_stats()["max_health"]
	attacker.get_stats()["healing_threshold"] = 30
	
	
func test_combat_round_creators_touch_no_threshold():
	attacker.get_stats()["current_health"] = 1
	attacker.get_stats()["healing_threshold"] = 0
	
	var skill_name = "creators_touch"
	var spa = GameStatus.skillSet[skill_name]["spa"]
	
	SEF.run_out_of_combat(skill_name, attacker, attacker, spa)
	
	assert_int(attacker.get_current_health()).is_equal(1)
	
	attacker.get_stats()["current_health"] = attacker.get_stats()["max_health"]
	attacker.get_stats()["healing_threshold"] = 30
	
	
func test_combat_round_mend_flesh_myself():
	attacker.get_stats()["current_health"] = 1
	
	var skill_name = "mend_flesh"
	var spa = GameStatus.skillSet[skill_name]["spa"]
	var should_heal = attacker.get_attack() + spa
	var magic_number_heal = 18
	
	SEF.run_out_of_combat(skill_name, attacker, attacker, spa)
	
	assert_int(attacker.get_current_health()).is_equal(1 + should_heal)
	assert_int(attacker.get_current_health()).is_equal(1 + magic_number_heal)
	
	
	attacker.get_stats()["current_health"] = attacker.get_stats()["max_health"]
	attacker.get_stats()["healing_threshold"] = 30
	
	
func test_combat_round_mend_flesh_ally():
	ally.get_stats()["current_health"] = 1
	
	var skill_name = "mend_flesh"
	var spa = GameStatus.skillSet[skill_name]["spa"]
	var should_heal = attacker.get_attack() + spa
	var magic_number_heal = 18
	
	SEF.run_out_of_combat(skill_name, attacker, ally, spa)
	
	assert_int(ally.get_current_health()).is_equal(1 + should_heal)
	assert_int(ally.get_current_health()).is_equal(1 + magic_number_heal)
	
	ally.get_stats()["current_health"] = ally.get_stats()["max_health"]
	ally.get_stats()["healing_threshold"] = 30
	
	
func test_combat_round_mend_flesh_limited_threshold():
	attacker.get_stats()["current_health"] = 1
	attacker.get_stats()["healing_threshold"] = 1
	
	var skill_name = "mend_flesh"
	var spa = GameStatus.skillSet[skill_name]["spa"]
	var magic_number_heal = 1
	
	SEF.run_out_of_combat(skill_name, attacker, attacker, spa)
	
	assert_int(attacker.get_current_health()).is_equal(1 + magic_number_heal)
	
	attacker.get_stats()["current_health"] = attacker.get_stats()["max_health"]
	attacker.get_stats()["healing_threshold"] = 30
	
	
func test_combat_round_mend_flesh_no_threshold():
	attacker.get_stats()["current_health"] = 1
	attacker.get_stats()["healing_threshold"] = 0
	
	var skill_name = "mend_flesh"
	var spa = GameStatus.skillSet[skill_name]["spa"]
	
	SEF.run_out_of_combat(skill_name, attacker, attacker, spa)
	
	assert_int(attacker.get_current_health()).is_equal(1)
	
	attacker.get_stats()["current_health"] = attacker.get_stats()["max_health"]
	attacker.get_stats()["healing_threshold"] = 30

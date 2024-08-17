extends GdUnitTestSuite

var Character = preload("res://Scenes/Entities/character.tscn")
var Combat = preload("res://Scenes/3D/combat.tscn")
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
		"mesh_path": "res://Assets/Characters/Placeholder/Placeholder_Char.glb",
		"current_health": 24,
		"current_mana": 5,
		"is_enemy": false,
		"map_id": 0
	}


	stats_def = {
		"name": "Defender",
		"max_health": 22,
		"attack": 14,
		"dexterity": 10,
		"defense": 6,
		"agility": 8,
		"movement": 5,
		"ini_mana": 5,
		"max_mana": 20,
		"reg_mana": 5,
		"range": 4,
		"skills": [], # GameStatus.get_ability_by_id("SKILL_ID_1") -> instance ability.gd
		"is_ranged": false,
		"mesh_path": "res://Assets/Characters/Placeholder/Placeholder_Char.glb",
		"current_health": 22,
		"current_mana": 5,
		"is_enemy": true,
		"map_id": 2
	}
	
	attacker = Factory.Character.create(stats_atk)
	defender = Factory.Character.create(stats_def)
	ally = Factory.Character.create(stats_ally)
	CombatMapStatus.set_active_characters(attacker.get_stats(), defender.get_stats())
	GameStatus.set_autorun_combat(false)
	
	test_combat = Combat.instantiate()
	add_child(test_combat)
	ally.modify_health(-25)
	
	
func after_test():
	attacker.free()
	defender.free()
	ally.free()
	test_combat.free()
	for test_skill in GameStatus.skillSet:
		GameStatus.skillSet[test_skill].free()


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
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-(attacker.get_attack()+spa))

func test_combat_round_flaming_daggers():
	test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 4, "flaming_daggers")
	var spa = GameStatus.skillSet["flaming_daggers"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-(attacker.get_attack()+spa))

func test_combat_round_nero_nero():
	test_combat.combat_round([2, 100, 100, 0], [1, 1, 1, 100], 0, 4, "nero_nero") # double roll, double 100 to hit (cant hit) 0 to crit (always crit) but shouldnt deal 1.5 damage since it doesnt check for crits
	var spa = GameStatus.skillSet["nero_nero"].get_spa()
	assert_int(defender.get_current_health()).is_equal(defender.get_max_health()-(attacker.get_attack()+spa))

#func test_combat_round_bestow_life():
	#CombatMapStatus.set_active_characters(attacker.get_stats(), ally.get_stats())
	#test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 4, "bestow_life")
	#var spa = GameStatus.skillSet["bestow_life"].get_spa()
	#assert_int(ally.get_current_health()).is_equal(ally.get_max_health()-25+(attacker.get_attack()+spa))


#func test_combat_round_creators_touch():
	#CombatMapStatus.set_active_characters(attacker.get_stats(), ally.get_stats())
	#test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 1, "creators_touch")
	#var spa = GameStatus.skillSet["creators_touch"].get_spa()
	#assert_int(ally.get_current_health()).is_equal(ally.get_max_health()-25+(attacker.get_attack()+spa))

	
#func test_combat_round_mend_flesh():
	#CombatMapStatus.set_active_characters(attacker.get_stats(), ally.get_stats())
	#test_combat.combat_round([1, 1, 1, 100], [1, 1, 1, 100], 0, 1, "mend_flesh")
	#var spa = GameStatus.skillSet["mend_flesh"].get_spa()
	#assert_int(ally.get_current_health()).is_equal(ally.get_max_health()-25+(attacker.get_attack()+spa))

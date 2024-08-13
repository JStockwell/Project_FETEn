extends GdUnitTestSuite

#var Character = preload("res://Scripts/Entities/character.gd")
var Character = preload("res://Scenes/Entities/character.tscn")
var Factory_Char = load("res://Scripts/Factories/characterFactory.gd")

var test_char
var test_factory_char
var initial_stats
var checker
var max_stats
var dict 

func before_test():
	test_char = Character.instantiate()
	add_child(test_char)
	test_factory_char = Factory_Char.new()
	
	initial_stats = {
		"name": "Player1",
		"max_health": 24,
		"attack": 16,
		"dexterity": 16,
		"defense": 6,
		"agility": 7,
		"movement": 5,
		"ini_mana": 5,
		"max_mana": 20,
		"reg_mana": 5,
		"range": 4,
		"skills": ["SKILL_ID_1", "SKILL_ID_2"], # GameStatus.get_ability_by_id("SKILL_ID_1") -> instance ability.gd
		"is_ranged": false,
		"mesh_path": "res://Assets/Characters/Placeholder/Placeholder_Char.glb"
	}
	
	max_stats = {
		"name": "Player1",
		"max_health": 24,
		"attack": 16,
		"dexterity": 16,
		"defense": 6,
		"agility": 7,
		"movement": 5,
		"ini_mana": 5,
		"max_mana": 20,
		"reg_mana": 5,
		"range": 4,
		"skills": ["SKILL_ID_1", "SKILL_ID_2"], # GameStatus.get_ability_by_id("SKILL_ID_1") -> instance ability.gd
		"is_ranged": false,
		"mesh_path": "res://Assets/Characters/Placeholder/Placeholder_Char.glb",
		"current_health": 24,
		"current_mana": 5
	}
	
	test_char = test_factory_char.create(initial_stats)
	
	
func after_test():
	test_char.free()
	
##############
# Unit Tests #
##############
func test_not_null():
	assert_that(test_char).is_not_null()
	assert_that(test_factory_char).is_not_null()
	
func test_character_factory():
	#Function called in before_test()
	
	assert_that(test_char.get_stats()).is_equal(max_stats)
	
func test_set_stats():
	var current_stats = {
		"current_health": 12,
		"current_mana": 8
	}
	max_stats.merge(current_stats, true)
	
	test_char.set_stats(max_stats)
	checker = test_char.get_stats()
	
	assert_that(max_stats).is_equal(checker)
	
func test_cap_current_stats_max():
	dict = {
		"current_health": test_char.get_stats().get("max_health") + 1,
		"current_mana": test_char.get_stats().get("max_mana") + 1
	}
	max_stats.merge(dict, true)
	
	checker = test_char.cap_current_stats(max_stats)
	
	assert_that(checker.get("current_health")).is_equal(checker.get("max_health"))
	assert_that(checker.get("current_mana")).is_equal(checker.get("max_mana"))
	

func test_cap_current_stats_no_negatives():
	dict = {
		"current_health": test_char.get_stats().get("max_health") - 8000,
		"current_mana": test_char.get_stats().get("max_mana") - 8000
	}
	max_stats.merge(dict, true)
	
	checker = test_char.cap_current_stats(max_stats)
	
	assert_that(checker.get("current_health")).is_equal(0)
	assert_that(checker.get("current_mana")).is_equal(0)
	
func test_modify_health_damage_non_lethal():
	test_char.modify_health(-1)
	
	assert_that(test_char.get_stats().get("current_health")).is_equal(test_char.get_stats().get("max_health") - 1)
	
func test_modify_health_damage_lethal():
	test_char.modify_health(-8000)
	
	assert_that(test_char.get_stats().get("current_health")).is_equal(0)
	
#TODO Modifica el cambio de la current_health usando un setter cuando se pueda
func test_modify_health_heal_under_cap():
	dict = {
		"current_health": test_char.get_stats().get("max_health") - 2,
	}
	max_stats.merge(dict, true)
	test_char.set_stats(max_stats)
	
	test_char.modify_health(1)
	
	assert_that(test_char.get_stats().get("current_health")).is_equal(test_char.get_stats().get("max_health") - 1)
	

#TODO Modifica el cambio de la current_health usando un setter cuando se pueda
func test_modify_health_heal_over_cap():
	dict = {
		"current_health": test_char.get_stats().get("max_health") - 2,
	}
	max_stats.merge(dict, true)
	test_char.set_stats(max_stats)
	
	test_char.modify_health(8000)
	
	assert_that(test_char.get_stats().get("current_health")).is_equal(test_char.get_stats().get("max_health"))
	

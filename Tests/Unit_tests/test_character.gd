extends GdUnitTestSuite

var Character = load("res://Scripts/Entities/character.gd")

var test_char
var initial_stats
var checker
var max_stats

# var skills = ["SKILL_1", "SKILL2"] # ???
#var max_stats = {
	#"name": "Player1",
	#"max_health": 24,
	#"attack": 16,
	#"dexterity": 16,
	#"defense": 6,
	#"movement": 5,
	#"ini_mana": 5,
	#"max_mana": 20,
	#"reg_mana": 5,
	#"range": 4,
	#"skills": ["SKILL_ID_1", "SKILL_ID_2"], # GameStatus.get_ability_by_id("SKILL_ID_1") -> instance ability.gd
	#"mesh_path": "res://Assets/Characters/Placeholder/Placeholder_Char.glb",
	#"current_health": 24,
	#"current_mana": 5
#}

func before_test():
	test_char = Character.new()
	
	initial_stats = {
		"name": "Player1",
		"max_health": 24,
		"attack": 16,
		"dexterity": 16,
		"defense": 6,
		"movement": 5,
		"ini_mana": 5,
		"max_mana": 20,
		"reg_mana": 5,
		"range": 4,
		"skills": ["SKILL_ID_1", "SKILL_ID_2"], # GameStatus.get_ability_by_id("SKILL_ID_1") -> instance ability.gd
		"mesh_path": "res://Assets/Characters/Placeholder/Placeholder_Char.glb"
	}
	
	max_stats = {
		"name": "Player1",
		"max_health": 24,
		"attack": 16,
		"dexterity": 16,
		"defense": 6,
		"movement": 5,
		"ini_mana": 5,
		"max_mana": 20,
		"reg_mana": 5,
		"range": 4,
		"skills": ["SKILL_ID_1", "SKILL_ID_2"], # GameStatus.get_ability_by_id("SKILL_ID_1") -> instance ability.gd
		"mesh_path": "res://Assets/Characters/Placeholder/Placeholder_Char.glb",
		"current_health": 24,
		"current_mana": 5
	}
	
	
func after_test():
	test_char.free()
	
# --------- Unit Tests --------- #
func test_not_null():
	assert_that(test_char).is_not_null()
	
	
func test_set_initial_stats():
	test_char.set_initial_stats(initial_stats)
	
	checker = test_char.get_stats()
	
	assert_that(max_stats).is_equal(checker)


func test_set_initial_variable_stats():
	var temp_stats = initial_stats
	test_char.set_initial_stats(temp_stats)
	
	var initial_current_stats = {
		"current_health": test_char.get_stats().get("max_health"),
		"current_mana": test_char.get_stats().get("ini_mana")
	}
	
	checker = test_char.get_stats()
	
	for stat in initial_current_stats:
		temp_stats[stat] = initial_current_stats[stat]
	
	assert_that(temp_stats).is_equal(checker)
	
	
func test_set_stats():
	test_char.set_initial_stats(initial_stats)
	
	var current_stats = {
		"current_health": 12,
		"current_mana": 8
	}
	
	initial_stats.merge(current_stats)
	
	test_char.set_stats(current_stats)
	
	checker = test_char.get_stats()
	
	assert_that(initial_stats).is_equal(checker)
	
	
func test_cap_current_stats_max():
	test_char.set_initial_stats(initial_stats)
	test_char.set_stats(max_stats)
	
	var dict = {
		"current_health": test_char.get_stats().get("max_health") + 1,
		"current_mana": test_char.get_stats().get("max_mana") + 1
	}
	
	max_stats.merge(dict, true)
	
	var checker = test_char.cap_current_stats(max_stats)
	
	assert_that(checker.get("current_health")).is_equal(checker.get("max_health"))
	assert_that(checker.get("current_mana")).is_equal(checker.get("max_mana"))
	

func test_cap_current_stats_no_negatives():
	test_char.set_initial_stats(initial_stats)
	test_char.set_stats(max_stats)
	
	var dict = {
		"current_health": test_char.get_stats().get("max_health") - 8000,
		"current_mana": test_char.get_stats().get("max_mana") - 8000
	}
	
	max_stats.merge(dict, true)
	
	var checker = test_char.cap_current_stats(max_stats)
	
	assert_that(checker.get("current_health")).is_equal(0)
	assert_that(checker.get("current_mana")).is_equal(0)

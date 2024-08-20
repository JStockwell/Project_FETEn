extends GdUnitTestSuite

var Character = preload("res://Scenes/Entities/character.tscn")

var test_char
var initial_stats
var checker
var max_stats
var dict 

func before_test():
	test_char = Character.instantiate()
	add_child(test_char)
	
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
		"is_rooted": false,
		"mesh_path": "res://Assets/Characters/Placeholder/Placeholder_Char.glb",
		"is_enemy": false
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
		"is_rooted": false,
		"mesh_path": "res://Assets/Characters/Placeholder/Placeholder_Char.glb",
		"current_health": 24,
		"current_mana": 5, 
		"is_enemy": false
	}
	
	test_char = Factory.Character.create(initial_stats)
	
	
func after_test():
	test_char.free()
	Utils.reset_all()
	
	
##############
# Unit Tests #
##############

func test_not_null():
	assert_that(test_char).is_not_null()
	
	
func test_character_factory():
	#Function called in before_test()
	assert_that(test_char.get_stats()).is_equal(max_stats)
	
	
func test_set_is_enemy():
	test_char.set_is_enemy(true)
	
	assert_bool(test_char.get_stats().get("is_enemy")).is_true()
	
	
func test_calculate_initiative():
	var random_roll = randi_range(1, 20)
	var no_random_roll = 6
	var checker_ini_random = random_roll + ((test_char.get_agility() + test_char.get_dexterity()) / 2) * 1.1
	var checker_ini_no_random = no_random_roll + ((test_char.get_agility() + test_char.get_dexterity()) / 2) * 1.1
	
	var initiative_random = test_char.calculate_initiative(random_roll)
	var initiative_no_random = test_char.calculate_initiative(no_random_roll)
	
	assert_that(initiative_random).is_equal(checker_ini_random)
	assert_that(initiative_no_random).is_equal(checker_ini_no_random)
	
	
func test_cap_current_stats_max():
	dict = {
		"current_health": test_char.get_max_health() + 1,
		"current_mana": test_char.get_max_mana() + 1
	}
	max_stats.merge(dict, true)
	
	checker = test_char.cap_current_stats(max_stats)
	
	assert_that(checker.get("current_health")).is_equal(checker.get("max_health"))
	assert_that(checker.get("current_mana")).is_equal(checker.get("max_mana"))
	
	
func test_cap_current_stats_no_negatives():
	dict = {
		"current_health": test_char.get_max_health() - 8000,
		"current_mana": test_char.get_max_mana() - 8000
	}
	max_stats.merge(dict, true)
	
	checker = test_char.cap_current_stats(max_stats)
	
	assert_int(checker.get("current_health")).is_zero()
	assert_int(checker.get("current_mana")).is_zero()
	
	
#####################
# Integration Tests #
#####################

func test_set_stats():
	var current_stats = {
		"current_health": 12,
		"current_mana": 8
	}
	max_stats.merge(current_stats, true)
	
	test_char.set_stats(max_stats)
	checker = test_char.get_stats()
	
	assert_that(max_stats).is_equal(checker)


func test_set_map_coords_ok():
	checker = Vector2(3, 3)
	CombatMapStatus.set_map_size(3, 3)
	
	test_char.set_map_coords(checker)
	
	assert_that(test_char.get_stats().get("map_coords")).is_equal(checker)
	
	
func test_set_map_coords_x_out_of_range():
	checker = Vector2(4, 3)
	CombatMapStatus.set_map_size(3, 3)
	
	test_char.set_map_coords(checker)
	
	assert_that(test_char.get_stats().get("map_coords")).is_null()
	
	
func test_set_map_coords_y_out_of_range():
	checker = Vector2(3, 4)
	CombatMapStatus.set_map_size(3, 3)
	
	test_char.set_map_coords(checker)
	
	assert_that(test_char.get_stats().get("map_coords")).is_null()

	
func test_modify_health_damage_non_lethal():
	test_char.modify_health(-1)
	
	assert_that(test_char.get_current_health()).is_equal(test_char.get_max_health() - 1)
	
	
func test_modify_health_damage_lethal():
	test_char.modify_health(-8000)
	
	assert_int(test_char.get_current_health()).is_zero()
	
	
#TODO Modifica el cambio de la current_health usando un setter cuando se pueda
func test_modify_health_heal_under_cap():
	dict = {
		"current_health": test_char.get_max_health() - 2,
	}
	max_stats.merge(dict, true)
	test_char.set_stats(max_stats)
	
	test_char.modify_health(1)
	
	assert_that(test_char.get_current_health()).is_equal(test_char.get_max_health() - 1)
	

#TODO Modifica el cambio de la current_health usando un setter cuando se pueda
func test_modify_health_heal_over_cap():
	dict = {
		"current_health": test_char.get_max_health() - 2,
	}
	max_stats.merge(dict, true)
	test_char.set_stats(max_stats)
	
	test_char.modify_health(8000)
	
	assert_that(test_char.get_current_health()).is_equal(test_char.get_max_health())
	
	
func test_modify_mana_increase_under_cap():
	dict = {
		"current_mana": test_char.get_max_mana() - 2,
	}
	max_stats.merge(dict, true)
	test_char.set_stats(max_stats)
	
	test_char.modify_mana(1)
	
	assert_that(test_char.get_current_mana()).is_equal(test_char.get_max_mana() - 1)


func test_modify_mana_increase_over_cap():
	dict = {
		"current_mana": test_char.get_max_mana() - 2,
	}
	max_stats.merge(dict, true)
	test_char.set_stats(max_stats)
	
	test_char.modify_mana(8000)
	
	assert_that(test_char.get_current_mana()).is_equal(test_char.get_max_mana())
	

func test_modify_mana_decrease_under_cap():
	checker = test_char.get_current_mana()
	
	test_char.modify_mana(-1)
	
	assert_that(test_char.get_current_mana()).is_equal(checker - 1)


func test_modify_mana_decrease_over_cap():
	test_char.modify_mana(-8000)
	
	assert_int(test_char.get_current_mana()).is_zero()

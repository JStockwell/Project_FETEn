extends GdUnitTestSuite

var Character = load("res://Scripts/Entities/character.gd")
var Combat = load("res://Scripts/3D/combat.gd")
var Game_Status = load("res://Scripts/Global/gameStatus.gd")

var attacker
var defender
var test_combat
var game_status

var stats_atk
var stats_def

func before_test():
	attacker = Character.new()
	defender = Character.new()
	test_combat = Combat.new()
	game_status = Game_Status.new()
	
	stats_atk = {
		"name": "Attacker",
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
	
	stats_def = {
		"name": "Defender",
		"max_health": 22,
		"attack": 14,
		"dexterity": 14,
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
		"current_health": 22,
		"current_mana": 5
	}
	
func after_test():
	attacker.free()
	defender.free()
	test_combat.free()
	game_status.free()
	
func test_not_null():
	assert_that(attacker).is_not_null()
	assert_that(defender).is_not_null()
	assert_that(test_combat).is_not_null()
	
func test_init_characters():
	game_status.set_characters(stats_atk, stats_def)
	
	Combat.init_characters()
	
	assert_that(game_status.get_attacker_stats()).is_equal(stats_atk)
	assert_that(game_status.get_defender_stats()).is_equal(stats_def)
	
func test_combat_round():
	pass

func test_attack_physical():
	pass
	
func test_attack_skill():
	pass
	
func test_attack_magic():
	pass
	
func test_attack_miss():
	pass
	
func test_generate_rolls_1_2_and_1_100():
	var dices = test_combat.generate_rolls()
	var dice
	
	for i in range(10):
		for j in range(3):
			dice = dices[j]
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

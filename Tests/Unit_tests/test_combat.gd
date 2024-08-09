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
	GameStatus.set_characters(stats_atk, stats_def)
	
	test_combat.init_characters()
	
	assert_that(GameStatus.get_attacker_stats().get("name")).is_equal(stats_atk.get("name"))
	
#func test_init_characters():
	## Arrange
	#var attacker = Character.new()
	#var defender = Character.new()
	#
	## Act
	#test_combat.init_characters()
	#
	## Assert
	#assert_that(attacker.get_stats()["max_health"]).is_equal_to(stats_atk["max_health"])
	#assert_that(attacker.get_stats()["attack"]).is_equal_to(stats_atk["attack"])
	#assert_that(attacker.get_stats()["dexterity"]).is_equal_to(stats_atk["dexterity"])
	#assert_that(attacker.get_stats()["defense"]).is_equal_to(stats_atk["defense"])
	#assert_that(attacker.get_stats()["agility"]).is_equal_to(stats_atk["agility"])
	#assert_that(attacker.get_stats()["movement"]).is_equal_to(stats_atk["movement"])
	#assert_that(attacker.get_stats()["ini_mana"]).is_equal_to(stats_atk["ini_mana"])
	#assert_that(attacker.get_stats()["max_mana"]).is_equal_to(stats_atk["max_mana"])
	#assert_that(attacker.get_stats()["reg_mana"]).is_equal_to(stats_atk["reg_mana"])
	#assert_that(attacker.get_stats()["range"]).is_equal_to(stats_atk["range"])
	#assert_that(attacker.get_stats()["skills"]).is_equal_to(stats_atk["skills"])
	#assert_that(attacker.get_stats()["is_ranged"]).is_equal_to(stats_atk["is_ranged"])
	#assert_that(attacker.get_stats()["mesh_path"]).is_equal_to(stats_atk["mesh_path"])
	#assert_that(attacker.get_stats()["current_health"]).is_equal_to(stats_atk["current_health"])
	#assert_that(attacker.get_stats()["current_mana"]).is_equal_to(stats_atk["current_mana"])
	#
	#assert_that(defender.get_stats()["max_health"]).is_equal_to(stats_def["max_health"])
	#assert_that(defender.get_stats()["attack"]).is_equal_to(stats_def["attack"])
	#assert_that(defender.get_stats()["dexterity"]).is_equal_to(stats_def["dexterity"])
	#assert_that(defender.get_stats()["defense"]).is_equal_to(stats_def["defense"])
	#assert_that(defender.get_stats()["agility"]).is_equal_to(stats_def["agility"])
	#assert_that(defender.get_stats()["movement"]).is_equal_to(stats_def["movement"])
	#assert_that(defender.get_stats()["ini_mana"]).is_equal_to(stats_def["ini_mana"])
	#assert_that(defender.get_stats()["max_mana"]).is_equal_to(stats_def["max_mana"])
	#assert_that(defender.get_stats()["reg_mana"]).is_equal_to(stats_def["reg_mana"])
	#assert_that(defender.get_stats()["range"]).is_equal_to(stats_def["range"])
	#assert_that(defender.get_stats()["skills"]).is_equal_to(stats_def["skills"])
	#assert_that(defender.get_stats()["is_ranged"]).is_equal_to(stats_def["is_ranged"])
	#assert_that(defender.get_stats()["mesh_path"]).is_equal_to(stats_def["mesh_path"])
	#assert_that(defender.get_stats()["current_health"]).is_equal_to(stats_def["current_health"])
	#assert_that(defender.get_stats()["current_mana"]).is_equal_to(stats_def["current_mana"])
	#
	## Clean up
	#attacker.free()
	#defender.free()
#

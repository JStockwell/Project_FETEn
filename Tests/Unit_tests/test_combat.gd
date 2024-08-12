extends GdUnitTestSuite

#var Character = preload("res://Scripts/Entities/character.gd")
#var Combat = preload("res://Scripts/3D/combat.gd")




@onready
var attacker = $Characters/Attacker
@onready
var defender = $Characters/Defender

#var attacker
#var defender
var test_combat
var game_status

var stats_atk
var stats_def

func before_test():
	var Game_Status = load("res://Scripts/Global/gameStatus.gd")
	var Character = preload("res://Scenes/Entities/character.tscn")
	var Combat = preload("res://Scenes/3D/combat.tscn")
	
	attacker = Character.instantiate()
	defender = Character.instantiate()
	

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
	
	attacker.set_stats(stats_atk)
	defender.set_stats(stats_def)
	GameStatus.set_characters(stats_atk, stats_def)
	Game_Status.set_characters(stats_atk, stats_def)
	game_status.set_characters(stats_atk, stats_def)
	
	test_combat = Combat.instantiate()
	
func after_test():
	attacker.free()
	defender.free()
	test_combat.free()
	#game_status.free()
	
##############
# UNIT TESTS #
##############
func test_not_null():
	assert_that(attacker).is_not_null()
	assert_that(defender).is_not_null()
	assert_that(test_combat).is_not_null()
	
func test_init_characters():
#	init_characters() executed in before_test()
	test_combat.init_characters()
	
	assert_that(GameStatus.get_attacker_stats()).is_equal(stats_atk)
	#assert_that(GameStatus.get_defender_stats()).is_equal(stats_def)
	
#TODO ask llames
func test_combat_round_melee():
	pass
	#Combat.combat_round("melee", [1, 1, 1, 1], [1, 1, 1, 1], 0, "")
	
	#assert_that(game_status.get_attacker_stats().get("current_health")).is_not_equal(game_status.get_attacker_stats().get("max_health"))
	#assert_that(game_status.get_defender_stats().get("current_health")).is_not_equal(game_status.get_defender_stats().get("max_health"))
	
func test_combat_round_ranged():
	pass
	
func test_combat_round_skill_no_SEF():
	pass
	
#	TODO Evalua nero-nero
func test_combat_round_skill_SEF():
	pass
	
func test_attack():
	pass
	
func test_deal_damage():
	pass
	
func test_calc_hit_chance_hit():
	pass
	
func test_calc_hit_chance_no_hit():
	pass
	
#func test_calc_crit():
	#var attack = game_status.get_attacker_stats().get("attack")
	#var defense = game_status.get_defender_stats().get("defense")
	#var test_res = test_combat.calc_damage(attack, defense, 0, 0)
	#
	#pass
	#
#func test_calc_damage_no_magic():
	#var should_dmg = stats_atk.get("attack") - stats_def.get("defense")
	#
	#var attack = game_status.get_attacker_stats().get("attack")
	#var defense = game_status.get_defender_stats().get("defense")
	#var test_res = test_combat.calc_damage(attack, defense, 0, 0)
	#
	#assert_that(test_res).is_equal(should_dmg)
	#
#func test_calc_damage_magic():
	#var should_dmg = stats_atk.get("attack")
	#
	#var attack = game_status.get_attacker_stats().get("attack")
	#var defense = game_status.get_defender_stats().get("defense")
	#var test_res = test_combat.calc_damage(attack, defense, 0, 1)
	#
	#assert_that(test_res).is_equal(should_dmg)
	#
#func test_calc_damage_no_magic_SPA():
	#var should_dmg = stats_atk.get("attack") + 5 - stats_def.get("defense")
	#
	#var attack = game_status.get_attacker_stats().get("attack")
	#var defense = game_status.get_defender_stats().get("defense")
	#var spa = 5
	#var test_res = test_combat.calc_damage(attack, defense, spa, 0)
	#
	#assert_that(test_res).is_equal(should_dmg)
	#
#func test_calc_damage_magic_no_SPA():
	#var should_dmg = stats_atk.get("attack") + 5
	#
	#var attack = game_status.get_attacker_stats().get("attack")
	#var defense = game_status.get_defender_stats().get("defense")
	#var spa = 5
	#var test_res = test_combat.calc_damage(attack, defense, spa, 1)
	#
	#assert_that(test_res).is_equal(should_dmg)
	#
#func test_generate_rolls_1_2_and_1_100():
	#var dices = test_combat.generate_rolls()
	#var dice
	#
	#for  i in range(10):
		#for j in range(3):
			#dice = dices[j]
			#if j == 0:
				#assert_int(dice).is_between(1,2)
			#else:
				#assert_int(dice).is_between(1,100)
	#
#func test_generate_rolls_random():
	#var dices1 = []
	#var dices2 = []
	#
	#for i in range(8000):
		#dices1.append_array(test_combat.generate_rolls())
		#dices2.append_array(test_combat.generate_rolls())
	#
	#assert_that(dices1).is_not_equal(dices2)

extends GdUnitTestSuite

var MapCombat = load("res://Scenes/3D/mapCombat.tscn")

var test_players = Utils.read_json("res://Assets/json/test_players.json")
var test_enemies = Utils.read_json("res://Assets/json/test_enemies.json")
var test_skillSet = Utils.read_json("res://Assets/json/skills.json")

var test_mapCombat
var mapDict

#var stats_atk
#var stats_def

func before():
	GameStatus.debugMode = false

func before_test():
	GameStatus.set_playable_characters(test_players)
	GameStatus.set_enemy_set(test_enemies)
	
	GameStatus.set_party(["attacker"])
	
	CombatMapStatus.set_map_path("res://Assets/json/maps/test_map_1vs1.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	
	var i = 0
	for skillName in test_skillSet:
		GameStatus.skillSet[skillName] = Factory.Skill.create(test_skillSet[skillName])
		GameStatus.skillSet[skillName].set_skill_menu_id(i)
		i += 1
		
	CombatMapStatus.set_is_start_combat(true)
	
	GameStatus.set_autorun_combat(false)
	
	test_mapCombat = MapCombat.instantiate()
	add_child(test_mapCombat)
	
	#test_mapCombat.initial_map_load()
	
func after_test():
	test_mapCombat.free()
	for test_skill in GameStatus.skillSet:
		GameStatus.skillSet[test_skill].free()
	Utils.reset_all()
	

##############
# Unit Tests #
##############

func test_not_null():
	assert_that(test_mapCombat).is_not_null()
	
	
func test_sort_descending_case_a_bigger_b():
	var res = test_mapCombat.sort_descending(2., 1.)
	
	assert_bool(res).is_true()


func test_sort_descending_case_a_less_b():
	var res = test_mapCombat.sort_descending(1., 2.)
	
	assert_bool(res).is_false()


func test_sort_descending_case_a_equal_b():
	var res = test_mapCombat.sort_descending(1., 1.)
	
	assert_bool(res).is_true()


#####################
# Integration Tests #
#####################

func test_initial_map_load():
	#Function called in _ready() of mapCombat
	assert_that(CombatMapStatus.get_map_dimensions()).is_equal(Vector2(3, 3))
	assert_that(CombatMapStatus.get_selected_character()).is_not_null()
	assert_that(GameStatus.get_party()["attacker"]["map_coords"]).is_not_null()
	assert_that(GameStatus.get_party()["attacker"]["map_id"]).is_not_null()
	assert_that(test_mapCombat.enemyGroup.get_children()[0].get_stats()["map_coords"]).is_not_null()
	assert_that(test_mapCombat.enemyGroup.get_children()[0].get_stats()["map_id"]).is_not_null()
	
	
func test_calculate_combat_initiative():
	CombatMapStatus.initiative.clear()
	assert_array(CombatMapStatus.get_initiative()).is_empty()
	
	test_mapCombat.calculate_combat_initiative()
	
	assert_array(CombatMapStatus.get_initiative()).is_not_empty()


func test_setup_skill_menu():
	test_mapCombat.setup_skill_menu()
	var checker
	
	if(CombatMapStatus.get_selected_character().get_char_name() == "Attacker"):
		checker = test_mapCombat.skillMenu.get_item_text(0)
		assert_that(checker).is_equal("Spheres of Darkness")
		checker = test_mapCombat.skillMenu.get_item_text(1)
		assert_that(checker).is_equal("Death Beam")
	if(CombatMapStatus.get_selected_character().get_char_name() == "Defender"):
		checker = test_mapCombat.skillMenu.get_item_count()
		assert_int(checker).is_zero()
	

func test_reset_to_tavern_selected_character_enemy():
	CombatMapStatus.set_selected_character(test_mapCombat.enemyGroup.get_children()[0])
	CombatMapStatus.set_initiative([1,0])
	
	test_mapCombat.reset_to_tavern()
	
	assert_int(CombatMapStatus.get_current_ini()).is_equal(1)


func test_reset_to_tavern_selected_character_ally_has_moved():
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.characterGroup.get_children()[0].get_stats()["hasMoved"] = true
	
	test_mapCombat.reset_to_tavern()
	
	assert_that(CombatMapStatus.get_selected_character()).is_equal(test_mapCombat.characterGroup.get_children()[0])

	test_mapCombat.characterGroup.get_children()[0].get_stats()["hasMoved"] = false


func test_reset_to_tavern_selected_character_ally_has_not_moved():
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.characterGroup.get_children()[0].get_stats()["hasMoved"] = false
	
	test_mapCombat.characterGroup.get_children()[0].get_stats()["movement"] = 1
	
	test_mapCombat.reset_to_tavern()
	
	var tile_10 = test_mapCombat.get_tile_from_coords(Vector2(1, 0)).highlighted.visible
	var tile_01 = test_mapCombat.get_tile_from_coords(Vector2(0, 1)).highlighted.visible
	var tile_11 = test_mapCombat.get_tile_from_coords(Vector2(1, 1)).highlighted.visible
	var tile_21 = test_mapCombat.get_tile_from_coords(Vector2(2, 1)).highlighted.visible
	var tile_12 = test_mapCombat.get_tile_from_coords(Vector2(1, 2)).highlighted.visible
	
	assert_that(CombatMapStatus.get_selected_character()).is_equal(test_mapCombat.characterGroup.get_children()[0])
	assert_bool(tile_10).is_true()
	assert_bool(tile_01).is_true()
	assert_bool(tile_11).is_false()
	assert_bool(tile_21).is_false()
	assert_bool(tile_12).is_false()
	
	test_mapCombat.characterGroup.get_children()[0].get_stats()["movement"] = 5

func test_start_turn_party():
	CombatMapStatus.set_initiative([0,1])
	CombatMapStatus.set_is_start_combat(false)
	assert_that(GameStatus.get_party()["attacker"]["current_mana"]).is_equal(5.)

	test_mapCombat.start_turn()
	
	assert_that(GameStatus.get_party()["attacker"]["current_mana"]).is_equal(10.)
	assert_bool(CombatMapStatus.hasAttacked).is_false()
	assert_that(CombatMapStatus.hasMoved).is_false()
	assert_that(CombatMapStatus.get_selected_character().get_stats()).is_equal(GameStatus.get_party()["attacker"])
	assert_that(test_mapCombat.skillMenu).is_not_null()
	
	
	#TODO Wait Pablo for IA for more testing
func test_start_turn_enemy():
	CombatMapStatus.set_initiative([1,0])
	CombatMapStatus.set_is_start_combat(false)

	test_mapCombat.start_turn()
	
	assert_that(CombatMapStatus.hasAttacked).is_false()
	assert_that(CombatMapStatus.hasMoved).is_false()
	
	
func test_enemy_turn_end(do_skip=true, skip_reason="Waiting for TODO"):
	pass


func test_reset_map_status():
	#Change the map 
	GameStatus.set_party(["attacker", "attacker2"])
	CombatMapStatus.set_map_path("res://Assets/json/maps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	CombatMapStatus.set_initiative([0, 1, 2, 3])
	
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_ally(GameStatus.get_party()["attacker2"])
	CombatMapStatus.set_selected_enemy(test_mapCombat.enemyGroup.get_children()[0])
	CombatMapStatus.set_selected_map_tile(Vector2(1,1))
	assert_that(CombatMapStatus.get_selected_ally()).is_equal(GameStatus.get_party()["attacker2"])
	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(test_mapCombat.enemyGroup.get_children()[0])
	assert_that(CombatMapStatus.get_selected_map_tile()).is_equal(Vector2(1,1))
	assert_that(CombatMapStatus.get_selected_character().get_stats()).is_equal(GameStatus.get_party()["attacker"])
	
	CombatMapStatus.advance_ini()
	test_mapCombat.reset_map_status()
	
	assert_that(CombatMapStatus.get_selected_ally()).is_null()
	assert_that(CombatMapStatus.get_selected_enemy()).is_null()
	assert_that(CombatMapStatus.get_selected_map_tile()).is_null()
	assert_that(CombatMapStatus.get_selected_character().get_stats()).is_equal(GameStatus.get_party()["attacker2"])


func test_regen_mana():
	GameStatus.get_party()["attacker"]["current_mana"] = 5.
	assert_that(GameStatus.get_party()["attacker"]["current_mana"]).is_equal(5.)

	test_mapCombat.regen_mana()
	
	assert_that(GameStatus.get_party()["attacker"]["current_mana"]).is_equal(10.)
	
	
func purge_the_dead(do_skip=true):
	pass


func test_character_handler_enemy_turn():
	CombatMapStatus.set_selected_character(test_mapCombat.enemyGroup.get_children()[0])
	
	test_mapCombat.character_handler(test_mapCombat.characterGroup.get_children()[0])
	
	assert_that(CombatMapStatus.get_selected_ally()).is_null()
	assert_that(CombatMapStatus.get_selected_enemy()).is_null()
	

func test_character_handler_isEnemy_handled():
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	
	test_mapCombat.character_handler(test_mapCombat.enemyGroup.get_children()[0])
	
	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(test_mapCombat.enemyGroup.get_children()[0])
	
	
func test_character_handler_other_ally_turn():
	CombatMapStatus.set_map_path("res://Assets/json/maps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	
	test_mapCombat.character_handler(test_mapCombat.characterGroup.get_children()[1])
	
	assert_that(CombatMapStatus.get_selected_ally()).is_equal(test_mapCombat.characterGroup.get_children()[1])


func test_selected_checker_last_selection_null_enemy():
	CombatMapStatus.set_map_path("res://Assets/json/maps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	
	test_mapCombat.selected_checker(enemy, null, enemy.get_stats()["is_enemy"])
	
	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(enemy)
	

func test_selected_checker_last_selection_null_ally():
	CombatMapStatus.set_map_path("res://Assets/json/maps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	var ally = test_mapCombat.characterGroup.get_children()[1]

	test_mapCombat.selected_checker(ally, null, ally.get_stats()["is_enemy"])
	
	assert_that(CombatMapStatus.get_selected_ally()).is_equal(ally)
	
	
func test_selected_checker_unselect_enemy():
	CombatMapStatus.set_map_path("res://Assets/json/maps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	
	test_mapCombat.selected_checker(enemy, enemy, enemy.get_stats()["is_enemy"])
	
	assert_that(CombatMapStatus.get_selected_enemy()).is_null()
	
	
func test_selected_checker_unselect_ally():
	CombatMapStatus.set_map_path("res://Assets/json/maps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	var ally = test_mapCombat.characterGroup.get_children()[0]
	
	test_mapCombat.selected_checker(ally, ally, ally.get_stats()["is_enemy"])
	
	assert_that(CombatMapStatus.get_selected_ally()).is_null()
	
	
func test_selected_checker_change_selection_enemy():
	CombatMapStatus.set_map_path("res://Assets/json/maps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	var old_enemy = test_mapCombat.enemyGroup.get_children()[0]
	var enemy = test_mapCombat.enemyGroup.get_children()[1]
	
	test_mapCombat.selected_checker(enemy, old_enemy, enemy.get_stats()["is_enemy"])
	
	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(enemy)


func test_selected_checker_change_selection_ally():
	CombatMapStatus.set_map_path("res://Assets/json/maps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	var old_ally = test_mapCombat.characterGroup.get_children()[0]
	var ally = test_mapCombat.characterGroup.get_children()[1]
	
	test_mapCombat.selected_checker(ally, old_ally, ally.get_stats()["is_enemy"])
	
	assert_that(CombatMapStatus.get_selected_ally()).is_equal(ally)


func test_set_selected_character_enemy():
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	test_mapCombat.set_selected_character(enemy, enemy.get_stats()["is_enemy"])
	
	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(enemy)
	
	
func test_set_selected_character_ally():
	var ally = test_mapCombat.characterGroup.get_children()[0]
	test_mapCombat.set_selected_character(ally, ally.get_stats()["is_enemy"])
	
	assert_that(CombatMapStatus.get_selected_ally()).is_equal(ally)


func test_get_tile_from_coords_exist():
	var tile = test_mapCombat.get_tile_from_coords(Vector2(1 ,1))
	
	assert_that(tile.get_variables()["coords"]).is_equal(Vector2(1 ,1))
	assert_int(tile.get_variables()["height"]).is_zero()
	assert_bool(tile.get_variables()["idt"]).is_false()
	assert_bool(tile.get_variables()["isPopulated"]).is_false()
	assert_bool(tile.get_variables()["isTraversable"]).is_true()
	assert_bool(tile.get_variables()["isObstacle"]).is_false()
	
	
func test_get_tile_from_coords_not_exist():
	var tile = test_mapCombat.get_tile_from_coords(Vector2(5 ,5))
	
	assert_that(tile).is_null()

	
func test_set_tile_populated_false_to_true():
	var tile = test_mapCombat.get_tile_from_coords(Vector2(1 ,1))
	assert_bool(tile.get_variables()["isPopulated"]).is_false()
	
	test_mapCombat.set_tile_populated(Vector2(1 ,1), true)
	
	assert_bool(tile.get_variables()["isPopulated"]).is_true()
	
	
func test_set_tile_populated_true_to_false():
	var tile = test_mapCombat.get_tile_from_coords(Vector2(0 ,0))
	assert_bool(tile.get_variables()["isPopulated"]).is_true()
	
	test_mapCombat.set_tile_populated(Vector2(0 ,0), false)
	
	assert_bool(tile.get_variables()["isPopulated"]).is_false()
	

# Set selected MapTile
func test_tile_handler_tile_selected():
	var tile = test_mapCombat.get_tile_from_coords(Vector2(1 ,1))
	CombatMapStatus.set_selected_map_tile(tile)
	
	test_mapCombat.tile_handler(tile)
	
	assert_that(CombatMapStatus.get_selected_map_tile()).is_null()
	
	
func test_tile_handler_tile_not_selected():
	var old_tile = test_mapCombat.get_tile_from_coords(Vector2(1 ,1))
	var new_tile = test_mapCombat.get_tile_from_coords(Vector2(0 ,0))
	CombatMapStatus.set_selected_map_tile(old_tile)
	
	test_mapCombat.tile_handler(new_tile)
	
	assert_that(CombatMapStatus.get_selected_map_tile()).is_not_equal(old_tile)
	assert_that(CombatMapStatus.get_selected_map_tile()).is_equal(new_tile)
	
	
func test_tile_handler_null_selected():
	var tile = test_mapCombat.get_tile_from_coords(Vector2(1 ,1))
	
	test_mapCombat.tile_handler(tile)
	
	assert_that(CombatMapStatus.get_selected_map_tile()).is_equal(tile)

#TODO
func test__on_move_button_pressed(do_skip=true, skip_reason="Waiting for TODOs"):
	assert_that(true).is_equal(true)
	pass
	
#TODO
func test_move_character_validated(do_skip=true, skip_reason="Waiting for TODOs"):
	assert_that(true).is_equal(true)
	pass
	
#TODO
func test_move_character_not_validated(do_skip=true, skip_reason="Waiting for TODOs"):
	assert_that(true).is_equal(true)
	pass
	
# Player movement
#TODO
func test_validate_move(do_skip=true, skip_reason="Waiting for TODOs"):
	assert_that(true).is_equal(true)
	pass
	
	
func test__on_phys_attack_button_pressed():
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	CombatMapStatus.set_selected_enemy(test_mapCombat.enemyGroup.get_children()[0])
	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(2,1)
	
	test_mapCombat._on_phys_attack_button_pressed()
	
	assert_int(CombatMapStatus.mapMod).is_zero()
	assert_that(test_mapCombat.characterGroup.get_children()[0].get_stats()).is_equal(CombatMapStatus.get_attacker_stats())
	assert_that(test_mapCombat.enemyGroup.get_children()[0].get_stats()).is_equal(CombatMapStatus.get_defender_stats())
	
	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(0,0)

func test_phys_combat_round_melee():
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	CombatMapStatus.set_selected_enemy(test_mapCombat.enemyGroup.get_children()[0])
	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(2,1)
	
	test_mapCombat.phys_combat_round()
	
	assert_int(CombatMapStatus.mapMod).is_zero()
	assert_that(test_mapCombat.characterGroup.get_children()[0].get_stats()).is_equal(CombatMapStatus.get_attacker_stats())
	assert_that(test_mapCombat.enemyGroup.get_children()[0].get_stats()).is_equal(CombatMapStatus.get_defender_stats())
	
	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(0,0)
	
	
func test_phys_combat_round_ranged(do_skip=false, skip_reason="Tests under development"):
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	CombatMapStatus.set_selected_enemy(test_mapCombat.enemyGroup.get_children()[0])
	test_mapCombat.characterGroup.get_children()[0].get_stats()["is_ranged"] = true
	
	test_mapCombat.phys_combat_round()
	
	assert_int(CombatMapStatus.mapMod).is_zero()
	assert_that(test_mapCombat.characterGroup.get_children()[0].get_stats()).is_equal(CombatMapStatus.get_attacker_stats())
	assert_that(test_mapCombat.enemyGroup.get_children()[0].get_stats()).is_equal(CombatMapStatus.get_defender_stats())
	
	test_mapCombat.characterGroup.get_children()[0].get_stats()["is_ranged"] = false
	
	
func test_phys_combat_round_ranged_melee(do_skip=false, skip_reason="Tests under development"):
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	CombatMapStatus.set_selected_enemy(test_mapCombat.enemyGroup.get_children()[0])
	test_mapCombat.characterGroup.get_children()[0].get_stats()["is_ranged"] = true
	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(1,2)
	
	test_mapCombat.phys_combat_round()
	
	assert_int(CombatMapStatus.mapMod).is_equal(-25)
	assert_that(test_mapCombat.characterGroup.get_children()[0].get_stats()).is_equal(CombatMapStatus.get_attacker_stats())
	assert_that(test_mapCombat.enemyGroup.get_children()[0].get_stats()).is_equal(CombatMapStatus.get_defender_stats())
	
	test_mapCombat.characterGroup.get_children()[0].get_stats()["is_ranged"] = false
	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(0,0)
	
#TODO
func test__on_skill_selected_targeting_allies(do_skip=true, skip_reason="Waiting for TODOs"):
	assert_that(true).is_equal(true)
	pass
	
	
#TODO
func test__on_skill_selected_targeting_enemies(do_skip=true, skip_reason="Waiting for TODOs"):
	assert_that(true).is_equal(true)
	pass


func test__on_end_turn_button_pressed():
	CombatMapStatus.set_initiative([0, 1])
	assert_that(CombatMapStatus.get_current_ini()).is_equal(0)
	
	test_mapCombat._on_end_turn_button_pressed()
	
	assert_that(CombatMapStatus.get_current_ini()).is_equal(1)
	assert_bool(CombatMapStatus.is_start_combat()).is_false()
	
	
func test_update_buttons(do_skip=true, skip_reason="Waiting for TODOs"):
	assert_that(true).is_equal(true)
	pass
	
func test_update_move_button(do_skip=true, skip_reason="Waiting for TODOs"):
	assert_that(true).is_equal(true)
	pass

func test_update_phys_attack_button_after_attack():
	CombatMapStatus.set_initiative([0, 1])
	CombatMapStatus.set_has_attacked(true)
	
	test_mapCombat.update_phys_attack_button()
	
	assert_bool(test_mapCombat.physAttackButton.disabled).is_true()
	
	
func test_update_phys_attack_button_is_enemy():
	CombatMapStatus.set_initiative([1, 0])

	test_mapCombat.update_phys_attack_button()
	
	assert_bool(test_mapCombat.physAttackButton.disabled).is_true()
	
	
func test_update_phys_attack_button_no_selected_enemy():
	CombatMapStatus.set_initiative([0, 1])
	CombatMapStatus.set_selected_enemy(null)
	
	test_mapCombat.update_phys_attack_button()
	
	assert_bool(test_mapCombat.physAttackButton.disabled).is_true()
	
func test_update_phys_attack_button_enemy_at_range():
	CombatMapStatus.set_initiative([0, 1])
	var ally = test_mapCombat.characterGroup.get_children()[0]
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	CombatMapStatus.set_selected_character(ally)
	CombatMapStatus.set_selected_enemy(enemy)
	
	test_mapCombat.update_phys_attack_button()
	
	assert_bool(test_mapCombat.physAttackButton.disabled).is_false()
	
	
func test_update_phys_attack_button_disabled():
	test_mapCombat.update_phys_attack_button()
	
	assert_bool(test_mapCombat.physAttackButton.disabled).is_true()
	
	
func test_update_skill_menu_button_after_attack():
	CombatMapStatus.set_initiative([0, 1])
	CombatMapStatus.set_has_attacked(true)
	
	test_mapCombat.update_skill_menu_button()
	
	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_true()
	
	
func test_update_skill_menu_button_is_enemy():
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	CombatMapStatus.set_selected_character(enemy)

	test_mapCombat.update_skill_menu_button()
	
	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_true()


func test_update_skill_menu_button_character_has_no_skills():
	CombatMapStatus.set_initiative([0, 1])
	CombatMapStatus.set_current_ini(0)
	test_mapCombat.characterGroup.get_children()[0].get_stats()["skills"] = []
	
	test_mapCombat.update_skill_menu_button()
	
	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_true()
	
	test_mapCombat.characterGroup.get_children()[0].get_stats()["skills"] = ["shadow_ball", "nero_nero"]
	
	
func test_update_skill_menu_button_skills_availables():
	CombatMapStatus.set_initiative([0, 1])
	CombatMapStatus.set_current_ini(0)
	var ally = test_mapCombat.characterGroup.get_children()[0]
	CombatMapStatus.set_selected_character(ally)
	
	test_mapCombat.update_skill_menu_button()
	
	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_false()


func test_update_end_turn_button_is_player():
	CombatMapStatus.set_initiative([0, 1])
	var ally = test_mapCombat.characterGroup.get_children()[0]
	CombatMapStatus.set_selected_character(ally)
	
	test_mapCombat.update_end_turn_button()
	
	assert_bool(test_mapCombat.endTurnButton.disabled).is_false()


func test_update_end_turn_button_is_enemy():
	CombatMapStatus.set_initiative([1, 0])
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	CombatMapStatus.set_selected_character(enemy)
	
	test_mapCombat.update_end_turn_button()
	
	assert_bool(test_mapCombat.endTurnButton.disabled).is_true()


func test_highlight_movement(do_skip=false, skip_reason="Tests under development"):
	test_mapCombat.characterGroup.get_children()[0].get_stats()["movement"] = 1
	#CombatMapStatus.set_initiative([0,1])
	#CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	
	#test_mapCombat.wait(0.5)

	test_mapCombat.highlight_movement(test_mapCombat.characterGroup.get_children()[0])
	
	#test_mapCombat.wait(0.5)
	
	var tile_10 = test_mapCombat.get_tile_from_coords(Vector2(1, 0)).highlighted.visible
	var tile_01 = test_mapCombat.get_tile_from_coords(Vector2(0, 1)).highlighted.visible
	var tile_11 = test_mapCombat.get_tile_from_coords(Vector2(1, 1)).highlighted.visible
	var tile_21 = test_mapCombat.get_tile_from_coords(Vector2(2, 1)).highlighted.visible
	var tile_12 = test_mapCombat.get_tile_from_coords(Vector2(1, 2)).highlighted.visible
	var char = test_mapCombat.characterGroup.get_children()[0]
	
	#test_mapCombat.wait(0.5)

	assert_bool(tile_10).is_true()
	assert_bool(tile_01).is_true()
	assert_bool(tile_11).is_false()
	assert_bool(tile_21).is_false()
	assert_bool(tile_12).is_false()

	test_mapCombat.characterGroup.get_children()[0].get_stats()["movement"] = 5

func test_highlight_control_zones(do_skip=true, skip_reason="Tests under development"):
	assert_that(true).is_equal(true)
	pass
					
func test_check_within_bounds(do_skip=true, skip_reason="Tests under development"):
	assert_that(true).is_equal(true)
	pass

func test_remove_highlights(do_skip=true, skip_reason="Tests under development"):
	assert_that(true).is_equal(true)
	pass

func test_remove_control_zones(do_skip=true, skip_reason="Tests under development"):
	assert_that(true).is_equal(true)
	pass

func test_remove_selected(do_skip=true, skip_reason="Tests under development"):
	assert_that(true).is_equal(true)
	pass
		
func test_remove_char_highlights(do_skip=true, skip_reason="Tests under development"):
	assert_that(true).is_equal(true)
	pass

func test_remove_ally_highlights(do_skip=true, skip_reason="Tests under development"):
	assert_that(true).is_equal(true)
	pass
		
func test_remove_enemy_highlights(do_skip=true, skip_reason="Tests under development"):
	assert_that(true).is_equal(true)
	pass

extends GdUnitTestSuite

var MapCombat = load("res://Scenes/3D/mapCombat.tscn")

var players = Utils.read_json("res://Assets/json/players.json")
var enemies = Utils.read_json("res://Assets/json/enemies.json")
var skillSet = Utils.read_json("res://Assets/json/skills.json")

var mapCombat
var mapDict
var res

var dick
var samael
var lystra
var enemy
var dijkstra

func before():
	GameStatus.debugMode = false
	GameStatus.testMode = true
	
	
func before_test():
	GameStatus.set_playable_characters(players)
	GameStatus.set_enemy_set(enemies)

	GameStatus.set_party(["dick", "samael", "lystra"])

	var i = 0
	for skillName in skillSet:
		GameStatus.skillSet[skillName] = Factory.Skill.create(skillSet[skillName])
		GameStatus.skillSet[skillName].set_skill_menu_id(i)
		i += 1

func after_test():
	for test_skill in GameStatus.skillSet:
		GameStatus.skillSet[test_skill].free()
	if  mapCombat != null:
		mapCombat.free()
	Utils.reset_all()
	
	
func test_not_null():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_goblin_melee.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	assert_that(mapCombat).is_not_null()
	assert_that(dick.get_map_coords()).is_equal(Vector2(0,3))
	assert_that(samael.get_map_coords()).is_equal(Vector2(1,3))
	assert_that(lystra.get_map_coords()).is_equal(Vector2(2,3))
	

# TODO finish
func test_dumb_melee_behavior_possible_targets_isEmpty(do_skip=true, skip_reason="Test fails due to check closest player needs repair"):
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_goblin_melee.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	enemy.get_stats()["movement"] = 0
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	res = EnemyBehavior.dumb_melee_behavior(mapCombat, dijkstra)
	
	assert_bool(res).is_false()
	
	enemy.get_stats()["movement"] = 5
	
# TODO finish
func test_dumb_melee_behavior_ok():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_goblin_melee.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	res = EnemyBehavior.dumb_melee_behavior(mapCombat, dijkstra)
	
	var target = CombatMapStatus.get_selected_enemy()
	assert_that(target).is_not_null()
	assert_that(target.get_map_coords()).is_equal(enemy.get_map_coords() + Vector2.DOWN)
	assert_bool(res).is_true()
	
# TODO finish
func test_smart_melee_behavior_possible_targets_isEmpty(do_skip=true, skip_reason="Test fails due to check closest player needs repair"):
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_melee.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	enemy.get_stats()["movement"] = 0
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	res = EnemyBehavior.smart_melee_behavior(mapCombat, dijkstra)
	
	assert_bool(res).is_false()
	
	enemy.get_stats()["movement"] = 5
	
# TODO finish
func test_smart_melee_behavior_ok():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_melee.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	res = EnemyBehavior.smart_melee_behavior(mapCombat, dijkstra)
	
	var target = CombatMapStatus.get_selected_enemy()
	assert_that(target).is_equal(lystra)
	assert_that(target.get_map_coords()).is_equal(enemy.get_map_coords() + Vector2.DOWN)
	assert_bool(res).is_true()
	

func test_check_players_in_range_isRooted():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_melee.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,0))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	enemy.set_is_rooted(true)
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	res = EnemyBehavior.check_players_in_range(mapCombat, enemy, dijkstra[0])
	
	assert_array(res).contains_exactly([dick])
	
	enemy.set_is_rooted(false)
	
	
func test_check_players_in_range_ok():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_melee.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,0))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	res = EnemyBehavior.check_players_in_range(mapCombat, enemy, dijkstra[0])
	
	assert_array(res).contains_exactly([dick, samael, lystra])


func test_melee_enemy_attack_isRooted():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_melee.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,0))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	enemy.set_is_rooted(true)
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	var possible_targets = EnemyBehavior.check_players_in_range(mapCombat, enemy, dijkstra[0])
	var target = EnemyBehavior.smart_enemy_target_choice(mapCombat, enemy, possible_targets, "")
	
	res = EnemyBehavior.melee_enemy_attack(mapCombat, enemy, target, dijkstra)
	
	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(dick)
	assert_bool(enemy.is_rooted()).is_false()
	assert_bool(res).is_true()
	
	
func test_melee_enemy_attack_no_move_needed():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_melee.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(0,0))
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	var possible_Targets = EnemyBehavior.check_players_in_range(mapCombat, enemy, dijkstra[0])
	var target = EnemyBehavior.smart_enemy_target_choice(mapCombat, enemy, possible_Targets, "")
	
	res = EnemyBehavior.melee_enemy_attack(mapCombat, enemy, target, dijkstra)
	
	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(lystra)
	assert_bool(res).is_true()
	
	
func test_melee_enemy_attack_move_needed():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_melee.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	var possible_Targets = EnemyBehavior.check_players_in_range(mapCombat, enemy, dijkstra[0])
	var target = EnemyBehavior.smart_enemy_target_choice(mapCombat, enemy, possible_Targets, "")
	
	res = EnemyBehavior.melee_enemy_attack(mapCombat, enemy, target, dijkstra)
	
	assert_that(CombatMapStatus.get_selected_enemy()).is_not_null()
	assert_that(enemy.get_map_coords()).is_equal(CombatMapStatus.get_selected_enemy().get_map_coords() + Vector2.UP)
	assert_bool(CombatMapStatus.hasMoved).is_true()
	assert_bool(res).is_true()


func test_dumb_ranged_behavior_target_isEmpty():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_goblin_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	enemy.get_stats()["movement"] = 1
	enemy.get_stats()["range"] = 1
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	var originalPos = enemy.get_map_coords()
	
	res = EnemyBehavior.dumb_ranged_behavior(mapCombat, dijkstra)
	
	assert_vector(enemy.get_map_coords()).is_not_equal(originalPos)
	assert_bool(CombatMapStatus.hasMoved).is_true()
	assert_bool(res).is_false()
	
	enemy.get_stats()["movement"] = 4
	enemy.get_stats()["range"] = 5
	
	
func test_dumb_ranged_behavior_target_ok():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_goblin_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	
	res = EnemyBehavior.dumb_ranged_behavior(mapCombat, dijkstra)
	
	assert_array([dick, samael, lystra]).contains([CombatMapStatus.get_selected_enemy()])
	assert_vector(enemy.get_map_coords()).is_equal(Vector2(1,1))
	assert_bool(CombatMapStatus.hasMoved).is_true()
	assert_bool(res).is_true()
	
func test_smart_ranged_behavior_target_isEmpty():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	enemy.get_stats()["movement"] = 1
	enemy.get_stats()["range"] = 1
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	var originalPos = enemy.get_map_coords()
	
	res = EnemyBehavior.smart_ranged_behavior(mapCombat, dijkstra)
	
	assert_vector(enemy.get_map_coords()).is_not_equal(originalPos)
	assert_bool(CombatMapStatus.hasMoved).is_true()
	assert_bool(res).is_false()
	
	enemy.get_stats()["movement"] = 5
	enemy.get_stats()["range"] = 7
	
	
func test_smart_ranged_behavior_target_ok():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	res = EnemyBehavior.smart_ranged_behavior(mapCombat, dijkstra)
	
	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(lystra)
	assert_vector(enemy.get_map_coords()).is_equal(Vector2(1,1))
	assert_bool(CombatMapStatus.hasMoved).is_true()
	assert_bool(res).is_true()


# ranged only function	# TODO test
func test_find_optimal_shot():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	var possible_targets = EnemyBehavior.check_players_in_range(mapCombat, enemy, dijkstra[0])
	var target = EnemyBehavior.smart_enemy_target_choice(mapCombat, enemy, possible_targets, "")
	var possible_positions = EnemyBehavior.viable_ranged_positions(mapCombat, enemy, target, dijkstra[0])
	
	res = EnemyBehavior.find_optimal_shot(mapCombat, target, possible_positions)
	
	assert_vector(res).is_equal(Vector2(1,1))


# ranged only function
func test_ranged_enemy_attack_isRooted():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	enemy.set_is_rooted(true)
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	var possible_targets = EnemyBehavior.check_players_in_range(mapCombat, enemy, dijkstra[0])
	var target = EnemyBehavior.smart_enemy_target_choice(mapCombat, enemy, possible_targets, "")
	var possible_positions = EnemyBehavior.viable_ranged_positions(mapCombat, enemy, target, dijkstra[0])
	var best_position = EnemyBehavior.find_optimal_shot(mapCombat, target, possible_positions)

	
	res = EnemyBehavior.ranged_enemy_attack(mapCombat, enemy, target, dijkstra, best_position)
	
	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(lystra)
	assert_bool(enemy.is_rooted()).is_false()
	assert_bool(res).is_true()
	
	
func test_ranged_enemy_attack_best_position_already():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	enemy.set_map_coords(Vector2(1,1))
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	var possible_targets = EnemyBehavior.check_players_in_range(mapCombat, enemy, dijkstra[0])
	var target = EnemyBehavior.smart_enemy_target_choice(mapCombat, enemy, possible_targets, "")
	var possible_positions = EnemyBehavior.viable_ranged_positions(mapCombat, enemy, target, dijkstra[0])
	var best_position = EnemyBehavior.find_optimal_shot(mapCombat, target, possible_positions)

	
	res = EnemyBehavior.ranged_enemy_attack(mapCombat, enemy, target, dijkstra, best_position)
	
	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(lystra)
	assert_bool(CombatMapStatus.hasMoved).is_false()
	assert_bool(res).is_true()
	
	
func test_ranged_enemy_attack_with_movement():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	var possible_targets = EnemyBehavior.check_players_in_range(mapCombat, enemy, dijkstra[0])
	var target = EnemyBehavior.smart_enemy_target_choice(mapCombat, enemy, possible_targets, "")
	var possible_positions = EnemyBehavior.viable_ranged_positions(mapCombat, enemy, target, dijkstra[0])
	var best_position = EnemyBehavior.find_optimal_shot(mapCombat, target, possible_positions)
	
	res = EnemyBehavior.ranged_enemy_attack(mapCombat, enemy, target, dijkstra, best_position)
	
	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(lystra)
	assert_that(enemy.get_map_coords()).is_equal(Vector2(1,1))
	assert_bool(CombatMapStatus.hasMoved).is_true()
	assert_bool(res).is_true()
	
	
func test_check_players_in_range_ranged_isRooted():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(0,1))
	lystra.set_map_coords(Vector2(2,3))
	enemy.set_is_rooted(true)
	enemy.get_stats()["range"] = 2
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	res = EnemyBehavior.check_players_in_range_ranged(mapCombat, enemy, dijkstra[0])
	
	assert_array(res).is_equal([samael])
	
	enemy.get_stats()["range"] = 7
	enemy.set_is_rooted(false)
	

func test_check_players_in_range_ranged_ok():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	res = EnemyBehavior.check_players_in_range_ranged(mapCombat, enemy, dijkstra[0])
	
	assert_array(res).is_equal([dick, samael, lystra])


func test_viable_ranged_target():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	
	dick.set_map_coords(Vector2(1,2))
	lystra.set_map_coords(Vector2(0,2))
	samael.set_map_coords(Vector2(2,3))
	enemy.get_stats()["range"] = 2
	
	mapCombat.get_tile_from_coords(Vector2(0,1)).obstacleType = 1
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	res = []
	
	for character in mapCombat.characterGroup.get_children():
		res.append(EnemyBehavior.viable_ranged_target(mapCombat, enemy, character, [Vector2(1,0)]))
		
	assert_array(res).is_equal([true, false, false])
	
	mapCombat.get_tile_from_coords(Vector2(0,1)).obstacleType = 0
	enemy.get_stats()["range"] = 7
	
	
func test_viable_ranged_positions():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	
	dick.set_map_coords(Vector2(1,2))
	lystra.set_map_coords(Vector2(0,2))
	samael.set_map_coords(Vector2(2,3))
	enemy.get_stats()["range"] = 2
	
	mapCombat.get_tile_from_coords(Vector2(0,1)).obstacleType = 1
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	res = []
	#res = EnemyBehavior.viable_ranged_positions(mapCombat, enemy, lystra, dijkstra[0])
	for character in mapCombat.characterGroup.get_children():
		res.append(EnemyBehavior.viable_ranged_positions(mapCombat, enemy, lystra, dijkstra[0]))
		
	#(1,1) -> High terrain
	#(0,0) -> Behind cover
	var best_positions = [Vector2(1,1), Vector2(0,0)]
		
	assert_array(res[0]).is_equal(best_positions)
	assert_array(res[1]).is_equal(best_positions)
	assert_array(res[2]).is_equal(best_positions)
	
	mapCombat.get_tile_from_coords(Vector2(0,1)).obstacleType = 0
	enemy.get_stats()["range"] = 7

# generic for now and will probably will stay unless we want to tweak the hell out of it to account for cover
func test_smart_enemy_target_choice_ranged_no_kill():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	var possible_targets = EnemyBehavior.check_players_in_range(mapCombat, enemy, dijkstra[0])
	
	res = EnemyBehavior.smart_enemy_target_choice(mapCombat, enemy, possible_targets, "")
	
	assert_that(res).is_equal(lystra)
	
	
func test_smart_enemy_target_choice_ranged_kill():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	dick.modify_health(-dick.get_current_health() + 1)
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	var possible_targets = EnemyBehavior.check_players_in_range(mapCombat, enemy, dijkstra[0])
	
	res = EnemyBehavior.smart_enemy_target_choice(mapCombat, enemy, possible_targets, "")
	
	assert_that(res).is_equal(dick)
	
	dick.modify_health(8000)
	
	
func test_smart_enemy_target_choice_mage_no_kill():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_mage.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	var possible_targets = EnemyBehavior.check_players_in_range(mapCombat, enemy, dijkstra[0])
	
	res = EnemyBehavior.smart_enemy_target_choice(mapCombat, enemy, possible_targets, "mage")
	
	assert_that(res).is_equal(dick)
	
	
func test_smart_enemy_target_choice_mage_kill():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	samael.modify_health(-samael.get_current_health() + 1)
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	var possible_targets = EnemyBehavior.check_players_in_range(mapCombat, enemy, dijkstra[0])
	
	res = EnemyBehavior.smart_enemy_target_choice(mapCombat, enemy, possible_targets, "")
	
	assert_that(res).is_equal(samael)
	
	samael.modify_health(8000)

# generic across ranged and melee
# TODO fix with Pablo
func test_check_closest_player(do_skip=true, skip_reason="Test fail due to the original func is not ok"):
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_mage.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	CombatMapStatus.set_initiative([3,0,1,2])
	
	dick = mapCombat.characterGroup.get_children()[0]
	samael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	enemy = mapCombat.enemyGroup.get_children()[0]
	
	dick.set_map_coords(Vector2(0,3))
	samael.set_map_coords(Vector2(1,3))
	lystra.set_map_coords(Vector2(2,3))
	
	samael.set_map_coords(Vector2(1,2))
	
	mapCombat.set_tile_populated(Vector2(0,2), false)
	mapCombat.set_tile_populated(Vector2(1,2), false)
	mapCombat.set_tile_populated(Vector2(2,2), false)
	mapCombat.get_tile_from_coords(Vector2(0,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(1,1)).set_is_control_zone(false)
	mapCombat.get_tile_from_coords(Vector2(2,1)).set_is_control_zone(false)
	
	mapCombat.set_tile_populated(Vector2(0,3), true)
	mapCombat.set_tile_populated(Vector2(1,2), true)
	mapCombat.set_tile_populated(Vector2(2,3), true)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	#var possible_targets = EnemyBehavior.check_players_in_range(mapCombat, enemy, dijkstra[0])
	
	res = EnemyBehavior.check_closest_player(mapCombat, enemy)
	
	assert_that(res[0]).is_equal(samael)

# TODO fix with Pablo
func test_approach_enemy(do_skip=true, skip_reason="Test fails due to check closest player needs repair"):
	assert_that(true).is_equal(true)

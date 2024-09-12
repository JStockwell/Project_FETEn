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
	
	assert_that(mapCombat).is_not_null()
	assert_that(dick.get_map_coords()).is_equal(Vector2(0,3))
	assert_that(samael.get_map_coords()).is_equal(Vector2(1,3))
	assert_that(lystra.get_map_coords()).is_equal(Vector2(2,3))
	

# TODO finish
func test_dumb_melee_behavior_possible_targets_isEmpty():
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
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	res = EnemyBehavior.dumb_melee_behavior(mapCombat, dijkstra)
	
	assert_bool(res).is_true()
	
# TODO finish
func test_smart_melee_behavior_possible_targets_isEmpty():
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
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	res = EnemyBehavior.dumb_melee_behavior(mapCombat, dijkstra)
	
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
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	res = EnemyBehavior.dumb_melee_behavior(mapCombat, dijkstra)
	
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
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	var possible_Targets = EnemyBehavior.check_players_in_range(mapCombat, enemy, dijkstra[0])
	var target = EnemyBehavior.smart_enemy_target_choice(mapCombat, enemy, possible_Targets, "")
	
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
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	var possible_Targets = EnemyBehavior.check_players_in_range(mapCombat, enemy, dijkstra[0])
	var target = EnemyBehavior.smart_enemy_target_choice(mapCombat, enemy, possible_Targets, "")
	
	res = EnemyBehavior.melee_enemy_attack(mapCombat, enemy, target, dijkstra)
	
	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(lystra)
	assert_bool(enemy.is_rooted()).is_false()
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
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	var possible_Targets = EnemyBehavior.check_players_in_range(mapCombat, enemy, dijkstra[0])
	var target = EnemyBehavior.smart_enemy_target_choice(mapCombat, enemy, possible_Targets, "")
	
	res = EnemyBehavior.melee_enemy_attack(mapCombat, enemy, target, dijkstra)
	
	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(lystra)
	assert_that(enemy.get_map_coords()).is_equal(lystra.get_map_coords() + Vector2.UP)
	assert_bool(CombatMapStatus.hasMoved).is_true()
	assert_bool(enemy.is_rooted()).is_false()
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
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	var originalPos = enemy.get_map_coords()
	
	res = EnemyBehavior.dumb_ranged_behavior(mapCombat, dijkstra)
	
	assert_vector(enemy.get_map_coords()).is_greater(originalPos)
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
	
	mapDict["tiles"][3]["obstacleType"] = 1
	
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
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	var originalPos = enemy.get_map_coords()
	
	res = EnemyBehavior.dumb_ranged_behavior(mapCombat, dijkstra)
	
	assert_vector(enemy.get_map_coords()).is_greater(originalPos)
	assert_bool(CombatMapStatus.hasMoved).is_true()
	assert_bool(res).is_false()
	
	mapDict["tiles"][3]["obstacleType"] = 0

	# TODO test
func test_smart_ranged_behavior():
	assert_that(true).is_equal(true)


# ranged only function	# TODO test
func test_find_optimal_shot():
	assert_that(true).is_equal(true)


# ranged only function	# TODO test
func test_ranged_enemy_attack():
	assert_that(true).is_equal(true)

# ranged only function	# TODO test
func test_check_players_in_range_ranged():
	assert_that(true).is_equal(true)

# ranged only function	# TODO test
func test_viable_ranged_target():
	assert_that(true).is_equal(true)
	# TODO test
func test_viable_ranged_positions():
	assert_that(true).is_equal(true)

# generic for now and will probably will stay unless we want to tweak the hell out of it to account for cover	# TODO test
func test_smart_enemy_target_choice():
	assert_that(true).is_equal(true)

# generic across ranged and melee	# TODO test
func test_check_closest_player():
	assert_that(true).is_equal(true)

# generic across ranged and melee	# TODO test
func test_approach_enemy():
	assert_that(true).is_equal(true)

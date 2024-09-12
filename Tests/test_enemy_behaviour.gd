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
	
	dick.set_map_coords(Vector2(0,2))
	samael.set_map_coords(Vector2(1,2))
	lystra.set_map_coords(Vector2(2,2))
	
	assert_that(mapCombat).is_not_null()
	assert_that(dick.get_map_coords()).is_equal(Vector2(0,2))
	assert_that(samael.get_map_coords()).is_equal(Vector2(1,2))
	assert_that(lystra.get_map_coords()).is_equal(Vector2(2,2))
	

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
	
	dick.set_map_coords(Vector2(0,2))
	samael.set_map_coords(Vector2(1,2))
	lystra.set_map_coords(Vector2(2,2))
	enemy.get_stats()["movement"] = 0
	
	mapCombat.set_tile_populated(Vector2(0,1), false)
	mapCombat.set_tile_populated(Vector2(1,1), false)
	mapCombat.set_tile_populated(Vector2(2,1), false)
	
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
	
	dick.set_map_coords(Vector2(0,2))
	samael.set_map_coords(Vector2(1,2))
	lystra.set_map_coords(Vector2(2,2))
	
	mapCombat.set_tile_populated(Vector2(0,1), false)
	mapCombat.set_tile_populated(Vector2(1,1), false)
	mapCombat.set_tile_populated(Vector2(2,1), false)
	
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
	
	dick.set_map_coords(Vector2(0,2))
	samael.set_map_coords(Vector2(1,2))
	lystra.set_map_coords(Vector2(2,2))
	enemy.get_stats()["movement"] = 0
	
	mapCombat.set_tile_populated(Vector2(0,1), false)
	mapCombat.set_tile_populated(Vector2(1,1), false)
	mapCombat.set_tile_populated(Vector2(2,1), false)
	
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
	
	dick.set_map_coords(Vector2(0,2))
	samael.set_map_coords(Vector2(1,2))
	lystra.set_map_coords(Vector2(2,2))
	
	mapCombat.set_tile_populated(Vector2(0,1), false)
	mapCombat.set_tile_populated(Vector2(1,1), false)
	mapCombat.set_tile_populated(Vector2(2,1), false)
	
	CombatMapStatus.set_selected_character(enemy)
	
	mapCombat.generate_dijkstra(enemy)
	dijkstra = mapCombat.characterDijkstra
	
	res = EnemyBehavior.dumb_melee_behavior(mapCombat, dijkstra)
	
	assert_bool(res).is_true()
	

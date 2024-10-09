extends GdUnitTestSuite

var MapCombat = load("res://Scenes/3D/mapCombat.tscn")

var players = Utils.read_json("res://Assets/json/players.json")
var enemies = Utils.read_json("res://Assets/json/enemies.json")
var skillSet = Utils.read_json("res://Assets/json/skills.json")

var mapCombat
var mapDict

var dick
var azrael
var lystra

func before():
	GameStatus.debugMode = false
	GameStatus.testMode = true
	
	
func before_test():
	GameStatus.set_playable_characters(players)
	GameStatus.set_enemy_set(enemies)

	GameStatus.set_party(["dick", "azrael", "lystra"])

	var i = 0
	for skillName in skillSet:
		GameStatus.skillSet[skillName] = Factory.Skill.create(skillSet[skillName])
		GameStatus.skillSet[skillName].set_skill_menu_id(i)
		i += 1

func after_test():
	for test_skill in GameStatus.skillSet:
		GameStatus.skillSet[test_skill].free()
	Utils.reset_all()
	
	
##############
# Unit Tests #
##############

func test_not_null():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_goblin_melee.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)

	mapCombat = MapCombat.instantiate()
	add_child(mapCombat)
	
	dick = mapCombat.characterGroup.get_children()[0]
	azrael = mapCombat.characterGroup.get_children()[1]
	lystra = mapCombat.characterGroup.get_children()[2]
	
	dick.set_map_coords(Vector2(0,2))
	azrael.set_map_coords(Vector2(1,2))
	lystra.set_map_coords(Vector2(2,2))
	
	assert_that(mapCombat).is_not_null()
	assert_that(dick.get_map_coords()).is_equal(Vector2(0,2))
	assert_that(azrael.get_map_coords()).is_equal(Vector2(1,2))
	assert_that(lystra.get_map_coords()).is_equal(Vector2(2,2))
	
	mapCombat.free()
	
	
func test_goblin_melee_behaviour():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_goblin_melee.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	var attacks = {}
	
	for i in range(60):
		mapCombat = MapCombat.instantiate()
		add_child(mapCombat)
		
		CombatMapStatus.set_initiative([3,0,1,2])
		
		dick = mapCombat.characterGroup.get_children()[0]
		azrael = mapCombat.characterGroup.get_children()[1]
		lystra = mapCombat.characterGroup.get_children()[2]
		var goblin = mapCombat.enemyGroup.get_children()[0]
		
		dick.set_map_coords(Vector2(0,3))
		azrael.set_map_coords(Vector2(1,3))
		lystra.set_map_coords(Vector2(2,3))
		
		mapCombat.set_tile_populated(Vector2(0,2), false)
		mapCombat.set_tile_populated(Vector2(1,2), false)
		mapCombat.set_tile_populated(Vector2(2,2), false)
		
		mapCombat.start_turn()
		
		var where_attack = goblin.get_map_coords()
		if attacks.has(where_attack): attacks[where_attack] += 1
		else: attacks[where_attack] = 1
	
		mapCombat.free()
		
	assert_int(attacks.get(Vector2(0,2))).is_between(15,25)
	assert_int(attacks.get(Vector2(1,2))).is_between(15,25)
	assert_int(attacks.get(Vector2(2,2))).is_between(15,25)


func test_orc_melee_no_kill_behaviour():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_melee.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	var attacks = {}
	
	for i in range(60):
		mapCombat = MapCombat.instantiate()
		add_child(mapCombat)
		
		CombatMapStatus.set_initiative([3,0,1,2])
		
		dick = mapCombat.characterGroup.get_children()[0]
		azrael = mapCombat.characterGroup.get_children()[1]
		lystra = mapCombat.characterGroup.get_children()[2]
		var orc = mapCombat.enemyGroup.get_children()[0]
		
		dick.set_map_coords(Vector2(0,3))
		azrael.set_map_coords(Vector2(1,3))
		lystra.set_map_coords(Vector2(2,3))
		
		mapCombat.set_tile_populated(Vector2(0,2), false)
		mapCombat.set_tile_populated(Vector2(1,2), false)
		mapCombat.set_tile_populated(Vector2(2,2), false)
		
		mapCombat.start_turn()
		
		var where_attack = orc.get_map_coords()
		if attacks.has(where_attack): attacks[where_attack] += 1
		else: attacks[where_attack] = 1
		
		mapCombat.free()
		
	assert_int(attacks.get(Vector2(0,2))).is_null()
	assert_int(attacks.get(Vector2(1,2))).is_null()
	assert_int(attacks.get(Vector2(2,2))).is_equal(60)
	
	
func test_orc_melee_kill_behaviour():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_melee.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	var attacks = {}
	
	for i in range(60):
		mapCombat = MapCombat.instantiate()
		add_child(mapCombat)
		
		CombatMapStatus.set_initiative([3,0,1,2])
		
		dick = mapCombat.characterGroup.get_children()[0]
		azrael = mapCombat.characterGroup.get_children()[1]
		lystra = mapCombat.characterGroup.get_children()[2]
		var orc = mapCombat.enemyGroup.get_children()[0]
		
		dick.set_map_coords(Vector2(0,3))
		azrael.set_map_coords(Vector2(1,3))
		lystra.set_map_coords(Vector2(2,3))
		dick.modify_health(-dick.get_current_health() + 1)
		
		mapCombat.set_tile_populated(Vector2(0,2), false)
		mapCombat.set_tile_populated(Vector2(1,2), false)
		mapCombat.set_tile_populated(Vector2(2,2), false)
		
		mapCombat.start_turn()
		
		var where_attack = orc.get_map_coords()
		if attacks.has(where_attack): attacks[where_attack] += 1
		else: attacks[where_attack] = 1
		
		dick.modify_health(8000)
	
		mapCombat.free()
		
	assert_int(attacks.get(Vector2(0,2))).is_equal(60)
	assert_int(attacks.get(Vector2(1,2))).is_null()
	assert_int(attacks.get(Vector2(2,2))).is_null()
	
	
func test_goblin_ranged_behaviour():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_goblin_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	var attacks = {}
	
	for i in range(60):
		mapCombat = MapCombat.instantiate()
		add_child(mapCombat)
		
		CombatMapStatus.set_initiative([3,0,1,2])
		
		dick = mapCombat.characterGroup.get_children()[0]
		azrael = mapCombat.characterGroup.get_children()[1]
		lystra = mapCombat.characterGroup.get_children()[2]
		
		dick.set_map_coords(Vector2(0,3))
		azrael.set_map_coords(Vector2(1,3))
		lystra.set_map_coords(Vector2(2,3))
		
		mapCombat.set_tile_populated(Vector2(0,2), false)
		mapCombat.set_tile_populated(Vector2(1,2), false)
		mapCombat.set_tile_populated(Vector2(2,2), false)
		
		mapCombat.start_turn()
		
		var where_attack = CombatMapStatus.get_selected_enemy().get_id()
		if attacks.has(where_attack): attacks[where_attack] += 1
		else: attacks[where_attack] = 1
		
		mapCombat.free()
		
	assert_int(attacks.get("dick")).is_between(15,25)
	assert_int(attacks.get("azrael")).is_between(15,25)
	assert_int(attacks.get("lystra")).is_between(15,25)
	
	
func test_orc_ranged_no_kill_behaviour():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	var attacks = {}
	
	for i in range(60):
		mapCombat = MapCombat.instantiate()
		add_child(mapCombat)
		
		CombatMapStatus.set_initiative([3,0,1,2])
		
		dick = mapCombat.characterGroup.get_children()[0]
		azrael = mapCombat.characterGroup.get_children()[1]
		lystra = mapCombat.characterGroup.get_children()[2]
		var orc = mapCombat.enemyGroup.get_children()[0]
		
		dick.set_map_coords(Vector2(0,3))
		azrael.set_map_coords(Vector2(1,3))
		lystra.set_map_coords(Vector2(2,3))
		
		mapCombat.set_tile_populated(Vector2(0,2), false)
		mapCombat.set_tile_populated(Vector2(1,2), false)
		mapCombat.set_tile_populated(Vector2(2,2), false)
		
		mapCombat.start_turn()
		
		var where_attack = CombatMapStatus.get_selected_enemy().get_id()
		if attacks.has(where_attack): attacks[where_attack] += 1
		else: attacks[where_attack] = 1
		
		mapCombat.free()
		
	assert_int(attacks.get("dick")).is_null()
	assert_int(attacks.get("azrael")).is_null()
	assert_int(attacks.get("lystra")).is_equal(60)
	
	
func test_orc_ranged_kill_behaviour():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_ranged.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	var attacks = {}
	
	for i in range(60):
		mapCombat = MapCombat.instantiate()
		add_child(mapCombat)
		
		CombatMapStatus.set_initiative([3,0,1,2])
		
		dick = mapCombat.characterGroup.get_children()[0]
		azrael = mapCombat.characterGroup.get_children()[1]
		lystra = mapCombat.characterGroup.get_children()[2]
		var orc = mapCombat.enemyGroup.get_children()[0]
		
		dick.set_map_coords(Vector2(0,3))
		azrael.set_map_coords(Vector2(1,3))
		lystra.set_map_coords(Vector2(2,3))
		dick.modify_health(-dick.get_current_health() + 1)
		
		mapCombat.set_tile_populated(Vector2(0,2), false)
		mapCombat.set_tile_populated(Vector2(1,2), false)
		mapCombat.set_tile_populated(Vector2(2,2), false)
		
		mapCombat.start_turn()
		
		var where_attack = CombatMapStatus.get_selected_enemy().get_id()
		if attacks.has(where_attack): attacks[where_attack] += 1
		else: attacks[where_attack] = 1
		
		dick.modify_health(8000)
	
		mapCombat.free()
		
	assert_int(attacks.get("dick")).is_equal(60)
	assert_int(attacks.get("azrael")).is_null()
	assert_int(attacks.get("lystra")).is_null()


func test_orc_mage_no_kill_behaviour():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_mage.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	var attacks = {}
	
	for i in range(60):
		mapCombat = MapCombat.instantiate()
		add_child(mapCombat)
		
		CombatMapStatus.set_initiative([3,0,1,2])
		
		dick = mapCombat.characterGroup.get_children()[0]
		azrael = mapCombat.characterGroup.get_children()[1]
		lystra = mapCombat.characterGroup.get_children()[2]
		var orc = mapCombat.enemyGroup.get_children()[0]
		
		dick.set_map_coords(Vector2(0,3))
		azrael.set_map_coords(Vector2(1,3))
		lystra.set_map_coords(Vector2(2,3))
		
		mapCombat.set_tile_populated(Vector2(0,2), false)
		mapCombat.set_tile_populated(Vector2(1,2), false)
		mapCombat.set_tile_populated(Vector2(2,2), false)
		
		mapCombat.start_turn()
		
		var where_attack = CombatMapStatus.get_selected_enemy().get_id()
		if attacks.has(where_attack): attacks[where_attack] += 1
		else: attacks[where_attack] = 1
		
		mapCombat.free()
		
	assert_int(attacks.get("dick")).is_equal(60)
	assert_int(attacks.get("azrael")).is_null()
	assert_int(attacks.get("lystra")).is_null()
	
	
func test_orc_mage_kill_behaviour():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_orc_mage.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	var attacks = {}
	
	for i in range(60):
		mapCombat = MapCombat.instantiate()
		add_child(mapCombat)
		
		CombatMapStatus.set_initiative([3,0,1,2])
		
		dick = mapCombat.characterGroup.get_children()[0]
		azrael = mapCombat.characterGroup.get_children()[1]
		lystra = mapCombat.characterGroup.get_children()[2]
		var orc = mapCombat.enemyGroup.get_children()[0]
		
		dick.set_map_coords(Vector2(0,3))
		azrael.set_map_coords(Vector2(1,3))
		lystra.set_map_coords(Vector2(2,3))
		azrael.modify_health(-azrael.get_current_health() + 1)

		mapCombat.set_tile_populated(Vector2(0,2), false)
		mapCombat.set_tile_populated(Vector2(1,2), false)
		mapCombat.set_tile_populated(Vector2(2,2), false)
		
		mapCombat.start_turn()
		
		var where_attack = CombatMapStatus.get_selected_enemy().get_id()
		if attacks.has(where_attack): attacks[where_attack] += 1
		else: attacks[where_attack] = 1
		
		mapCombat.free()
		
	assert_int(attacks.get("dick")).is_null()
	assert_int(attacks.get("azrael")).is_equal(60)
	assert_int(attacks.get("lystra")).is_null()


func test_juggernaut_behaviour():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_juggernaut.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	var attacks = {}
	
	for i in range(60):
		mapCombat = MapCombat.instantiate()
		add_child(mapCombat)
		
		CombatMapStatus.set_initiative([3,0,1,2])
		
		dick = mapCombat.characterGroup.get_children()[0]
		azrael = mapCombat.characterGroup.get_children()[1]
		lystra = mapCombat.characterGroup.get_children()[2]
		var juggernaut = mapCombat.enemyGroup.get_children()[0]
		
		dick.set_map_coords(Vector2(0,3))
		azrael.set_map_coords(Vector2(1,3))
		lystra.set_map_coords(Vector2(2,3))
		
		mapCombat.set_tile_populated(Vector2(0,2), false)
		mapCombat.set_tile_populated(Vector2(1,2), false)
		mapCombat.set_tile_populated(Vector2(2,2), false)
		
		mapCombat.start_turn()
		
		var where_attack = juggernaut.get_map_coords()
		if attacks.has(where_attack): attacks[where_attack] += 1
		else: attacks[where_attack] = 1
	
		mapCombat.free()
		
	assert_int(attacks.get(Vector2(0,2))).is_between(15,25)
	assert_int(attacks.get(Vector2(1,2))).is_between(15,25)
	assert_int(attacks.get(Vector2(2,2))).is_between(15,25)

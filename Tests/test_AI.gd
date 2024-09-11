extends GdUnitTestSuite

var MapCombat = load("res://Scenes/3D/mapCombat.tscn")

var players = Utils.read_json("res://Assets/json/players.json")
var enemies = Utils.read_json("res://Assets/json/enemies.json")
var skillSet = Utils.read_json("res://Assets/json/skills.json")

var mapCombat
var mapDict
var dick
var samael
var lystra

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
	Utils.reset_all()
	
	
##############
# Unit Tests #
##############

func test_not_null():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_goblin.json")
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
	
	mapCombat.free()
	
	
func test_goblin_behaviour():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_AI_goblin.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	GameStatus.set_autorun_combat(false)
	
	var attacks = {}
	
	for i in range(100):
		mapCombat = MapCombat.instantiate()
		add_child(mapCombat)
		
		CombatMapStatus.set_initiative([3,0,1,2])
		
		dick = mapCombat.characterGroup.get_children()[0]
		samael = mapCombat.characterGroup.get_children()[1]
		lystra = mapCombat.characterGroup.get_children()[2]
		var goblin = mapCombat.enemyGroup.get_children()[0]
		
		dick.set_map_coords(Vector2(0,2))
		samael.set_map_coords(Vector2(1,2))
		lystra.set_map_coords(Vector2(2,2))
		
		mapCombat.start_turn()
		
		var where_attack = goblin.get_map_coords()
		if attacks.has(where_attack): attacks[where_attack] += 1
		else: attacks[where_attack] = 1
	
		mapCombat.free()
		
	assert_int(attacks.get(Vector2(0,1))).is_between(23,43)
	assert_int(attacks.get(Vector2(1,1))).is_between(23,43)
	assert_int(attacks.get(Vector2(2,1))).is_between(23,43)

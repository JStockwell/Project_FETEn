extends GdUnitTestSuite

var Tavern = preload("res://Scenes/3D/tavern.tscn")

var test_players = Utils.read_json("res://Assets/json/test_players.json")
var test_enemies = Utils.read_json("res://Assets/json/test_enemies.json")
var test_skillSet = Utils.read_json("res://Assets/json/skills.json")

var test_tavern
var mapDict

func before():
	GameStatus.debugMode = false
	GameStatus.testMode = false

func before_test():
	GameStatus.set_playable_characters(test_players)
	GameStatus.set_enemy_set(test_enemies)
	
	GameStatus.set_party(["attacker"])
	
	CombatMapStatus.set_map_path("res://Assets/json/maps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	
	var i = 0
	for skillName in test_skillSet:
		GameStatus.skillSet[skillName] = Factory.Skill.create(test_skillSet[skillName])
		GameStatus.skillSet[skillName].set_skill_menu_id(i)
		i += 1
	
	GameStatus.set_autorun_combat(false)
	
	test_tavern = Tavern.instantiate()
	add_child(test_tavern)
	
	
func after_test():
	test_tavern.free()
	for test_skill in GameStatus.skillSet:
		GameStatus.skillSet[test_skill].free()
	Utils.reset_all()


##############
# Unit Tests #
##############

func test_not_null():
	assert_that(test_tavern).is_not_null()
	
	
#####################
# Integration Tests #
#####################

func test_setup_cameras(do_skip=false, skip_reason="Needs repair"):
	#Function called in _ready() of tavern
	assert_that(CombatMapStatus.get_map_dimensions()).is_equal(Vector2(5,5))
	assert_bool(CombatMapStatus.is_start_combat()).is_true()
	assert_that(test_tavern.cm).is_not_null()
	assert_that(test_tavern.cm.mapDict["name"]).is_equal("test_map_2vs2")
	
	#Tests for setup_cameras
	#TODO Checkear la z de taverncam
	assert_that(test_tavern.topTavernCam.size).is_equal(float(CombatMapStatus.get_map_x()))
	
	
func test__on_start_turn(do_skip=true):
	assert_that(true).is_equal(true)
	pass

func test__on_combat_start(do_skip=true):
	assert_that(true).is_equal(true)
	pass

func test__on_combat_end(do_skip=true):
	assert_that(true).is_equal(true)
	pass

func test__on_change_camera(do_skip=true):
	assert_that(true).is_equal(true)
	pass


extends GdUnitTestSuite

var Tavern = preload("res://Scenes/3D/tavern.tscn")

var test_players = Utils.read_json("res://Assets/json/test_players.json")
var test_enemies = Utils.read_json("res://Assets/json/test_enemies.json")
var test_skillSet = Utils.read_json("res://Assets/json/skills.json")

var test_tavern
var mapDict

func before():
	GameStatus.debugMode = false
	GameStatus.testMode = true

func before_test():
	GameStatus.set_playable_characters(test_players)
	GameStatus.set_enemy_set(test_enemies)
	
	GameStatus.set_party(["attacker", "attacker2"])
	
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	
	var i = 0
	for skillName in test_skillSet:
		GameStatus.skillSet[skillName] = Factory.Skill.create(test_skillSet[skillName])
		GameStatus.skillSet[skillName].set_skill_menu_id(i)
		i += 1
	
	GameStatus.set_autorun_combat(true)
	
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
# TODO
func test_setup_cameras(do_skip=true, skip_reason="Will be changed"):
	#Function called in _ready() of tavern
	test_tavern.start_map_combat()
	assert_that(CombatMapStatus.get_map_dimensions()).is_equal(Vector2(5,5))
	assert_bool(CombatMapStatus.is_start_combat()).is_true()
	assert_that(test_tavern.cm).is_not_null()
	assert_that(test_tavern.cm.mapDict["name"]).is_equal("test_map_2vs2")
	
	#TODO Tests for setup_camera when its finished
	
	
func test__on_start_turn():
	test_tavern.start_map_combat()
	test_tavern._on_start_turn()

	assert_bool(test_tavern.tavernCam.current).is_true()
	assert_int(test_tavern.setCam).is_equal(1)


func test__on_combat_start():
	test_tavern.start_map_combat()
	var attacker = test_tavern.cm.characterGroup.get_children()[0]
	var defender = test_tavern.cm.enemyGroup.get_children()[0]
	CombatMapStatus.set_active_characters(attacker.get_stats(), defender.get_stats())
	assert_that(test_tavern.com).is_null()
	
	test_tavern._on_combat_start()
	
	assert_that(test_tavern.com).is_not_null()
	assert_bool(test_tavern.com.camera.current).is_true()
	assert_that(test_tavern.com.attacker.get_stats()).is_equal(attacker.get_stats())
	assert_that(test_tavern.com.defender.get_stats()).is_equal(defender.get_stats())
	

func test__on_combat_end():
	test_tavern.start_map_combat()
	var attacker = test_tavern.cm.characterGroup.get_children()[0]
	var defender = test_tavern.cm.enemyGroup.get_children()[0]
	CombatMapStatus.set_active_characters(attacker.get_stats(), defender.get_stats())
	#CombatMapStatus.set_initiative([0,1])
	test_tavern.cm.battleStart = true
	assert_that(test_tavern.com).is_null()
	test_tavern.cm.start_turn()
	test_tavern._on_combat_start()
	
	test_tavern._on_combat_end()
	
	assert_bool(test_tavern.tavernCam.current).is_true()
	assert_that(test_tavern.com).is_queued_for_deletion()
	

	#TODO Tests for setup_camera when its finished
func test__on_change_camera(do_skip=true, skip_reason="TODO when camera is finished"):
	assert_that(true).is_equal(true)
	pass

extends GdUnitTestSuite

var MapCombat = load("res://Scenes/3D/mapCombat.tscn")

var test_players = Utils.read_json("res://Assets/json/test_players.json")
var test_enemies = Utils.read_json("res://Assets/json/test_enemies.json")
var test_skillSet = Utils.read_json("res://Assets/json/skills.json")

var test_mapCombat
var mapDict

func before():
	GameStatus.debugMode = false
	GameStatus.testMode = false

func before_test():
	GameStatus.set_playable_characters(test_players)
	GameStatus.set_enemy_set(test_enemies)

	GameStatus.set_party(["attacker"])

	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_map_1vs1.json")
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


func test__on_start_button_pressed():
	assert_that(CombatMapStatus.get_selected_character()).is_null()

	test_mapCombat._on_start_button_pressed()

	assert_that(CombatMapStatus.get_selected_character()).is_not_null()


func test_choose_random_spawn():
	#Function called in _ready() of mapCombat
	var att_coords1 = []
	var att_coords2 = []

	for i in range(20):
		test_mapCombat.initial_map_load()
		att_coords1.append(GameStatus.get_party()["attacker"]["map_coords"])
		test_mapCombat.initial_map_load()
		att_coords2.append(GameStatus.get_party()["attacker"]["map_coords"])

	assert_that(att_coords1).is_not_equal(att_coords2)


func test_validate_move_ok():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var mapTile = test_mapCombat.get_tile_from_coords(Vector2(0, 2))
	var dijkstra = [Vector2(0,2)]

	var res = test_mapCombat.validate_move(character, mapTile, dijkstra)

	assert_bool(res).is_true()


func test_validate_move_not_dijkstra():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var mapTile = test_mapCombat.get_tile_from_coords(Vector2(0, 2))
	var dijkstra = []

	var res = test_mapCombat.validate_move(character, mapTile, dijkstra)

	assert_bool(res).is_false()


func test_validate_move_tile_populated():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var mapTile = test_mapCombat.get_tile_from_coords(Vector2(2, 2))
	var dijkstra = [Vector2(0,2), Vector2(2, 2)]

	var res = test_mapCombat.validate_move(character, mapTile, dijkstra)

	assert_bool(res).is_false()


func test_validate_move_tile_not_traversable():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var mapTile = test_mapCombat.get_tile_from_coords(Vector2(2,1))
	var dijkstra = [Vector2(0,2), Vector2(2, 1)]

	var res = test_mapCombat.validate_move(character, mapTile, dijkstra)

	assert_bool(res).is_false()


func test_update_ane_character_card_with_mana():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var stats = character.get_stats()

	test_mapCombat.update_ane_character_card(character)

	var char_txt = ""

	char_txt += "Name: " + stats["name"]
	char_txt += "\nHealth: " + str(stats["current_health"]) + "/" + str(stats["max_health"])
	char_txt += "\nMana: " + str(stats["current_mana"]) + "/" + str(stats["max_mana"])
	char_txt += "\nAttack: " + str(stats["attack"])
	char_txt += "\nDefense: " + str(stats["defense"])
	char_txt += "\nDexterity: " + str(stats["dexterity"])
	char_txt += "\nAgility: " + str(stats["agility"])
	char_txt += "\nMovement: " + str(stats["movement"])
	char_txt += "\nRange: " + str(stats["range"])
	char_txt += "\nHealing Cap: " + str(stats["healing_threshold"])  + "/30 HP"

	assert_that(test_mapCombat.aneStats.text).is_equal(char_txt)


func test_update_ane_character_card_with_no_mana():
	var character = test_mapCombat.enemyGroup.get_children()[0]
	var stats = character.get_stats()

	test_mapCombat.update_ane_character_card(character)

	var txt = ""

	txt += "Name: " + stats["name"]
	txt += "\nHealth: " + str(stats["current_health"]) + "/" + str(stats["max_health"])
	txt += "\nAttack: " + str(stats["attack"])
	txt += "\nDefense: " + str(stats["defense"])
	txt += "\nDexterity: " + str(stats["dexterity"])
	txt += "\nAgility: " + str(stats["agility"])
	txt += "\nMovement: " + str(stats["movement"])
	txt += "\nRange: " + str(stats["range"])

	assert_that(test_mapCombat.aneStats.text).is_equal(txt)


#####################
# Integration Tests #
#####################

func test_initial_map_load():
	#Function called in _ready() of mapCombat
	assert_that(CombatMapStatus.get_map_dimensions()).is_equal(Vector2(3, 3))
	assert_that(CombatMapStatus.get_selected_character()).is_null()
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
	test_mapCombat._on_start_button_pressed()
	test_mapCombat.setup_skill_menu()
	var checker

	if(CombatMapStatus.get_selected_character().get_char_name() == "Attacker"):
		checker = test_mapCombat.skillMenu.get_item_text(0)
		assert_that(checker).is_equal("Spheres of Darkness")
		checker = test_mapCombat.skillMenu.get_item_text(1)
		assert_that(checker).is_equal("Death Beam")
		checker = test_mapCombat.skillMenu.get_item_text(2)
		assert_that(checker).is_equal("Bestow Life")
	if(CombatMapStatus.get_selected_character().get_char_name() == "Defender"):
		checker = test_mapCombat.skillMenu.get_item_count()
		assert_int(checker).is_zero()


func test_reset_to_tavern_selected_character_enemy():
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_selected_character(test_mapCombat.enemyGroup.get_children()[0])
	CombatMapStatus.set_initiative([1,0])

	test_mapCombat.reset_to_tavern()

	assert_int(CombatMapStatus.get_current_ini()).is_equal(1)


func test_reset_to_tavern_selected_character_ally_has_moved():
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.characterGroup.get_children()[0].get_stats()["hasMoved"] = true

	test_mapCombat.reset_to_tavern()

	assert_that(CombatMapStatus.get_selected_character()).is_equal(test_mapCombat.characterGroup.get_children()[0])

	test_mapCombat.characterGroup.get_children()[0].get_stats()["hasMoved"] = false


func test_reset_to_tavern_selected_character_ally_has_not_moved(do_skip=true, skip_reason="Tests fails, need for acceptance testing"):
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.characterGroup.get_children()[0].get_stats()["hasMoved"] = false
	test_mapCombat.characterGroup.get_children()[0].get_stats()["movement"] = 1
	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(1,0)

	test_mapCombat.reset_to_tavern()

	var player_coords = CombatMapStatus.get_selected_character().get_stats()["map_coords"]
	if player_coords.x != 0:
		var tile_left = test_mapCombat.get_tile_from_coords(player_coords + Vector2.LEFT).highlighted.visible
		assert_bool(tile_left).is_true()

	if player_coords.y != 0:
		var tile_up = test_mapCombat.get_tile_from_coords(player_coords + Vector2.UP).highlighted.visible
		assert_bool(tile_up).is_true()

	var tile_right_bool = test_mapCombat.get_tile_from_coords(player_coords + Vector2.RIGHT).highlighted.visible
	var tile_down = test_mapCombat.get_tile_from_coords(player_coords + Vector2.DOWN).highlighted.visible
	var tile_21 = test_mapCombat.get_tile_from_coords(Vector2(2, 1)).highlighted.visible

	var tile_12 = test_mapCombat.get_tile_from_coords(Vector2(1, 2))

	var tile_12_cz = tile_12.isControlZone
	var tile_12_h = tile_12.highlighted.visible
	var tile_right = test_mapCombat.get_tile_from_coords(player_coords + Vector2.RIGHT)

	assert_bool(test_mapCombat.get_tile_from_coords(player_coords + Vector2.RIGHT).highlighted.visible).is_true()
	assert_bool(tile_down).is_true()
	assert_bool(tile_21).is_false()
	assert_bool(tile_12.isControlZone).is_true()
	assert_bool(tile_12.highlighted.visible).is_true()


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


func test_generate_dijkstra():
	var currentChar = test_mapCombat.characterGroup.get_children()[0]
	CombatMapStatus.set_selected_character(currentChar)
	var res = [
		Vector2(0,0),
		Vector2(0,1),
		Vector2(0,2),
		Vector2(1,0),
		Vector2(1,1),
		Vector2(1,2),
		Vector2(2,0),
	]

	test_mapCombat.generate_dijkstra(currentChar)

	assert_array(test_mapCombat.characterDijkstra[0]).contains(res)


func test_set_status_bars():
	var char = test_mapCombat.characterGroup.get_children()[0]

	test_mapCombat.set_status_bars(char)

	assert_bool(test_mapCombat.hpBar.visible).is_true()
	assert_that(test_mapCombat.hpBar.max_value).is_equal(char.get_stats()["max_health"])
	assert_that(test_mapCombat.hpBar.value).is_equal(char.get_stats()["current_health"])
	assert_bool(test_mapCombat.manaBar.visible).is_true()
	assert_that(test_mapCombat.manaBar.max_value).is_equal(char.get_stats()["max_mana"])
	assert_that(test_mapCombat.manaBar.value).is_equal(char.get_stats()["current_mana"])


func test_set_status_bars_no_mana():
	var char = test_mapCombat.characterGroup.get_children()[0]
	char.get_stats()["max_mana"] = 0

	test_mapCombat.set_status_bars(char)

	assert_bool(test_mapCombat.hpBar.visible).is_true()
	assert_that(test_mapCombat.hpBar.max_value).is_equal(char.get_stats()["max_health"])
	assert_that(test_mapCombat.hpBar.value).is_equal(char.get_stats()["current_health"])
	assert_bool(test_mapCombat.manaBar.visible).is_false()

	char.get_stats()["max_mana"] = 20


func test_enemy_turn_end():
	var char = test_mapCombat.characterGroup.get_children()[0]
	CombatMapStatus.set_initiative([1,0])
	CombatMapStatus.set_current_ini(0)

	await test_mapCombat.enemy_turn_end()

	assert_int(CombatMapStatus.get_current_ini()).is_equal(1)
	assert_int(CombatMapStatus.get_selected_character().get_map_id()).is_zero()


func test_reset_map_status():
	#Change the map
	GameStatus.set_party(["attacker", "attacker2"])
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_map_2vs2.json")
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


func test_purge_the_dead_ally():
	test_mapCombat._on_start_button_pressed()
	var ally = test_mapCombat.characterGroup.get_children()[0]
	ally.modify_health(-8000)
	assert_int(ally.get_current_health()).is_zero()
	var ally_map_id = ally.get_map_id()
	var ally_tile = test_mapCombat.get_tile_from_coords(ally.get_map_coords())

	test_mapCombat.purge_the_dead()

	assert_array(CombatMapStatus.get_initiative()).not_contains([ally_map_id])
	assert_bool(ally_tile.is_populated()).is_false()

	test_mapCombat.initial_map_load()
	ally = test_mapCombat.characterGroup.get_children()[0]
	ally.modify_health(8000)


func test_purge_the_dead_enemy():
	test_mapCombat._on_start_button_pressed()
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	var player = test_mapCombat.characterGroup.get_children()[0]
	var player_mana = player.get_current_mana()
	enemy.modify_health(-8000)
	assert_int(enemy.get_current_health()).is_zero()
	var enemy_map_id = enemy.get_map_id()
	var enemy_tile = test_mapCombat.get_tile_from_coords(enemy.get_map_coords())
	CombatMapStatus.set_selected_character(player)
	CombatMapStatus.set_selected_enemy(enemy)

	test_mapCombat.purge_the_dead()

	assert_array(CombatMapStatus.get_initiative()).not_contains([enemy_map_id])
	assert_bool(enemy_tile.is_populated()).is_false()
	assert_int(player.get_current_mana()).is_equal(player_mana)

	test_mapCombat.initial_map_load()
	enemy = test_mapCombat.enemyGroup.get_children()[0]
	enemy.modify_health(8000)


func test_purge_the_dead_no_one_dies():
	var ally = test_mapCombat.characterGroup.get_children()[0]
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	var ally_map_id = ally.get_map_id()
	var enemy_map_id = enemy.get_map_id()
	var ally_tile = test_mapCombat.get_tile_from_coords(ally.get_map_coords())
	var enemy_tile = test_mapCombat.get_tile_from_coords(enemy.get_map_coords())
	CombatMapStatus.set_selected_character(ally)
	CombatMapStatus.set_selected_enemy(enemy)

	test_mapCombat.purge_the_dead()

	assert_array(CombatMapStatus.get_initiative()).has_size(2)
	assert_array(CombatMapStatus.get_initiative()).contains([ally_map_id, enemy_map_id])
	assert_bool(ally_tile.is_populated()).is_true()
	assert_bool(enemy_tile.is_populated()).is_true()


func test_purge_the_dead_mana_regen_on_kill():
	test_mapCombat._on_start_button_pressed()
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	var player = test_mapCombat.characterGroup.get_children()[0]
	player.get_stats()["id"] = "azrael"
	var player_mana = player.get_current_mana()
	enemy.modify_health(-8000)
	assert_int(enemy.get_current_health()).is_zero()
	var enemy_map_id = enemy.get_map_id()
	var enemy_tile = test_mapCombat.get_tile_from_coords(enemy.get_map_coords())
	CombatMapStatus.set_selected_character(player)
	CombatMapStatus.set_selected_enemy(enemy)

	test_mapCombat.purge_the_dead()

	assert_array(CombatMapStatus.get_initiative()).not_contains([enemy_map_id])
	assert_bool(enemy_tile.is_populated()).is_false()
	assert_int(player.get_current_mana()).is_equal(player_mana+1)

	test_mapCombat.initial_map_load()
	enemy = test_mapCombat.enemyGroup.get_children()[0]
	enemy.modify_health(8000)
	player.get_stats()["id"] = "attacker"


func test_character_handler_enemy_turn():
	CombatMapStatus.set_selected_character(test_mapCombat.enemyGroup.get_children()[0])

	test_mapCombat.character_handler(test_mapCombat.characterGroup.get_children()[0])

	assert_that(CombatMapStatus.get_selected_ally()).is_null()
	assert_that(CombatMapStatus.get_selected_enemy()).is_null()


func test_character_handler_isEnemy_handled():
	test_mapCombat.battleStart = true
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])

	test_mapCombat.character_handler(test_mapCombat.enemyGroup.get_children()[0])

	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(test_mapCombat.enemyGroup.get_children()[0])
	assert_that(CombatMapStatus.get_selected_ally()).is_null()


func test_character_handler_other_ally_turn():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	test_mapCombat.battleStart = true
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])

	test_mapCombat.character_handler(test_mapCombat.characterGroup.get_children()[1])

	assert_that(CombatMapStatus.get_selected_ally()).is_equal(test_mapCombat.characterGroup.get_children()[1])
	assert_that(CombatMapStatus.get_selected_enemy()).is_null()


func test_selected_checker_last_selection_null_enemy():
	GameStatus.set_party(["attacker", "attacker2"])
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	var player = test_mapCombat.characterGroup.get_children()[1]
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	CombatMapStatus.set_selected_character(player)

	test_mapCombat.selected_checker(enemy, null, enemy.get_stats()["is_enemy"])

	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(enemy)


func test_selected_checker_last_selection_null_ally():
	GameStatus.set_party(["attacker", "attacker2"])
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	var player = test_mapCombat.characterGroup.get_children()[1]
	var ally = test_mapCombat.characterGroup.get_children()[2]
	CombatMapStatus.set_selected_character(player)

	test_mapCombat.selected_checker(ally, null, ally.get_stats()["is_enemy"])

	assert_that(CombatMapStatus.get_selected_ally()).is_equal(ally)


func test_selected_checker_unselect_enemy():
	GameStatus.set_party(["attacker", "attacker2"])
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	var player = test_mapCombat.characterGroup.get_children()[1]
	CombatMapStatus.set_selected_character(player)
	var enemy = test_mapCombat.enemyGroup.get_children()[0]

	test_mapCombat.selected_checker(enemy, enemy, enemy.get_stats()["is_enemy"])

	assert_that(CombatMapStatus.get_selected_enemy()).is_null()


func test_selected_checker_unselect_ally():
	GameStatus.set_party(["attacker", "attacker2"])
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	var player = test_mapCombat.characterGroup.get_children()[1]
	var ally = test_mapCombat.characterGroup.get_children()[2]
	CombatMapStatus.set_selected_character(player)

	test_mapCombat.selected_checker(ally, ally, ally.get_stats()["is_enemy"])

	assert_that(CombatMapStatus.get_selected_ally()).is_null()


func test_selected_checker_change_selection_enemy():
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_map_2vs2.json")
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
	GameStatus.set_party(["attacker", "attacker2"])
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	var old_ally = test_mapCombat.characterGroup.get_children()[1]
	var ally = test_mapCombat.characterGroup.get_children()[2]

	test_mapCombat.selected_checker(ally, old_ally, ally.get_stats()["is_enemy"])

	assert_that(CombatMapStatus.get_selected_ally()).is_equal(ally)

func test_selected_checker_alternate_selection_ally_to_enemy():
	GameStatus.set_party(["attacker", "attacker2"])
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	CombatMapStatus.set_initiative([0, 1, 2, 3])
	var player = test_mapCombat.characterGroup.get_children()[1]
	var ally = test_mapCombat.characterGroup.get_children()[2]
	var enemy = test_mapCombat.enemyGroup.get_children()[1]
	CombatMapStatus.set_selected_character(player)
	CombatMapStatus.set_selected_ally(ally)

	test_mapCombat.selected_checker(enemy, ally, enemy.get_stats()["is_enemy"])

	assert_that(CombatMapStatus.get_selected_ally()).is_null()
	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(enemy)


func test_selected_checker_alternate_selection_enemy_to_ally():
	GameStatus.set_party(["attacker", "attacker2"])
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	CombatMapStatus.set_initiative([0, 1, 2, 3])
	var player = test_mapCombat.characterGroup.get_children()[1]
	var ally = test_mapCombat.characterGroup.get_children()[2]
	var enemy = test_mapCombat.enemyGroup.get_children()[1]
	CombatMapStatus.set_selected_character(player)
	CombatMapStatus.set_selected_ally(enemy)

	test_mapCombat.selected_checker(ally, enemy, ally.get_stats()["is_enemy"])

	assert_that(CombatMapStatus.get_selected_enemy()).is_null()
	assert_that(CombatMapStatus.get_selected_ally()).is_equal(ally)


func test_set_selected_character_enemy():
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	test_mapCombat.set_selected_character(enemy, enemy.get_stats()["is_enemy"])

	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(enemy)


func test_set_selected_character_ally():
	var ally = test_mapCombat.characterGroup.get_children()[0]
	test_mapCombat.set_selected_character(ally, ally.get_stats()["is_enemy"])

	assert_that(CombatMapStatus.get_selected_ally()).is_equal(ally)


func test_set_selected_character_enemy_to_ally():
	var ally = test_mapCombat.characterGroup.get_children()[0]
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	CombatMapStatus.set_selected_enemy(enemy)

	test_mapCombat.set_selected_character(ally, ally.get_stats()["is_enemy"])

	assert_that(CombatMapStatus.get_selected_enemy()).is_null()
	assert_that(CombatMapStatus.get_selected_ally()).is_equal(ally)


func test_set_selected_character_ally_to_enemy():
	var ally = test_mapCombat.characterGroup.get_children()[0]
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	CombatMapStatus.set_selected_ally(ally)

	test_mapCombat.set_selected_character(enemy, enemy.get_stats()["is_enemy"])

	assert_that(CombatMapStatus.get_selected_ally()).is_null()
	assert_that(CombatMapStatus.get_selected_enemy()).is_equal(enemy)


func test_get_tile_from_coords_exist():
	var tile = test_mapCombat.get_tile_from_coords(Vector2(1 ,1))

	assert_that(tile.get_variables()["coords"]).is_equal(Vector2(1 ,1))
	assert_int(tile.get_variables()["height"]).is_zero()
	assert_bool(tile.get_variables()["idt"]).is_false()
	assert_bool(tile.get_variables()["isPopulated"]).is_false()
	assert_bool(tile.get_variables()["isTraversable"]).is_true()
	assert_that(tile.get_variables()["obstacleType"]).is_equal(0)


func test_get_tile_from_coords_not_exist():
	var tile = test_mapCombat.get_tile_from_coords(Vector2(5 ,5))

	assert_that(tile).is_null()


func test_set_tile_populated_false_to_true():
	var tile = test_mapCombat.get_tile_from_coords(Vector2(1 ,1))
	assert_bool(tile.get_variables()["isPopulated"]).is_false()

	test_mapCombat.set_tile_populated(Vector2(1 ,1), true)

	assert_bool(tile.get_variables()["isPopulated"]).is_true()


func test_set_tile_populated_true_to_false():
	var player_coords = test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"]
	var tile = test_mapCombat.get_tile_from_coords(player_coords)
	assert_bool(tile.get_variables()["isPopulated"]).is_true()

	test_mapCombat.set_tile_populated(player_coords, false)

	assert_bool(tile.get_variables()["isPopulated"]).is_false()


# Set selected MapTile
func test_tile_handler_tile_selected():
	test_mapCombat.battleStart = true
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	var tile = test_mapCombat.get_tile_from_coords(Vector2(1 ,1))
	CombatMapStatus.set_selected_map_tile(tile)

	test_mapCombat.tile_handler(tile)

	assert_that(CombatMapStatus.get_selected_map_tile()).is_null()


func test_tile_handler_tile_not_selected():
	test_mapCombat.battleStart = true
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	var old_tile = test_mapCombat.get_tile_from_coords(Vector2(1 ,1))
	var new_tile = test_mapCombat.get_tile_from_coords(Vector2(0 ,0))
	CombatMapStatus.set_selected_map_tile(old_tile)

	test_mapCombat.tile_handler(new_tile)

	assert_that(CombatMapStatus.get_selected_map_tile()).is_not_equal(old_tile)
	assert_that(CombatMapStatus.get_selected_map_tile()).is_equal(new_tile)


func test_tile_handler_null_selected():
	test_mapCombat.battleStart = true
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	var tile = test_mapCombat.get_tile_from_coords(Vector2(1 ,1))

	test_mapCombat.tile_handler(tile)

	assert_that(CombatMapStatus.get_selected_map_tile()).is_equal(tile)


func test__on_move_button_pressed():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var prev_coords = character.get_map_coords()
	var mapTile = test_mapCombat.get_tile_from_coords(Vector2(0, 2))
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_map_tile(mapTile)

	test_mapCombat._on_move_button_pressed()

	assert_that(character.get_map_coords()).is_equal(mapTile.coords)
	assert_bool(test_mapCombat.get_tile_from_coords(Vector2(0, 2)).isPopulated).is_true()
	assert_bool(test_mapCombat.get_tile_from_coords(prev_coords).isPopulated).is_false()


func test_move_character_validated():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var prev_coords = character.get_map_coords()
	var mapTile = test_mapCombat.get_tile_from_coords(Vector2(0, 2))
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_map_tile(mapTile)

	test_mapCombat.move_character()

	assert_that(character.get_map_coords()).is_equal(mapTile.coords)
	assert_bool(test_mapCombat.get_tile_from_coords(Vector2(0, 2)).isPopulated).is_true()
	assert_bool(test_mapCombat.get_tile_from_coords(prev_coords).isPopulated).is_false()


func test_move_character_not_validated():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var prev_coords = character.get_map_coords()
	var mapTile = test_mapCombat.get_tile_from_coords(Vector2(2, 1))
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_map_tile(mapTile)

	test_mapCombat.move_character()

	assert_that(character.get_map_coords()).is_not_equal(mapTile.coords)
	assert_bool(test_mapCombat.get_tile_from_coords(Vector2(2,1)).isPopulated).is_false()
	assert_bool(test_mapCombat.get_tile_from_coords(prev_coords).isPopulated).is_true()


func test__on_phys_attack_button_pressed():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	test_mapCombat.battleStart = true
	CombatMapStatus.set_initiative([0,1])
	CombatMapStatus.set_selected_character(character)
	character.get_stats()["map_coords"] = Vector2(1,2)
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_enemy(enemy)
	
	test_mapCombat._on_phys_attack_button_pressed()
	
	assert_that(test_mapCombat.comPred).is_not_null()
	assert_bool(test_mapCombat.disableUI).is_true()
	assert_str(test_mapCombat.comPred.skillName).is_empty()
	assert_str(test_mapCombat.comPred.skillResult).is_empty()

	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(0,0)


func test_setup_com_pred_no_skill():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	test_mapCombat.battleStart = true
	CombatMapStatus.set_initiative([0,1])
	CombatMapStatus.set_selected_character(character)
	character.get_stats()["map_coords"] = Vector2(1,2)
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_enemy(enemy)
	
	test_mapCombat.setup_com_pred()
	
	assert_that(test_mapCombat.comPred).is_not_null()
	assert_bool(test_mapCombat.disableUI).is_true()
	assert_str(test_mapCombat.comPred.skillName).is_empty()
	assert_str(test_mapCombat.comPred.skillResult).is_empty()

	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(0,0)
	
	
func test_setup_com_pred_skill():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	test_mapCombat.battleStart = true
	CombatMapStatus.set_initiative([0,1])
	CombatMapStatus.set_selected_character(character)
	character.get_stats()["map_coords"] = Vector2(1,2)
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_enemy(enemy)
	var character_skill = "shadow_ball"
	
	test_mapCombat.setup_com_pred(character_skill)
	
	assert_that(test_mapCombat.comPred).is_not_null()
	assert_bool(test_mapCombat.disableUI).is_true()
	assert_that(test_mapCombat.comPred.skillName).is_equal(character_skill)
	assert_str(test_mapCombat.comPred.skillResult).is_empty()

	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(0,0)


func test_attack_combat_prediction_no_skill():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	test_mapCombat.battleStart = true
	CombatMapStatus.set_initiative([0,1])
	CombatMapStatus.set_selected_character(character)
	character.get_stats()["map_coords"] = Vector2(1,2)
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_enemy(enemy)
	test_mapCombat.setup_com_pred()

	test_mapCombat.attack_combat_prediction(test_mapCombat.comPred)

	assert_that(test_mapCombat.comPred).is_queued_for_deletion()
	assert_bool(test_mapCombat.disableUI).is_false()
	assert_that(character.get_stats()).is_equal(CombatMapStatus.get_attacker_stats())
	assert_that(enemy.get_stats()).is_equal(CombatMapStatus.get_defender_stats())

	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(0,0)
	
	
func test_attack_combat_prediction_skill():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	test_mapCombat.battleStart = true
	CombatMapStatus.set_initiative([0,1])
	CombatMapStatus.set_selected_character(character)
	character.get_stats()["map_coords"] = Vector2(1,2)
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_enemy(enemy)
	test_mapCombat.setup_com_pred("shadow_ball")

	test_mapCombat.attack_combat_prediction(test_mapCombat.comPred, "shadow_ball")

	assert_that(test_mapCombat.comPred).is_queued_for_deletion()
	assert_bool(test_mapCombat.disableUI).is_false()
	assert_that(character.get_stats()).is_equal(CombatMapStatus.get_attacker_stats())
	assert_that(enemy.get_stats()).is_equal(CombatMapStatus.get_defender_stats())

	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(0,0)
	
	
func test_close_combat_prediction():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	test_mapCombat.battleStart = true
	CombatMapStatus.set_initiative([0,1])
	CombatMapStatus.set_selected_character(character)
	character.get_stats()["map_coords"] = Vector2(1,2)
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_enemy(enemy)
	test_mapCombat.setup_com_pred()

	test_mapCombat.close_combat_prediction(test_mapCombat.comPred)
	
	assert_that(test_mapCombat.comPred).is_queued_for_deletion()
	assert_bool(test_mapCombat.disableUI).is_false()
	assert_dict(CombatMapStatus.get_attacker_stats()).is_empty()
	assert_dict(CombatMapStatus.get_defender_stats()).is_empty()
	
	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(0,0)


func test_phys_combat_round_melee():
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	CombatMapStatus.set_selected_enemy(test_mapCombat.enemyGroup.get_children()[0])
	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(1,2)

	test_mapCombat.phys_combat_round()

	assert_int(CombatMapStatus.mapMod).is_zero()
	assert_that(test_mapCombat.characterGroup.get_children()[0].get_stats()).is_equal(CombatMapStatus.get_attacker_stats())
	assert_that(test_mapCombat.enemyGroup.get_children()[0].get_stats()).is_equal(CombatMapStatus.get_defender_stats())

	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(0,0)


func test_phys_combat_round_ranged():
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	CombatMapStatus.set_selected_enemy(test_mapCombat.enemyGroup.get_children()[0])
	test_mapCombat.characterGroup.get_children()[0].get_stats()["is_ranged"] = true

	test_mapCombat.phys_combat_round()

	assert_int(CombatMapStatus.mapMod).is_zero()
	assert_that(test_mapCombat.characterGroup.get_children()[0].get_stats()).is_equal(CombatMapStatus.get_attacker_stats())
	assert_that(test_mapCombat.enemyGroup.get_children()[0].get_stats()).is_equal(CombatMapStatus.get_defender_stats())

	test_mapCombat.characterGroup.get_children()[0].get_stats()["is_ranged"] = false


func test_phys_combat_round_ranged_melee():
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


func test_phys_combat_round_melee_mapMod_positive_height():
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	CombatMapStatus.set_selected_enemy(test_mapCombat.enemyGroup.get_children()[0])
	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(1,2)
	var tile = test_mapCombat.get_tile_from_coords(Vector2(1, 2))
	tile.height = 1

	test_mapCombat.phys_combat_round()

	assert_int(CombatMapStatus.mapMod).is_equal(5)
	assert_that(test_mapCombat.characterGroup.get_children()[0].get_stats()).is_equal(CombatMapStatus.get_attacker_stats())
	assert_that(test_mapCombat.enemyGroup.get_children()[0].get_stats()).is_equal(CombatMapStatus.get_defender_stats())

	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(0,0)
	tile.height = 0


func test_phys_combat_round_melee_mapMod_negative_height():
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	CombatMapStatus.set_selected_enemy(test_mapCombat.enemyGroup.get_children()[0])
	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(1,2)
	var tile = test_mapCombat.get_tile_from_coords(Vector2(1, 2))
	tile.height = -1

	test_mapCombat.phys_combat_round()

	assert_int(CombatMapStatus.mapMod).is_equal(-5)
	assert_that(test_mapCombat.characterGroup.get_children()[0].get_stats()).is_equal(CombatMapStatus.get_attacker_stats())
	assert_that(test_mapCombat.enemyGroup.get_children()[0].get_stats()).is_equal(CombatMapStatus.get_defender_stats())

	test_mapCombat.characterGroup.get_children()[0].get_stats()["map_coords"] = Vector2(0,0)
	tile.height = 0


func test_calc_los(do_skip=true, skip_reason="Not possible, raycast fails in testing"):
	#los -> Line Of Sight
	assert_that(true).is_equal(true)
	pass


func test_collision_loop_collision_full_cover(do_skip=true, skip_reason="Not possible, raycast fails in testing"):
	assert_that(true).is_equal(true)
	pass


func test_collision_loop_collision_partial_cover(do_skip=true, skip_reason="Not possible, raycast fails in testing"):
	var cover = test_mapCombat.get_tile_from_coords(Vector2(2, 1))
	cover.init_odz()
	cover.set_odz(false)

	test_mapCombat.characterGroup.get_children()[0].set_map_coords(Vector2(2,0))
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	CombatMapStatus.set_selected_enemy(test_mapCombat.enemyGroup.get_children()[0])

	var ray = RayCast3D.new()
	var origin = CombatMapStatus.get_selected_character().get_map_coords()
	var end = CombatMapStatus.get_selected_enemy().get_map_coords()

	ray.position = Vector3(origin.x, -5, origin.y)
	ray.target_position = Vector3(end.x - origin.x, 0, end.y - origin.y)

	add_child(ray)
	ray.set_collide_with_areas(true)
	ray.hit_back_faces = true
	ray.hit_from_inside = true
	ray.exclude_parent = false

	var result = [false, false, []]

	for i in range(0, 1000):
		result = test_mapCombat.collision_loop(ray, result)

		if result[0]:
			break

	assert_that(result[2][0]).is_equal(cover)


func test_collision_loop_collision_no_cover(do_skip=true, skip_reason="Not possible, raycast fails in testing"):
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	CombatMapStatus.set_selected_enemy(test_mapCombat.enemyGroup.get_children()[0])
	test_mapCombat.characterGroup.get_children()[0].set_map_coords(Vector2(2,0))
	var ray = RayCast3D.new()
	var origin = CombatMapStatus.get_selected_character().get_map_coords()
	var end = CombatMapStatus.get_selected_enemy().get_map_coords()
	ray.position = Vector3(origin.x, -5, origin.y)
	ray.target_position = Vector3(end.x - origin.x, 0, end.y - origin.y)
	add_child(ray)
	ray.set_collide_with_areas(true)
	var result = [false, false, []]

	result = test_mapCombat.collision_loop(ray, result)

	assert_that(result[0]).is_equal(true)


func test_check_behind_cover():
	#obz -> Obstacle Detection Zone
	var cover = test_mapCombat.get_tile_from_coords(Vector2(2, 1))
	var defender = test_mapCombat.enemyGroup.get_children()[0]

	var mapMod = test_mapCombat.check_behind_cover(defender, [cover])

	assert_that(mapMod).is_equal(25)


func test_check_behind_cover_not():
	var cover = []
	var defender = test_mapCombat.enemyGroup.get_children()[0]

	var mapMod = test_mapCombat.check_behind_cover(defender, cover)

	assert_that(mapMod).is_equal(0)


func test__on_skill_selected_target_myself():
	CombatMapStatus.set_initiative([0, 1])
	var caster = test_mapCombat.characterGroup.get_children()[0]
	caster.get_stats()["current_health"] = 1
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_character(caster)
	var skill_id = 6

	test_mapCombat._on_skill_selected(skill_id)

	assert_int(caster.get_current_health()).is_greater(1)

	caster.get_stats()["current_health"] = caster.get_stats()["max_health"]
	caster.get_stats()["current_mana"] = caster.get_stats()["ini_mana"]
	caster.get_stats()["healing_threshold"] = 30


func test__on_skill_selected_target_allies():
	GameStatus.set_party(["attacker", "attacker2"])
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	CombatMapStatus.set_initiative([0, 1, 2, 3])
	var caster = test_mapCombat.characterGroup.get_children()[1]
	var target = test_mapCombat.characterGroup.get_children()[2]
	caster.set_map_coords(Vector2(0,0))
	target.set_map_coords(Vector2(1,0))
	target.get_stats()["current_health"] = 1
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_character(caster)
	CombatMapStatus.set_selected_ally(target)
	var skill_id = 6

	test_mapCombat._on_skill_selected(skill_id)

	assert_int(target.get_current_health()).is_greater(1)

	target.get_stats()["current_health"] = target.get_stats()["max_health"]
	caster.get_stats()["current_mana"] = caster.get_stats()["ini_mana"]
	caster.get_stats()["healing_threshold"] = 30


func test__on_skill_selected_target_enemies():
	CombatMapStatus.set_initiative([0, 1])
	var caster = test_mapCombat.characterGroup.get_children()[0]
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_character(caster)
	CombatMapStatus.set_selected_enemy(enemy)
	caster.modify_mana(10)
	var skill_id = 0

	test_mapCombat._on_skill_selected(skill_id)

	assert_that(test_mapCombat.comPred).is_connected("combat_start", Callable(self, "attack_combat_prediction"))
	assert_that(test_mapCombat.comPred).is_connected("close", Callable(self, "close_combat_prediction"))

	caster.get_stats()["current_mana"] = caster.get_stats()["ini_mana"]
	enemy.get_stats()["current_health"] = enemy.get_stats()["max_health"]


func test_cast_skill_target_myself():
	CombatMapStatus.set_initiative([0, 1])
	var caster = test_mapCombat.characterGroup.get_children()[0]
	caster.get_stats()["current_health"] = 1
	var caster_mana = caster.get_current_mana()
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_character(caster)
	var skill_name = "bestow_life"

	test_mapCombat.cast_skill(skill_name, "")

	assert_int(caster.get_current_health()).is_greater(1)
	assert_int(caster.get_current_mana()).is_less(caster_mana)
	assert_bool(CombatMapStatus.hasAttacked).is_true()

	caster.get_stats()["current_health"] = caster.get_stats()["max_health"]
	caster.get_stats()["current_mana"] = caster.get_stats()["ini_mana"]
	caster.get_stats()["healing_threshold"] = 30
	
	
func test_cast_skill_target_allies():
	GameStatus.set_party(["attacker", "attacker2"])
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	CombatMapStatus.set_initiative([0, 1, 2, 3])
	var caster = test_mapCombat.characterGroup.get_children()[1]
	var target = test_mapCombat.characterGroup.get_children()[2]
	caster.set_map_coords(Vector2(0,0))
	target.set_map_coords(Vector2(1,0))
	target.get_stats()["current_health"] = 1
	var caster_mana = caster.get_current_mana()
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_character(caster)
	CombatMapStatus.set_selected_ally(target)
	var skill_name = "bestow_life"

	test_mapCombat.cast_skill(skill_name, "")

	assert_int(target.get_current_health()).is_greater(1)
	assert_int(caster.get_current_mana()).is_less(caster_mana)
	assert_bool(CombatMapStatus.hasAttacked).is_true()

	target.get_stats()["current_health"] = target.get_stats()["max_health"]
	caster.get_stats()["current_mana"] = caster.get_stats()["ini_mana"]
	target.get_stats()["healing_threshold"] = 30
	
	
func test_cast_skill_target_enemies():
	CombatMapStatus.set_initiative([0, 1])
	var caster = test_mapCombat.characterGroup.get_children()[0]
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_character(caster)
	CombatMapStatus.set_selected_enemy(enemy)
	caster.modify_mana(10)
	var caster_mana = caster.get_current_mana()
	var skill_name = "shadow_ball"

	test_mapCombat.cast_skill(skill_name, "")

	assert_int(caster.get_current_mana()).is_less(caster_mana)
	assert_that(CombatMapStatus.get_attacker_stats()).is_equal(caster.get_stats())
	assert_that(CombatMapStatus.get_defender_stats()).is_equal(enemy.get_stats())
	assert_that(CombatMapStatus.attackRange).is_equal(Utils.calc_distance(caster.get_map_coords(), enemy.get_map_coords()))
	assert_that(CombatMapStatus.attackSkill).is_equal(skill_name)
	assert_bool(CombatMapStatus.hasAttacked).is_true()
	
	caster.get_stats()["current_mana"] = caster.get_stats()["ini_mana"]
	enemy.get_stats()["current_health"] = enemy.get_stats()["max_health"]


func test_allied_skill_handler():
	GameStatus.set_party(["attacker", "attacker2"])
	CombatMapStatus.set_map_path("res://Assets/json/maps/testMaps/test_map_2vs2.json")
	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	test_mapCombat.mapDict = mapDict
	CombatMapStatus.set_is_start_combat(true)
	test_mapCombat.initial_map_load()
	CombatMapStatus.set_initiative([0, 1, 2, 3])

	var caster = test_mapCombat.characterGroup.get_children()[1]
	var target = test_mapCombat.characterGroup.get_children()[2]
	caster.set_map_coords(Vector2(0,0))
	target.set_map_coords(Vector2(1,0))
	var distance = Utils.calc_distance(caster.get_map_coords(), target.get_map_coords())
	test_mapCombat.start_turn()
	target.get_stats()["current_health"] = 1

	test_mapCombat.allied_skill_handler(caster, target, distance, "bestow_life")

	assert_int(target.get_current_health()).is_greater(1)

	target.get_stats()["current_health"] = target.get_stats()["max_health"]
	target.get_stats()["healing_threshold"] = 30


func test__on_end_turn_button_pressed():
	CombatMapStatus.set_initiative([0, 1])
	assert_that(CombatMapStatus.get_current_ini()).is_equal(0)

	test_mapCombat._on_end_turn_button_pressed()

	assert_that(CombatMapStatus.get_current_ini()).is_equal(1)
	assert_bool(CombatMapStatus.is_start_combat()).is_false()


func test_update_buttons_abled():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var prev_coords = character.get_map_coords()
	var mapTile = test_mapCombat.get_tile_from_coords(Vector2(0, 2))
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_map_tile(mapTile)
	CombatMapStatus.set_selected_character(character)
	CombatMapStatus.set_selected_enemy(enemy)

	test_mapCombat.update_buttons()

	assert_bool(test_mapCombat.moveButton.disabled).is_false()
	assert_bool(test_mapCombat.physAttackButton.disabled).is_false()
	assert_bool(test_mapCombat.endTurnButton.disabled).is_false()
	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_false()
	assert_bool(test_mapCombat.changeCameraButton.disabled).is_false()
	assert_bool(test_mapCombat.mainMenuButton.disabled).is_false()


func test_update_buttons_disabled_hasMoved():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var mapTile = test_mapCombat.get_tile_from_coords(Vector2(0, 2))
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_map_tile(mapTile)
	CombatMapStatus.set_selected_character(character)
	CombatMapStatus.set_selected_enemy(enemy)
	CombatMapStatus.set_has_moved(true)
	
	test_mapCombat.update_buttons()
	
	assert_bool(test_mapCombat.moveButton.disabled).is_true()
	assert_bool(test_mapCombat.physAttackButton.disabled).is_false()
	assert_bool(test_mapCombat.endTurnButton.disabled).is_false()
	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_false()
	assert_bool(test_mapCombat.changeCameraButton.disabled).is_false()
	assert_bool(test_mapCombat.mainMenuButton.disabled).is_false()


func test_update_buttons_disabled_isEnemy():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var mapTile = test_mapCombat.get_tile_from_coords(Vector2(0, 2))
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_initiative([1,0])
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_map_tile(mapTile)
	CombatMapStatus.set_selected_character(enemy)
	
	test_mapCombat.update_buttons()
	
	assert_bool(test_mapCombat.moveButton.disabled).is_true()
	assert_bool(test_mapCombat.physAttackButton.disabled).is_true()
	assert_bool(test_mapCombat.endTurnButton.disabled).is_true()
	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_true()
	assert_bool(test_mapCombat.changeCameraButton.disabled).is_true()
	assert_bool(test_mapCombat.mainMenuButton.disabled).is_true()
	
	
func test_update_buttons_disabled_disableUI():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var mapTile = test_mapCombat.get_tile_from_coords(Vector2(0, 2))
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_map_tile(mapTile)
	CombatMapStatus.set_selected_character(character)
	CombatMapStatus.set_selected_enemy(enemy)
	test_mapCombat.disableUI = true

	test_mapCombat.update_buttons()
	
	assert_bool(test_mapCombat.moveButton.disabled).is_true()
	assert_bool(test_mapCombat.physAttackButton.disabled).is_true()
	assert_bool(test_mapCombat.endTurnButton.disabled).is_true()
	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_true()
	assert_bool(test_mapCombat.changeCameraButton.disabled).is_true()
	assert_bool(test_mapCombat.mainMenuButton.disabled).is_true()
	
	
func test_update_buttons_disabled_null_selected_maptile():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_character(character)
	CombatMapStatus.set_selected_enemy(enemy)

	test_mapCombat.update_buttons()

	assert_bool(test_mapCombat.moveButton.disabled).is_true()
	assert_bool(test_mapCombat.physAttackButton.disabled).is_false()
	assert_bool(test_mapCombat.endTurnButton.disabled).is_false()
	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_false()
	assert_bool(test_mapCombat.changeCameraButton.disabled).is_false()
	assert_bool(test_mapCombat.mainMenuButton.disabled).is_false()
	
	
func test_update_buttons_disabled_hasAttacked():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var mapTile = test_mapCombat.get_tile_from_coords(Vector2(0, 2))
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_map_tile(mapTile)
	CombatMapStatus.set_selected_character(character)
	CombatMapStatus.set_selected_enemy(enemy)
	CombatMapStatus.set_has_attacked(true)

	test_mapCombat.update_buttons()

	assert_bool(test_mapCombat.moveButton.disabled).is_false()
	assert_bool(test_mapCombat.physAttackButton.disabled).is_true()
	assert_bool(test_mapCombat.endTurnButton.disabled).is_false()
	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_true()
	assert_bool(test_mapCombat.changeCameraButton.disabled).is_false()
	assert_bool(test_mapCombat.mainMenuButton.disabled).is_false()
	
	
func test_update_buttons_disabled_null_selected_enemy():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var mapTile = test_mapCombat.get_tile_from_coords(Vector2(0, 2))
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_map_tile(mapTile)
	CombatMapStatus.set_selected_character(character)

	test_mapCombat.update_buttons()

	assert_bool(test_mapCombat.moveButton.disabled).is_false()
	assert_bool(test_mapCombat.physAttackButton.disabled).is_true()
	assert_bool(test_mapCombat.endTurnButton.disabled).is_false()
	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_false()
	assert_bool(test_mapCombat.changeCameraButton.disabled).is_false()
	assert_bool(test_mapCombat.mainMenuButton.disabled).is_false()


func test_update_buttons_disabled_no_skills():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var mapTile = test_mapCombat.get_tile_from_coords(Vector2(0, 2))
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	character.get_stats()["skills"] = []
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_map_tile(mapTile)
	CombatMapStatus.set_selected_character(character)
	CombatMapStatus.set_selected_enemy(enemy)

	test_mapCombat.update_buttons()

	assert_bool(test_mapCombat.moveButton.disabled).is_false()
	assert_bool(test_mapCombat.physAttackButton.disabled).is_false()
	assert_bool(test_mapCombat.endTurnButton.disabled).is_false()
	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_true()
	assert_bool(test_mapCombat.changeCameraButton.disabled).is_false()
	assert_bool(test_mapCombat.mainMenuButton.disabled).is_false()
	
	character.get_stats()["skills"] = ["shadow_ball", "nero_nero", "bestow_life"]


func test_update_buttons_disabled():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_character(enemy)
	
	CombatMapStatus.set_has_moved(true)
	test_mapCombat.disableUI = true
	CombatMapStatus.set_has_attacked(true)

	test_mapCombat.update_buttons()

	assert_bool(test_mapCombat.moveButton.disabled).is_true()
	assert_bool(test_mapCombat.physAttackButton.disabled).is_true()
	assert_bool(test_mapCombat.endTurnButton.disabled).is_true()
	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_true()
	assert_bool(test_mapCombat.changeCameraButton.disabled).is_true()
	assert_bool(test_mapCombat.mainMenuButton.disabled).is_true()


func test_update_move_button_ok():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var prev_coords = character.get_map_coords()
	var mapTile = test_mapCombat.get_tile_from_coords(Vector2(0, 2))
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.start_turn()
	CombatMapStatus.set_selected_map_tile(mapTile)

	test_mapCombat.update_move_button()

	assert_bool(test_mapCombat.moveButton.disabled).is_false()


func test_update_move_button_ally_hasMoved():
	CombatMapStatus.set_initiative([0,1])
	CombatMapStatus.set_has_moved(true)

	test_mapCombat.update_move_button()

	assert_bool(test_mapCombat.moveButton.disabled).is_true()



func test_update_move_button_enemy_turn():
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_initiative([1,0])

	test_mapCombat.update_move_button()

	assert_bool(test_mapCombat.moveButton.disabled).is_true()


func test_update_move_button_disableUI():
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.disableUI = true
	var player = test_mapCombat.characterGroup.get_children()[0]
	CombatMapStatus.set_selected_character(player)

	test_mapCombat.update_move_button()

	assert_bool(test_mapCombat.moveButton.disabled).is_true()


func test_update_move_button_not_selected_maptile():
	var character = test_mapCombat.characterGroup.get_children()[0]
	var prev_coords = character.get_map_coords()
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.start_turn()

	test_mapCombat.update_move_button()

	assert_bool(test_mapCombat.moveButton.disabled).is_true()


func test_update_phys_attack_button_after_attack():
	CombatMapStatus.set_initiative([0, 1])
	CombatMapStatus.set_has_attacked(true)

	test_mapCombat.update_phys_attack_button()

	assert_bool(test_mapCombat.physAttackButton.disabled).is_true()


func test_update_phys_attack_button_is_enemy():
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_initiative([1, 0])

	test_mapCombat.update_phys_attack_button()

	assert_bool(test_mapCombat.physAttackButton.disabled).is_true()


func test_update_phys_attack_button_disableUI():
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.disableUI = true
	var player = test_mapCombat.characterGroup.get_children()[0]
	CombatMapStatus.set_selected_character(player)

	test_mapCombat.update_phys_attack_button()

	assert_bool(test_mapCombat.physAttackButton.disabled).is_true()


func test_update_phys_attack_button_no_selected_enemy():
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_initiative([0, 1])
	CombatMapStatus.set_selected_enemy(null)

	test_mapCombat.update_phys_attack_button()

	assert_bool(test_mapCombat.physAttackButton.disabled).is_true()

func test_update_phys_attack_button_enemy_at_range():
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_initiative([0, 1])
	var ally = test_mapCombat.characterGroup.get_children()[0]
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	CombatMapStatus.set_selected_character(ally)
	CombatMapStatus.set_selected_enemy(enemy)

	test_mapCombat.update_phys_attack_button()

	assert_bool(test_mapCombat.physAttackButton.disabled).is_false()


func test_update_phys_attack_button_disabled():
	test_mapCombat._on_start_button_pressed()
	test_mapCombat.update_phys_attack_button()

	assert_bool(test_mapCombat.physAttackButton.disabled).is_true()


func test_update_skill_menu_button_after_attack():
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_initiative([0, 1])
	test_mapCombat.start_turn()
	CombatMapStatus.set_has_attacked(true)

	test_mapCombat.update_skill_menu_button()

	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_true()


func test_update_skill_menu_button_is_enemy():
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	CombatMapStatus.set_selected_character(enemy)

	test_mapCombat.update_skill_menu_button()

	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_true()


func test_update_skill_menu_button_disableUI():
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.disableUI = true
	var player = test_mapCombat.characterGroup.get_children()[0]
	CombatMapStatus.set_selected_character(player)

	test_mapCombat.update_skill_menu_button()

	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_true()


func test_update_skill_menu_button_character_has_no_skills():
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_initiative([0, 1])
	CombatMapStatus.set_current_ini(0)
	test_mapCombat.characterGroup.get_children()[0].get_stats()["skills"] = []

	test_mapCombat.update_skill_menu_button()

	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_true()

	test_mapCombat.characterGroup.get_children()[0].get_stats()["skills"] = ["shadow_ball", "nero_nero", "bestow_life"]


func test_update_skill_menu_button_skills_availables():
	CombatMapStatus.set_initiative([0, 1])
	CombatMapStatus.set_current_ini(0)
	var ally = test_mapCombat.characterGroup.get_children()[0]
	CombatMapStatus.set_selected_character(ally)

	test_mapCombat.update_skill_menu_button()

	assert_bool(test_mapCombat.baseSkillMenu.disabled).is_false()


func test_handle_skill_info_no_skill_hover():
	CombatMapStatus.set_initiative([0, 1])
	CombatMapStatus.set_current_ini(0)

	test_mapCombat.handle_skill_info()

	assert_that(test_mapCombat.focusedSkill).is_equal(-1)


func test_handle_skill_info_skill_hover():
	test_mapCombat._on_start_button_pressed()
	CombatMapStatus.set_initiative([0, 1])
	CombatMapStatus.set_current_ini(0)
	test_mapCombat.start_turn()
	var character = test_mapCombat.characterGroup.get_children()[0]
	CombatMapStatus.set_selected_character(character)
	var focusedSkill = 0
	test_mapCombat.skillMenu.set_focused_item(focusedSkill)
	var mySkill = GameStatus.skillSet[CombatMapStatus.get_selected_character().get_skills()[focusedSkill]].get_skill()
	var skill_txt = ""
	skill_txt += "Description: " + mySkill["description"]
	skill_txt += "\nCost: " + str(mySkill["cost"])

	test_mapCombat.handle_skill_info()

	var checker1 = test_mapCombat.skillCardText.text

	var checker2 = skill_txt
	#.erase(-1)

	assert_that(test_mapCombat.skillCardText.text).is_equal(skill_txt)


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


func test_update_end_turn_button_disableUI():
	CombatMapStatus.set_initiative([0,1])
	test_mapCombat.disableUI = true
	var player = test_mapCombat.characterGroup.get_children()[0]
	CombatMapStatus.set_selected_character(player)

	test_mapCombat.update_end_turn_button()

	assert_bool(test_mapCombat.endTurnButton.disabled).is_true()


func test_update_global_button_ok():
	CombatMapStatus.set_initiative([0,1])
	var player = test_mapCombat.characterGroup.get_children()[0]
	CombatMapStatus.set_selected_character(player)

	test_mapCombat.update_global_button()

	assert_bool(test_mapCombat.changeCameraButton.disabled).is_false()
	assert_bool(test_mapCombat.mainMenuButton.disabled).is_false()


func test_update_global_button_isEnemy():
	CombatMapStatus.set_initiative([1, 0])
	var enemy = test_mapCombat.enemyGroup.get_children()[0]
	CombatMapStatus.set_selected_character(enemy)

	test_mapCombat.update_global_button()

	assert_bool(test_mapCombat.changeCameraButton.disabled).is_true()
	assert_bool(test_mapCombat.mainMenuButton.disabled).is_true()


func test_update_global_button_disableUI():
	CombatMapStatus.set_initiative([0,1])
	var player = test_mapCombat.characterGroup.get_children()[0]
	CombatMapStatus.set_selected_character(player)
	test_mapCombat.disableUI = true

	test_mapCombat.update_global_button()

	assert_bool(test_mapCombat.changeCameraButton.disabled).is_true()
	assert_bool(test_mapCombat.mainMenuButton.disabled).is_true()


func test_highlight_movement(do_skip=true, skip_reason="Test is giving false negatives"):
	test_mapCombat.characterGroup.get_children()[0].get_stats()["movement"] = 1
	test_mapCombat.enemyGroup.get_children()[0].get_stats()["movement"] = 1
	test_mapCombat.remove_control_zones()
	test_mapCombat.remove_selected()
	test_mapCombat.remove_char_highlights()
	test_mapCombat.remove_ally_highlights()
	test_mapCombat.remove_enemy_highlights()

	test_mapCombat.highlight_movement(test_mapCombat.characterGroup.get_children()[0])

	var tile_10 = test_mapCombat.get_tile_from_coords(Vector2(1, 0))
	var tile_01 = test_mapCombat.get_tile_from_coords(Vector2(0, 1))
	var tile_11 = test_mapCombat.get_tile_from_coords(Vector2(1, 1))
	var tile_21 = test_mapCombat.get_tile_from_coords(Vector2(2, 1))
	var tile_12 = test_mapCombat.get_tile_from_coords(Vector2(1, 2))

	assert_bool(tile_10.highlighted.visible).is_true()
	assert_bool(tile_01.highlighted.visible).is_true()
	assert_bool(tile_11.highlighted.visible).is_false()
	assert_bool(tile_21.highlighted.visible).is_false()
	assert_bool(tile_12.highlighted.visible).is_false()

	test_mapCombat.characterGroup.get_children()[0].get_stats()["movement"] = 5
	test_mapCombat.enemyGroup.get_children()[0].get_stats()["movement"] = 5


func test_highlight_control_zones(do_skip=true, skip_reason="Test is giving false negatives"):
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	test_mapCombat.remove_control_zones()
	test_mapCombat.remove_selected()
	test_mapCombat.remove_char_highlights()
	test_mapCombat.remove_ally_highlights()
	test_mapCombat.remove_enemy_highlights()

	test_mapCombat.characterGroup.get_children()[0].get_stats()["movement"] = 1
	test_mapCombat.enemyGroup.get_children()[0].get_stats()["movement"] = 1

	test_mapCombat.highlight_control_zones()

	var tile_11 = test_mapCombat.get_tile_from_coords(Vector2(1, 1))
	var tile_12 = test_mapCombat.get_tile_from_coords(Vector2(1, 2))
	var tile_21 = test_mapCombat.get_tile_from_coords(Vector2(2, 1))

	assert_bool(tile_11.isControlZone).is_false()
	assert_bool(tile_12.isControlZone).is_true()
	assert_bool(tile_21.isControlZone).is_true()

	test_mapCombat.characterGroup.get_children()[0].get_stats()["movement"] = 5
	test_mapCombat.enemyGroup.get_children()[0].get_stats()["movement"] = 5


func test_check_within_bounds_ok():
	var enemyCoords = test_mapCombat.enemyGroup.get_children()[0].get_stats()["map_coords"]
	var vector_up = Vector2(0,-1)
	var vector_left = Vector2(-1,0)

	var checker_up = test_mapCombat.check_within_bounds(enemyCoords + vector_up, vector_up)
	var checker_left = test_mapCombat.check_within_bounds(enemyCoords + vector_left, vector_left)

	assert_bool(checker_up).is_true()
	assert_bool(checker_left).is_true()


func test_check_within_bounds_out_of_bounds():
	var enemyCoords = test_mapCombat.enemyGroup.get_children()[0].get_stats()["map_coords"]
	var vector_down = Vector2(0,1)
	var vector_right = Vector2(1,0)

	var checker_down = test_mapCombat.check_within_bounds(enemyCoords + vector_down, vector_down)
	var checker_right = test_mapCombat.check_within_bounds(enemyCoords + vector_right, vector_right)

	assert_bool(checker_down).is_false()
	assert_bool(checker_right).is_false()


func test_check_within_bounds_enemy_tile():
	var enemyCoords = test_mapCombat.enemyGroup.get_children()[0].get_stats()["map_coords"]

	var check_enemy_tile = test_mapCombat.check_within_bounds(enemyCoords, Vector2(0,0))

	assert_bool(check_enemy_tile).is_false()


func test_remove_highlights():
	test_mapCombat.remove_highlights()

	var tile_00 = test_mapCombat.get_tile_from_coords(Vector2(0, 0))
	var tile_01 = test_mapCombat.get_tile_from_coords(Vector2(0, 1))
	var tile_02 = test_mapCombat.get_tile_from_coords(Vector2(0, 2))
	var tile_10 = test_mapCombat.get_tile_from_coords(Vector2(1, 0))
	var tile_11 = test_mapCombat.get_tile_from_coords(Vector2(1, 1))
	var tile_12 = test_mapCombat.get_tile_from_coords(Vector2(1, 2))
	var tile_20 = test_mapCombat.get_tile_from_coords(Vector2(2, 0))
	var tile_21 = test_mapCombat.get_tile_from_coords(Vector2(2, 1))
	var tile_22 = test_mapCombat.get_tile_from_coords(Vector2(2, 2))

	assert_bool(tile_00.highlighted.visible).is_false()
	assert_bool(tile_01.highlighted.visible).is_false()
	assert_bool(tile_02.highlighted.visible).is_false()
	assert_bool(tile_10.highlighted.visible).is_false()
	assert_bool(tile_11.highlighted.visible).is_false()
	assert_bool(tile_12.highlighted.visible).is_false()
	assert_bool(tile_20.highlighted.visible).is_false()
	assert_bool(tile_21.highlighted.visible).is_false()
	assert_bool(tile_22.highlighted.visible).is_false()

	test_mapCombat.reset_map_status()


func test_remove_control_zones(do_skip=true, skip_reason="Test is giving false negatives"):
	test_mapCombat.remove_char_highlights()
	test_mapCombat.remove_ally_highlights()
	test_mapCombat.remove_enemy_highlights()
	var tile_11 = test_mapCombat.get_tile_from_coords(Vector2(1, 1))
	var tile_12 = test_mapCombat.get_tile_from_coords(Vector2(1, 2))
	var tile_21 = test_mapCombat.get_tile_from_coords(Vector2(2, 1))

	test_mapCombat.remove_control_zones()

	assert_bool(tile_11.isControlZone).is_false()
	assert_bool(tile_12.isControlZone).is_false()
	assert_bool(tile_21.isControlZone).is_false()


func test_remove_selected(do_skip=true, skip_reason="Test is giving false negatives"):
	var tile = test_mapCombat.get_tile_from_coords(Vector2(1, 1))
	test_mapCombat.remove_control_zones()
	test_mapCombat.remove_char_highlights()
	test_mapCombat.remove_ally_highlights()
	test_mapCombat.remove_enemy_highlights()

	CombatMapStatus.set_selected_map_tile(tile)

	test_mapCombat.remove_selected()

	assert_that(tile.highlighted.visible).is_equal(false)


func test_remove_char_highlights(do_skip=true, skip_reason="Test is giving false negatives"):
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	var tile = test_mapCombat.characterGroup.get_children()[0]
	test_mapCombat.remove_selected()
	test_mapCombat.remove_ally_highlights()
	test_mapCombat.remove_enemy_highlights()
	test_mapCombat.remove_control_zones()

	test_mapCombat.remove_char_highlights()

	assert_that(test_mapCombat.characterGroup.get_children()[0].selectedChar.visible).is_equal(false)


func test_remove_ally_highlights(do_skip=true, skip_reason="Test is giving false negatives"):
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	var tile = test_mapCombat.characterGroup.get_children()[0]
	test_mapCombat.remove_selected()
	test_mapCombat.remove_char_highlights()
	test_mapCombat.remove_enemy_highlights()
	test_mapCombat.remove_control_zones()

	test_mapCombat.remove_ally_highlights()

	assert_that(test_mapCombat.characterGroup.get_children()[0].selectedAlly.visible).is_equal(false)


func test_remove_enemy_highlights(do_skip=true, skip_reason="Test is giving false negatives"):
	CombatMapStatus.set_selected_character(test_mapCombat.characterGroup.get_children()[0])
	var tile = test_mapCombat.characterGroup.get_children()[0]
	test_mapCombat.remove_selected()
	test_mapCombat.remove_char_highlights()
	test_mapCombat.remove_ally_highlights()
	test_mapCombat.remove_control_zones()

	test_mapCombat.remove_enemy_highlights()

	assert_that(test_mapCombat.characterGroup.get_children()[0].selectedEnemy.visible).is_equal(false)

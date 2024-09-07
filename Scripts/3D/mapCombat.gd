extends Node3D

var mapDict: Dictionary
var setCam = 1
var battleStart: bool = false
var characterDijkstra
var focusedSkill: int = -1
var mapHeightModifier = 0.25
var disableUI: bool = false
var isPaused: bool = false

var BuffParticles = load("res://Scenes/Entities/buffParticles.tscn")
var CombatPrediction = load("res://Scenes/UI/combatPrediction.tscn")

@onready
var mapTileGroup = $MapTileGroup
@onready
var characterGroup = $CharacterGroup
@onready
var enemyGroup = $EnemyGroup
@onready
var ui = $UI
@onready
var uiStart = $StartUI
@onready
var moveButton = $UI/Actions/MoveButton
@onready
var physAttackButton = $UI/Actions/PhysAttackButton
@onready
var endTurnButton = $UI/Actions/EndTurnButton
@onready
var globalButtons = $GlobalButtons
@onready
var changeCameraButton = $GlobalButtons/ChangeCamera
@onready
var mainMenuButton = $GlobalButtons/MainMenuButton
@onready
var returnMainMenu = $ReturnMainMenu
@onready
var baseSkillMenu = $UI/Actions/Skills/SkillMenu
@onready
var skillMenu = $UI/Actions/Skills/SkillMenu.get_popup()
@onready
var skillIssue = $UI/Actions/Skills/SkillIssue
@onready
var skillIssue2 = $UI/Actions/Skills/SkillIssue2
@onready
var hpBar = $UI/StatusBars/HPBar
@onready
var hpBarText = $UI/StatusBars/HPText
@onready
var manaBar = $UI/StatusBars/ManaBar
@onready
var manaBarText = $UI/StatusBars/ManaText
@onready
var selCharSprite = $UI/SelectedCharacter/SelCharSprite
@onready
var initiativeBar = $UI/Initiative
@onready
var skillCard = $UI/Actions/Skills/SkillCard
@onready
var skillCardText = $UI/Actions/Skills/SkillCard/SkillCardText
@onready
var aneCharacter = $UI/AnECharacter
@onready
var aneStats = $UI/AnECharacter/AnEStats
@onready
var aneSprite = $UI/AnECharacter/AnESprite

var comPred

# Called when the node enters the scene tree for the first time.
func _ready():
	battleStart = false
	skillMenu.connect("id_pressed", Callable(self, "_on_skill_selected"))

	mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	initial_map_load()
	calculate_combat_initiative()
	ui.hide()
	aneCharacter.hide()
	globalButtons.hide()
	returnMainMenu.hide()
	uiStart.show()

	if GameStatus.testMode:
		await start_turn()

func initial_map_load() -> void:
	var row = []
	for tile in mapDict["tiles"]:
		var mapTile = Factory.MapTile.create(tile)
		mapTileGroup.add_child(mapTile, true)
		mapTile.position = Vector3(mapTile.get_coords().x, mapTile.get_height() * mapHeightModifier, mapTile.get_coords().y)
		mapTile.connect("tile_selected", Callable(self, "tile_handler"))

		if mapTile.get_obstacle_type() in [1, 2]:
			mapTile.init_odz()
			mapTile.set_odz(false)

		row.append(mapTile.get_variables().duplicate())

		if mapTile.get_coords().x == CombatMapStatus.get_map_x():
			CombatMapStatus.add_map_tile_row(row)
			row = []

	var i = 0
	var positions = mapDict["ally_spawn"]
	for character in GameStatus.get_party():
		var partyMember = Factory.Character.create(GameStatus.get_party_member(character), false)
		partyMember.scale *= Vector3(0.5, 0.5, 0.5)
		partyMember.position = CombatMapStatus.get_map_spawn()

		# TODO Possibly choose spawn, not sure if we're going to do this
		var spawnPos = choose_random_spawn(positions)

		partyMember.position += Vector3(spawnPos.x, 0.5 + (mapHeightModifier * get_tile_from_coords(spawnPos).get_height()), spawnPos.y)
		partyMember.set_map_coords(spawnPos)
		partyMember.set_map_id(i)
		characterGroup.add_child(partyMember)

		partyMember.set_is_enemy(false)
		partyMember.connect("character_selected", Callable(self, "character_handler"))

		set_tile_populated(spawnPos, true)
		i += 1

	var j = 0
	for character in mapDict["enemy_spawn"]:
		var enemy = Factory.Character.create(GameStatus.get_enemy_from_enemy_set(character[0]), true)
		enemy.scale *= Vector3(0.5, 0.5, 0.5)
		enemy.position = CombatMapStatus.get_map_spawn()
		var spawnPos = Utils.string_to_vector2(character[1])
		enemy.position += Vector3(spawnPos.x, 0.5 + (mapHeightModifier * get_tile_from_coords(spawnPos).get_height()), spawnPos.y)
		enemy.set_map_coords(spawnPos)
		enemy.set_map_id(i + j)
		enemyGroup.add_child(enemy)

		enemy.set_is_enemy(true)
		enemy.connect("character_selected", Callable(self, "character_handler"))

		set_tile_populated(spawnPos, true)
		j += 1

func choose_random_spawn(spawnPositions: Array) -> Vector2:
	var spawnPos
	var index

	for c in range(100):
		index = randi_range(0, len(spawnPositions) - 1)
		spawnPos = Utils.string_to_vector2(mapDict["ally_spawn"][index])
		if not get_tile_from_coords(spawnPos).is_populated() and get_tile_from_coords(spawnPos).get_obstacle_type() == 0:
			break

	return spawnPos

func calculate_combat_initiative() -> void:
	var allCharacters = []
	var res_dict = {}
	var result = []
	var initiativeBarResult = []

	for char in characterGroup.get_children():
		var ini = char.calculate_initiative(randi_range(1, 20))
		res_dict[char.get_map_id()] = ini
		allCharacters.append(char)

	for enemy in enemyGroup.get_children():
		var ini = enemy.calculate_initiative(randi_range(1, 20))
		res_dict[enemy.get_map_id()] = ini
		allCharacters.append(enemy)

	# Order the results
	var ordered_ini = res_dict.values()
	ordered_ini.sort_custom(sort_descending)

	# Construct the array
	for initiative in ordered_ini:
		var char = res_dict.find_key(initiative)
		result.append(char)
		res_dict.erase(char)

	# Set result
	CombatMapStatus.set_initiative(result)
	var myCharacter

	for mapId in result:
		for character in allCharacters:
			if character.get_map_id() == mapId:
				initiativeBarResult.append(character)
				break

	initiativeBar.set_initiative(initiativeBarResult)

func setup_skill_menu() -> void:
	skillMenu.clear()

	for skill in CombatMapStatus.get_selected_character().get_skills():
		skillMenu.add_item(GameStatus.skillSet[skill].get_skill_name(), GameStatus.skillSet[skill].get_skill_menu_id())

func reset_to_tavern():
	if CombatMapStatus.get_current_ini() > len(CombatMapStatus.get_initiative()) - 1:
		CombatMapStatus.set_current_ini(len(CombatMapStatus.get_initiative()) - 1)

	reset_map_status()
	if not CombatMapStatus.get_selected_character().is_enemy():
		highlight_control_zones(enemyGroup)
	else:
		highlight_control_zones(characterGroup)

	skillCard.hide()
	skillIssue.hide()
	skillIssue2.hide()

	if CombatMapStatus.get_selected_character() == null or CombatMapStatus.get_selected_character().is_enemy():
		CombatMapStatus.advance_ini()
		await start_turn()
	else:
		CombatMapStatus.get_selected_character().selectedChar.show()
		set_status_bars(CombatMapStatus.get_selected_character())
		selCharSprite.texture = load(CombatMapStatus.get_selected_character().get_sprite())
		if not CombatMapStatus.hasMoved:
			highlight_movement(CombatMapStatus.get_selected_character())

func sort_descending(a: float, b: float) -> bool:
	if a >= b:
		return true
	return false

signal start_turn_signal
func start_turn() -> void:
	start_turn_signal.emit()
	CombatMapStatus.attackSkill = ""

	if CombatMapStatus.get_current_turn_char() == CombatMapStatus.get_initiative()[0] and not CombatMapStatus.is_start_combat():
		regen_mana()
	else:
		CombatMapStatus.set_is_start_combat(false)

	reset_map_status()
	skillCard.hide()
	skillIssue.hide()
	skillIssue2.hide()

	var currentChar = CombatMapStatus.get_selected_character()

	CombatMapStatus.set_has_attacked(false)
	CombatMapStatus.set_has_moved(false)
	CombatMapStatus.set_selected_character(currentChar)

	set_status_bars(currentChar)
	initiativeBar.pointer = CombatMapStatus.get_current_ini()
	initiativeBar.modify_initiative()

	if CombatMapStatus.get_selected_character().get_sprite() == "":
		selCharSprite.texture = load("res://Assets/Characters/Placeholder/sprite_placeholder.png")
	else:
		selCharSprite.texture = load(CombatMapStatus.get_selected_character().get_sprite())

	if currentChar.is_enemy():
		currentChar.selectedEnemy.show()

		highlight_control_zones(characterGroup)
		generate_dijkstra(currentChar)

		if not GameStatus.testMode:
			await wait(1)
		var enemyAttack

		match CombatMapStatus.get_selected_character().get_id():
			"goblin", "juggernaut":
				enemyAttack = EnemyBehavior.dumb_melee_behavior(self, characterDijkstra)
			"orc":
				enemyAttack = EnemyBehavior.smart_melee_behavior(self, characterDijkstra)
			"sling_gobbo":
				enemyAttack = EnemyBehavior.dumb_ranged_behavior(self, characterDijkstra)
			"ranged_orc", "mage":
				enemyAttack = EnemyBehavior.smart_ranged_behavior(self, characterDijkstra)

		if not GameStatus.testMode:
			await wait(1)
		
		if enemyAttack and CombatMapStatus.get_selected_character().get_id() == "mage":
			CombatMapStatus.set_combat(currentChar, CombatMapStatus.get_selected_enemy(), Utils.calc_distance(currentChar.get_map_coords(), CombatMapStatus.get_selected_enemy().get_map_coords()), "icicle") # how to get defender
			combat_start.emit()
		elif enemyAttack:
			phys_combat_round()

		else:
			enemy_turn_end()

	else:
		setup_skill_menu()
		currentChar.selectedChar.show()
		highlight_control_zones(enemyGroup) #first highlight the control zones to allow correct dijkstra calculation
		generate_dijkstra(currentChar) #generate the dijkstra function
		highlight_movement(currentChar) #highlight the movement zones available (player characters only)


func generate_dijkstra(currentChar) -> void:
	#generate the dijkstra, will be called several times later, thus we update it here to avoid several calls to a computationally costly function
	if self.get_tile_from_coords(currentChar.get_map_coords()).is_control_zone():
		characterDijkstra = Utils._dijkstra(self, currentChar.get_map_coords(), currentChar.get_movement()-1)
	else:
		characterDijkstra = Utils._dijkstra(self, currentChar.get_map_coords(), currentChar.get_movement())


func set_status_bars(character) -> void:
	hpBar.set_max(character.get_max_health())
	hpBar.set_value_no_signal(character.get_current_health())
	hpBarText.text = str(character.get_current_health()) + "/" + str(character.get_max_health())

	if character.get_max_mana() == 0:
		manaBar.hide()
		manaBarText.hide()

	else:
		manaBar.show()
		manaBarText.show()
		manaBar.set_max(character.get_max_mana())
		manaBar.set_value_no_signal(character.get_current_mana())
		manaBarText.text = str(character.get_current_mana()) + "/" + str(character.get_max_mana())

func enemy_turn_end():
	CombatMapStatus.advance_ini()
	await start_turn()

func reset_map_status() -> void:
	remove_ally_highlights()
	remove_char_highlights()
	remove_enemy_highlights()
	remove_highlights()
	remove_control_zones()
	remove_selected()

	CombatMapStatus.set_selected_ally(null)
	CombatMapStatus.set_selected_character(null)
	CombatMapStatus.set_selected_enemy(null)
	CombatMapStatus.set_selected_map_tile(null)
	CombatMapStatus.mapMod = 0

	var currentChar
	var flag = true
	isPaused = false

	for character in characterGroup.get_children():
		if character.get_map_id() == CombatMapStatus.get_current_turn_char():
			currentChar = character
			flag = false

	if flag:
		for enemy in enemyGroup.get_children():
			if enemy.get_map_id() == CombatMapStatus.get_current_turn_char():
				currentChar = enemy

	CombatMapStatus.set_selected_character(currentChar)

# TODO Redo with actual mana recharges
func regen_mana() -> void:
	for char in characterGroup.get_children():
		if char.get_max_mana() != 0:
			char.modify_mana(char.get_reg_mana())


func purge_the_dead():
	var deadList = []
	for char in characterGroup.get_children():
		if char.get_current_health() == 0:
			deadList.append(char)

	for enemy in enemyGroup.get_children():
		if enemy.get_current_health() == 0:
			deadList.append(enemy)

	for dead in deadList:
		if dead.is_enemy():
			var selCharID = CombatMapStatus.get_selected_character().get_id()
			var enemCharID = CombatMapStatus.get_selected_enemy().get_id()
			
			if "samael" == selCharID or "salvador" == selCharID or "azrael" == selCharID:
				CombatMapStatus.get_selected_character().modify_mana(1)
				
			elif "samael" == enemCharID or "salvador" == enemCharID or "azrael" == enemCharID:
				CombatMapStatus.get_selected_enemy().modify_mana(1)

		CombatMapStatus.remove_character_ini(dead.get_map_id())
		var tile = get_tile_from_coords(dead.get_map_coords())
		tile.set_is_populated(false)
		initiativeBar.character_death(dead)
		dead.free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameStatus.debugMode:
		update_debug_label()

	if battleStart:
		update_buttons()


# Set selected enemies
func character_handler(character) -> void:
	if battleStart and not isPaused:
		if not CombatMapStatus.get_selected_character().is_enemy():
			if character.is_enemy():
				selected_checker(character, CombatMapStatus.get_selected_enemy(), character.is_enemy())
			elif character.get_instance_id() != CombatMapStatus.get_selected_character().get_instance_id():
				selected_checker(character, CombatMapStatus.get_selected_ally(), character.is_enemy())


func selected_checker(character, combatMapStatusCharacter, isEnemy: bool) -> void:
	if combatMapStatusCharacter == null or combatMapStatusCharacter.get_name() != character.get_name():
		set_selected_character(character, isEnemy)

	else:
		set_selected_character(null, isEnemy)


func set_selected_character(character, isEnemy: bool) -> void:
	remove_ally_highlights()
	remove_enemy_highlights()

	CombatMapStatus.set_selected_enemy(null)
	CombatMapStatus.set_selected_ally(null)

	if isEnemy:
		CombatMapStatus.set_selected_enemy(character)
		if character != null:
			character.selectedEnemy.show()

	else:
		CombatMapStatus.set_selected_ally(character)
		if character != null:
			character.selectedAlly.show()

	if character == null:
		aneCharacter.hide()

	else:
		aneCharacter.show()
		update_ane_character_card(character)

# AnE = Allies and Enemies
func update_ane_character_card(character) -> void:
	var txt = ""
	var stats = character.get_stats()

	txt += "Name: " + stats["name"]
	txt += "\nHealth: " + str(stats["current_health"]) + "/" + str(stats["max_health"])
	if stats["max_mana"] != 0:
		txt += "\nMana: " + str(stats["current_mana"]) + "/" + str(stats["max_mana"])
	txt += "\nAttack: " + str(stats["attack"])
	txt += "\nDefense: " + str(stats["defense"])
	txt += "\nDexterity: " + str(stats["dexterity"])
	txt += "\nAgility: " + str(stats["agility"])
	txt += "\nMovement: " + str(stats["movement"])
	txt += "\nRange: " + str(stats["range"])
	if not character.is_enemy():
		txt += "\nHealing Cap: " + str(stats["healing_threshold"]) + "/30 HP"

	aneStats.text = txt
	aneSprite.texture = load(stats["sprite_path"])

func get_tile_from_coords(coords: Vector2):
	for tile in mapTileGroup.get_children():
		if tile.get_coords() == coords:
			return tile
	return null

func set_tile_populated(coords: Vector2, value: bool) -> void:
	get_tile_from_coords(coords).set_is_populated(value)

# Set selected MapTile
func tile_handler(mapTile) -> void:
	if battleStart and not isPaused:
		if not CombatMapStatus.get_selected_character().is_enemy():
			if CombatMapStatus.get_selected_map_tile() == mapTile:
				remove_selected()
				CombatMapStatus.set_selected_map_tile(null)
			else:
				CombatMapStatus.set_selected_map_tile(mapTile)
				remove_selected()
				mapTile.selected.show()

func _on_start_button_pressed():
	battleStart = true
	ui.show()
	globalButtons.show()
	uiStart.hide()
	await start_turn()

# Player movement
func _on_move_button_pressed():
	move_character()


func move_character() -> void:
	var selChar = CombatMapStatus.get_selected_character()
	if validate_move(selChar, CombatMapStatus.get_selected_map_tile(), characterDijkstra[0]):
		var tile_coords = CombatMapStatus.get_selected_map_tile().get_coords()
		var old_char_coords = CombatMapStatus.get_selected_character().get_map_coords()

		selChar.position = CombatMapStatus.get_map_spawn()
		selChar.position += Vector3(tile_coords.x, 0.5 + (mapHeightModifier * CombatMapStatus.get_selected_map_tile().get_height()), tile_coords.y)
		selChar.set_map_coords(Vector2(tile_coords.x, tile_coords.y))

		# Deselect mapTile
		CombatMapStatus.set_selected_map_tile(null)
		set_tile_populated(old_char_coords, false)
		set_tile_populated(tile_coords, true)
		# Remove highlights
		remove_highlights()
		remove_selected()
		CombatMapStatus.set_has_moved(true)


func validate_move(character, mapTile, dijkstra) -> bool:
	var result = true

	if not dijkstra.has(mapTile.get_coords()):
		result = false
	
	if mapTile.is_populated() or mapTile.get_obstacle_type() == 1:
		result = false

	if not mapTile.is_traversable():
		result = false

	return result

signal combat_start

func _on_phys_attack_button_pressed():
	setup_com_pred()


func setup_com_pred(skillName: String = "", skillResult: String = ""):
	CombatMapStatus.mapMod = 0
	skillIssue2.hide()
	var attacker = CombatMapStatus.get_selected_character()
	var defender = CombatMapStatus.get_selected_enemy()

	var attackerPosition = attacker.get_map_coords()
	var defenderPosition = defender.get_map_coords()
	var losResult = calc_los(attackerPosition, defender)

	if losResult[0] and Utils.calc_distance(attackerPosition, defenderPosition) != 1:
		skillIssue2.show()
		
	else:
		if Utils.calc_distance(attackerPosition, defenderPosition) != 1:
			CombatMapStatus.set_hit_blocked(false)
			CombatMapStatus.mapMod -= losResult[1]
			
		if Utils.calc_distance(attackerPosition, defenderPosition) == 1 and attacker.is_ranged():
			CombatMapStatus.mapMod -= 25

		var attTile = get_tile_from_coords(attacker.get_map_coords())
		var defTile = get_tile_from_coords(defender.get_map_coords())

		CombatMapStatus.mapMod += 5 * (attTile.get_height() - defTile.get_height())
		
		disableUI = true
		comPred = CombatPrediction.instantiate()
		
		CombatMapStatus.set_attack_skill(skillName)
		
		comPred.position = Vector2(468, 376)
		
		comPred.skillName = skillName
		comPred.skillResult = skillResult
		
		add_child(comPred)
		
		comPred.connect("combat_start", Callable(self, "attack_combat_prediction"))
		comPred.connect("close", Callable(self, "close_combat_prediction"))
		
		comPred.setup()


func attack_combat_prediction(comPred, skillName: String = "", skillResult:String = ""):
	comPred.hide()
	comPred.queue_free()
	disableUI = false
	
	if CombatMapStatus.attackSkill == "":
		phys_combat_round()
		
	else:
		cast_skill(skillName, skillResult)


func close_combat_prediction(comPred):
	comPred.hide()
	comPred.queue_free()
	disableUI = false


func phys_combat_round() -> void:
	CombatMapStatus.mapMod = 0
	skillIssue2.hide()
	var attacker = CombatMapStatus.get_selected_character()
	var defender = CombatMapStatus.get_selected_enemy()

	var attackerPosition = attacker.get_map_coords()
	var defenderPosition = defender.get_map_coords()
	# 0: blockedFlag, 1: mapMod
	var losResult = calc_los(attackerPosition, defender)

	if losResult[0] and Utils.calc_distance(attackerPosition, defenderPosition) != 1:
		skillIssue2.show()

	else:
		if Utils.calc_distance(attackerPosition, defenderPosition) != 1:
			CombatMapStatus.set_hit_blocked(false)
			CombatMapStatus.mapMod -= losResult[1]

		if Utils.calc_distance(attackerPosition, defenderPosition) == 1 and attacker.is_ranged():
			CombatMapStatus.mapMod -= 25

		var attTile = get_tile_from_coords(attacker.get_map_coords())
		var defTile = get_tile_from_coords(defender.get_map_coords())

		CombatMapStatus.mapMod += 5 * (attTile.get_height() - defTile.get_height())

		CombatMapStatus.set_combat(attacker, defender, Utils.calc_distance(attackerPosition, defenderPosition))

		combat_start.emit()

# Result: hitFlag, mapMod
# hitFlag true means there's obstacle, can't attack
# hitFlag false means there's no obstacle, continue with attack with mapMod
#TODO breaking on first round of checks, doesnt really collide with anything although it should
func calc_los(attackerPosition, defender) -> Array:
	var ray = RayCast3D.new()
	var targetPosition = defender.get_map_coords()
	ray.position = Vector3(attackerPosition.x, -5, attackerPosition.y)
	ray.target_position = Vector3(targetPosition.x - attackerPosition.x, 0, targetPosition.y - attackerPosition.y)

	add_child(ray)
	ray.set_collide_with_areas(true)

	# endFlag, hasCollidedFull, mapMod
	var result = [false, false, []]

	for i in range(0, 1000):
		result = collision_loop(ray, result)

		if result[0] == true:
			break

	if result[1]:
		return [true, 0]

	else:
		if len(result[2]) == 0:
			return [false, 0]

		else:
			return [false, check_behind_cover(defender, result[2])]


# args: endFlag: bool, noLoS: bool, foundTiles: Array
func collision_loop(ray, args: Array):
	ray.force_raycast_update()
	var cover = get_tile_from_coords(Vector2(2, 1))
	var tile_test = mapTileGroup.get_children()[5]

	if ray.is_colliding():
		var tile = ray.get_collider().get_parent()

		if tile.get_obstacle_type() == 2:
			ray.free()
			args[0] = true
			args[1] = true

		elif tile.get_obstacle_type() == 1:
			args[2].append(tile)
			tile.set_odz(true)

	else:
		args[0] = true

	return args

func check_behind_cover(defender, tileArray: Array) -> int:
	var mapMod = 0
	for tile in tileArray:
		if Utils.calc_distance(defender.get_map_coords(), tile.get_coords()) == 1:
			mapMod = 25

		tile.set_odz(false)

	return mapMod


func _on_skill_selected(id: int):
	skillIssue.hide()
	skillIssue2.hide()
	skillMenu.hide()
	skillCard.hide()

	var skillName
	for skill in GameStatus.skillSet:
		if GameStatus.skillSet[skill].get_skill_menu_id() == id:
			skillName = skill

	var skillResult
	if GameStatus.skillSet[skillName].can_target_allies():
		if CombatMapStatus.get_selected_ally() != null:
			skillResult = SkillMenu.validate_skill(skillName, CombatMapStatus.get_selected_character(), CombatMapStatus.get_selected_ally())
		else:
			skillResult = SkillMenu.validate_skill(skillName, CombatMapStatus.get_selected_character(), CombatMapStatus.get_selected_character())
	else:
		skillResult = SkillMenu.validate_skill(skillName, CombatMapStatus.get_selected_character(), CombatMapStatus.get_selected_enemy())

	#TODO revisar -> skillMenu
	if skillResult != "":
		skillIssue.text = skillResult
		skillIssue.show()

	else:
		if GameStatus.skillSet[skillName].can_target_allies():
			cast_skill(skillName, skillResult)
		else:
			setup_com_pred(skillName, skillResult)

# TODO test
func cast_skill(skillName: String, skillResult):
	var caster = CombatMapStatus.get_selected_character() #got it out of the 3 since the character using the skill is always required
	caster.modify_mana(-GameStatus.skillSet[skillName].get_cost())

	if GameStatus.skillSet[skillName].can_target_allies():
		if CombatMapStatus.get_selected_ally() == null:
			var target = CombatMapStatus.get_selected_character()
			skillResult = await allied_skill_handler(caster, target, Utils.calc_distance(caster.get_map_coords(), target.get_map_coords()), skillName)
		else:
			var target = CombatMapStatus.get_selected_ally()
			skillResult = await allied_skill_handler(caster, target, Utils.calc_distance(caster.get_map_coords(), target.get_map_coords()), skillName)
		
		aneCharacter.hide()
		
	else:
		var defender = CombatMapStatus.get_selected_enemy()

		CombatMapStatus.set_combat(caster, defender, Utils.calc_distance(caster.get_map_coords(), defender.get_map_coords()), skillName)
		combat_start.emit()

		if not GameStatus.skillSet[skillName].is_instantaneous(): #handles the instantaneous flag here
			CombatMapStatus.hasAttacked = true


func allied_skill_handler(caster, target, distance, skillName):
	var particleArgs: Array
	disableUI = true
	particleArgs = SEF.run_out_of_combat(skillName, caster, target, GameStatus.skillSet[skillName].get_spa())
	target.cap_current_stats(target.get_stats())

	var buffPart = BuffParticles.instantiate()
	add_child(buffPart)
	buffPart.connect("particleEnd", Callable(self, "_on_particle_end"))

	buffPart.position = Vector3(target.get_map_coords().x, 0.5 + get_tile_from_coords(target.get_map_coords()).get_height() * mapHeightModifier, target.get_map_coords().y)
	buffPart.start(particleArgs[0], particleArgs[1])


func _on_particle_end(particleScn):
	particleScn.queue_free()
	set_status_bars(CombatMapStatus.get_selected_character())
	disableUI = false

func _on_end_turn_button_pressed():
	CombatMapStatus.advance_ini()
	await start_turn()

func _on_main_menu_button_pressed():
	if not CombatMapStatus.selectedCharacter.is_enemy():
		isPaused = !isPaused

		if isPaused:
			returnMainMenu.show()
			ui.hide()
			globalButtons.hide()

		else:
			returnMainMenu.hide()
			ui.show()
			globalButtons.show()

func _on_rmm_yes_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/mainMenu.tscn")

# Buttons updater
func update_buttons() -> void:
	if not isPaused:
		update_move_button()
		update_phys_attack_button()
		update_end_turn_button()
		update_skill_menu_button()
		update_global_button()

func update_move_button() -> void:
	if CombatMapStatus.hasMoved or CombatMapStatus.get_selected_character().is_enemy() or disableUI:
		moveButton.disabled = true
	else:
		if CombatMapStatus.get_selected_map_tile() == null:
			moveButton.disabled = true

		elif validate_move(CombatMapStatus.get_selected_character(), CombatMapStatus.get_selected_map_tile(), characterDijkstra[0]):
			moveButton.disabled = false

		else:
			moveButton.disabled = true

func update_phys_attack_button() -> void:
	if CombatMapStatus.hasAttacked or CombatMapStatus.get_selected_character().is_enemy() or disableUI:
		physAttackButton.disabled = true
	else:
		if CombatMapStatus.get_selected_enemy() == null:
			physAttackButton.disabled = true
		elif Utils.calc_distance(CombatMapStatus.get_selected_character().get_map_coords(), CombatMapStatus.get_selected_enemy().get_map_coords()) <= CombatMapStatus.get_selected_character().get_range():
			physAttackButton.disabled = false
		else:
			physAttackButton.disabled = true

func update_skill_menu_button() -> void:
	var instantMenu = false # allow menus to be displayed if instant skills present in character
	for skill in CombatMapStatus.get_selected_character().get_skills():
		if GameStatus.skillSet[skill].is_instantaneous():
			instantMenu = true

	if disableUI:
		baseSkillMenu.disabled = true
	elif instantMenu:
		baseSkillMenu.disabled = false
		handle_skill_info()
	elif CombatMapStatus.hasAttacked or CombatMapStatus.get_selected_character().is_enemy() or len(CombatMapStatus.get_selected_character().get_skills()) == 0:
		baseSkillMenu.disabled = true
	else:
		baseSkillMenu.disabled = false
		handle_skill_info()


func handle_skill_info() -> void:
	var newFocusedSkill = skillMenu.get_focused_item()
	if newFocusedSkill != focusedSkill:
		focusedSkill = newFocusedSkill

		if focusedSkill == -1:
			skillCard.hide()

		else:
			var mySkill = GameStatus.skillSet[CombatMapStatus.get_selected_character().get_skills()[focusedSkill]].get_skill()
			var txt = "Description: " + mySkill["description"]
			txt += "\nCost: " + str(mySkill["cost"])

			skillCardText.text = txt
			skillCard.show()

func update_end_turn_button() -> void:
	if CombatMapStatus.get_selected_character().is_enemy() or disableUI:
		endTurnButton.disabled = true
	else:
		endTurnButton.disabled = false


func update_global_button() -> void:
	if CombatMapStatus.get_selected_character().is_enemy() or disableUI:
		changeCameraButton.disabled = true
		mainMenuButton.disabled = true
	else:
		changeCameraButton.disabled = false
		mainMenuButton.disabled = false

func highlight_movement(character) -> void: #dijkstra probablemente va aquí
	for tile in characterDijkstra[0]:
		var sel_tile = get_tile_from_coords(tile)
		if sel_tile != null and not sel_tile.is_populated() and sel_tile.is_traversable() and not sel_tile.get_obstacle_type() == 1:
			sel_tile.highlighted.show()

func highlight_control_zones(myCharacterGroup) -> void:
	for character in myCharacterGroup.get_children():
		var characterCoords = character.get_map_coords()
		for i in range(-1, 2):
			for j in range(-1, 2):
				if check_within_bounds(characterCoords + Vector2(i,j), Vector2(i,j)):
					var tile = get_tile_from_coords(characterCoords + Vector2(i,j))
					if tile.is_traversable():
						tile.enemy.show()
						tile.set_is_control_zone(true)

func check_within_bounds(vector: Vector2, offset: Vector2) -> bool:
	var result = true

	if abs(offset.x) + abs(offset.y) != 1:
		result = false

	if vector.x < 0 or vector.y < 0:
		result = false

	if vector.x >= CombatMapStatus.get_map_x() or vector.y >= CombatMapStatus.get_map_y():
		result = false

	if result:
		for enemy in enemyGroup.get_children():
			if enemy.get_map_coords() == vector:
				return false

	return result

func remove_highlights() -> void:
	for tile in mapTileGroup.get_children():
		tile.highlighted.hide()

func remove_control_zones() -> void:
	for tile in mapTileGroup.get_children():
		tile.set_is_control_zone(false)
		tile.enemy.hide()

func remove_selected() -> void:
	for tile in mapTileGroup.get_children():
		tile.selected.hide()

func remove_char_highlights() -> void:
	for character in characterGroup.get_children():
		character.selectedChar.hide()
		aneCharacter.hide()

func remove_ally_highlights() -> void:
	for character in characterGroup.get_children():
		character.selectedAlly.hide()
		aneCharacter.hide()

func remove_enemy_highlights() -> void:
	for enemy in enemyGroup.get_children():
		enemy.selectedEnemy.hide()

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

signal change_camera
func _on_change_camera_pressed():
	change_camera.emit()

# Debug
@onready
var debugLabel = $DebugUI/DebugLabel

var debugSelected
var debugAlly
var debugEnemy
var debugTile

func update_debug_label():
	debugLabel.text = "selectedCharacter\n"
	if CombatMapStatus.get_selected_character() == null:
		debugLabel.text += "null"
	else:
		debugSelected = CombatMapStatus.get_selected_character()
		debugLabel.text += "name: " + debugSelected.get_char_name()
		debugLabel.text += "\ncoords: " + str(debugSelected.get_map_coords())
		debugLabel.text += "\nhealth: " + str(debugSelected.get_current_health())
		debugLabel.text += "\ncurrentMov: " + str(debugSelected.get_movement())
		if debugSelected.get_max_mana() != 0:
			debugLabel.text += "\ncurrentMana: " + str(debugSelected.get_current_mana())

	debugLabel.text += "\n--------------\nselectedAlly\n"
	if CombatMapStatus.get_selected_ally() == null:
		debugLabel.text += "null"
	else:
		debugAlly = CombatMapStatus.get_selected_ally()
		debugLabel.text += "name: " + debugAlly.get_char_name()
		debugLabel.text += "\ncoords: " + str(debugAlly.get_map_coords())
		debugLabel.text += "\nhealth: " + str(debugAlly.get_current_health())
		debugLabel.text += "\ncurrentMov: " + str(debugAlly.get_movement())
		if debugAlly.get_max_mana() != 0:
			debugLabel.text += "\ncurrentMana: " + str(debugAlly.get_current_mana())

	debugLabel.text += "\n--------------\nselectedEnemy\n"
	if CombatMapStatus.get_selected_enemy() == null:
		debugLabel.text += "null"
	else:
		debugEnemy = CombatMapStatus.get_selected_enemy()
		debugLabel.text += "name: " + debugEnemy.get_char_name()
		debugLabel.text += "\ncoords: " + str(debugEnemy.get_map_coords())
		debugLabel.text += "\nhealth: " + str(debugEnemy.get_current_health())
		debugLabel.text += "\ncurrentMov: " + str(debugEnemy.get_movement())
		if debugEnemy.get_max_mana() != 0:
			debugLabel.text += "\ncurrentMana: " + str(debugEnemy.get_current_mana())

	debugLabel.text += "\n--------------\nselectedMapTile\n"
	if CombatMapStatus.get_selected_map_tile() == null:
		debugLabel.text += "null"
	else:
		debugTile = CombatMapStatus.get_selected_map_tile()
		debugLabel.text += "coords: " + str(debugTile.get_coords())
		debugLabel.text += "\nisPopulated: " + str(debugTile.is_populated())
		debugLabel.text += "\nname: " + str(debugTile.get_name())
		debugLabel.text += "\nisControlZone: " + str(debugTile.is_control_zone())

	debugLabel.text += "\n--------------\ncombatMapStatus\n"
	debugLabel.text += "initiative: " + str(CombatMapStatus.get_initiative())
	debugLabel.text += "\ncurrentInitative: " + str(CombatMapStatus.get_current_turn_char())
	debugLabel.text += "\nhasAttacked: " + str(CombatMapStatus.hasAttacked)
	debugLabel.text += "\nhasMoved: " + str(CombatMapStatus.hasMoved)


func _on_debug_ally_skill_button_pressed():
	var skillName = "bestow_life"
	var caster = CombatMapStatus.get_selected_character()
	var target = CombatMapStatus.get_selected_ally()
	var distance = Utils.calc_distance(caster.get_map_coords(), target.get_map_coords())
	allied_skill_handler(caster, target, distance, skillName)

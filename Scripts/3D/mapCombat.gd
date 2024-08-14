extends Node3D

@onready
var cameraPivot = $Utility/CameraPivot
@onready
var camera = $Utility/CameraPivot/Camera3D
@onready
var mapTileGroup = $MapTileGroup
@onready
var characterGroup = $CharacterGroup
@onready
var enemyGroup = $EnemyGroup
@onready
var moveButton = $UI/MoveButton
@onready
var physAttackButton = $UI/PhysAttackButton
@onready
var endTurnButton = $UI/EndTurnButton

# Called when the node enters the scene tree for the first time.
func _ready():
	cameraPivot.position = Vector3(CombatMapStatus.get_map_x()/2, 0, CombatMapStatus.get_map_y()/2)
	camera.position = Vector3(0,0,CombatMapStatus.get_map_x())
	
	if CombatMapStatus.is_start_combat():
		initial_map_load()
		calculate_combat_initiative()
	else:
		reload_map()
		
	await start_turn()
	
func initial_map_load() -> void:
	for x in CombatMapStatus.get_map_x():
		var row = []
		for y in CombatMapStatus.get_map_y():
			var mapTile = Factory.MapTile.create({
				"coords": Vector2(x,y),
				"height": 0,
				"difficulty": 0,
				"isPopulated": false,
				"isTraversable": true,
				"isObstacle": false,
				"meshPath": ""
			})
			
			mapTileGroup.add_child(mapTile, true)
			mapTile.translate(Vector3(x, mapTile.get_height(), y))
			mapTile.connect("tile_selected", Callable(self, "tile_handler"))
			
			row.append(mapTile.get_variables().duplicate())
		CombatMapStatus.add_map_tile_row(row)
		
	var i = 0
	for character in GameStatus.get_party():
		var partyMember = Factory.Character.create(GameStatus.get_party_member(character))
		partyMember.scale *= Vector3(0.5, 0.5, 0.5)
		partyMember.position = Vector3(0, 0, i)
		partyMember.set_map_coords(Vector2(0, i))
		partyMember.set_map_id(i)
		characterGroup.add_child(partyMember)
		
		partyMember.set_is_enemy(false)
		partyMember.connect("character_selected", Callable(self, "character_handler"))
		
		set_tile_populated(Vector2(0, i), true)
		i += 1
		
	var j = 0
	for character in CombatMapStatus.get_enemies():
		var enemy = Factory.Character.create(CombatMapStatus.get_enemy(character))
		enemy.scale *= Vector3(0.5, 0.5, 0.5)
		enemy.position = Vector3(CombatMapStatus.get_map_x() - 1, 0, CombatMapStatus.get_map_y() - j - 1)
		enemy.set_map_coords(Vector2(CombatMapStatus.get_map_x() - 1, CombatMapStatus.get_map_y() - j - 1 ))
		enemy.set_map_id(i + j)
		enemyGroup.add_child(enemy)
		
		enemy.set_is_enemy(true)
		enemy.connect("character_selected", Callable(self, "character_handler"))
		
		set_tile_populated(Vector2(CombatMapStatus.get_map_x() - 1, CombatMapStatus.get_map_y() - 1 - j), true)
		j += 1
		
	CombatMapStatus.set_is_start_combat(false)

func reload_map():
	for mapTileRow in CombatMapStatus.get_map_tile_matrix():
		for mapTileVars in mapTileRow:
			var mapTile = Factory.MapTile.create(mapTileVars)
			mapTileGroup.add_child(mapTile, true)
			mapTile.translate(Vector3(mapTile["coords"].x, mapTile.get_height(), mapTile["coords"].y))
			mapTile.connect("tile_selected", Callable(self, "tile_handler"))
			
	for character in GameStatus.get_party():
		if GameStatus.get_party_member(character)["current_health"] > 0:
			var partyMember = Factory.Character.create(GameStatus.get_party_member(character))
			partyMember.scale *= Vector3(0.5, 0.5, 0.5)
			partyMember.position = Vector3(partyMember.get_map_coords().x, 0, partyMember.get_map_coords().y)
			characterGroup.add_child(partyMember)
			
			partyMember.connect("character_selected", Callable(self, "character_handler"))
			
			set_tile_populated(Vector2(partyMember.get_map_coords().x, partyMember.get_map_coords().y), true)
		
	for character in CombatMapStatus.get_enemies():
		if CombatMapStatus.get_enemy(character)["current_health"] > 0:
			var enemy = Factory.Character.create(CombatMapStatus.get_enemy(character))
			enemy.scale *= Vector3(0.5, 0.5, 0.5)
			enemy.position = Vector3(enemy.get_map_coords().x, 0, enemy.get_map_coords().y)
			enemyGroup.add_child(enemy)
			
			enemy.connect("character_selected", Callable(self, "character_handler"))
			
			set_tile_populated(Vector2(enemy.get_map_coords().x, enemy.get_map_coords().y), true)

# TODO Don't use instance ID!
func calculate_combat_initiative() -> void:
	var res_dict = {}
	var result = []
	
	for char in characterGroup.get_children():
		var ini = char.calculate_initiative(randi_range(1, 20))
		res_dict[char.get_map_id()] = ini
		
	for enemy in enemyGroup.get_children():
		var ini = enemy.calculate_initiative(randi_range(1, 20))
		res_dict[enemy.get_map_id()] = ini

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
	
func sort_descending(a: float, b: float) -> bool:
	if a > b:
		return true
	return false

func start_turn() -> void:
	reset_map_status()
	
	var currentChar
	var flag = true
	
	for character in characterGroup.get_children():
		if character.get_map_id() == CombatMapStatus.get_current_turn_char():
			currentChar = character
			flag = false
			
	if flag:
		for enemy in enemyGroup.get_children():
			if enemy.get_map_id() == CombatMapStatus.get_current_turn_char():
				currentChar = enemy
	
	currentChar.modify_current_movement(999)
	
	CombatMapStatus.set_has_attacked(false)
	CombatMapStatus.set_selected_character(currentChar)
	
	if currentChar.is_enemy():
		currentChar.selectedEnemy.show()
		await wait(2)
		CombatMapStatus.advance_ini()
		await start_turn()
		
	else:
		currentChar.selectedChar.show()
		highlight_movement(currentChar)
	
func reset_map_status() -> void:
	remove_ally_highlights()
	remove_char_highlights()
	remove_enemy_highlights()
	remove_highlights()
	remove_selected()
	
	CombatMapStatus.set_selected_ally(null)
	CombatMapStatus.set_selected_character(null)
	CombatMapStatus.set_selected_enemy(null)
	CombatMapStatus.set_selected_map_tile(null)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameStatus.debugMode:
		update_debug_label()
		
	update_buttons()
	
# Set selected enemies
func character_handler(character) -> void:
	if not CombatMapStatus.get_selected_character().is_enemy():
		if character.is_enemy():
			selected_checker(character, CombatMapStatus.get_selected_enemy(), character.is_enemy())
		elif character.get_instance_id() != CombatMapStatus.get_selected_character().get_instance_id():
			selected_checker(character, CombatMapStatus.get_selected_character(), character.is_enemy())

func selected_checker(character, combatMapStatusCharacter, isEnemy: bool) -> void:
	if combatMapStatusCharacter == null:
		if not isEnemy:
			character.selectedAlly.show()
		else:
			character.selectedEnemy.show()
			
		set_selected_character(character, isEnemy)
			
	elif combatMapStatusCharacter.get_name() == character.get_name():
		if not isEnemy:
			remove_ally_highlights()
		else:
			remove_enemy_highlights()
			
		set_selected_character(null, isEnemy)
		
	else:
		if not isEnemy:
			remove_ally_highlights()
			character.selectedAlly.show()
		else:
			remove_enemy_highlights()
			character.selectedEnemy.show()
			
		set_selected_character(character, isEnemy)
		
func set_selected_character(character, isEnemy: bool) -> void:
	if isEnemy:
		CombatMapStatus.set_selected_enemy(character)
	else:
		CombatMapStatus.set_selected_ally(character)

func get_tile_from_coords(coords: Vector2):
	for tile in mapTileGroup.get_children():
		if tile.get_coords() == coords:
			return tile

	return null

func set_tile_populated(coords: Vector2, value: bool) -> void:
	get_tile_from_coords(coords).set_is_populated(value)

# Set selected MapTile
func tile_handler(mapTile) -> void:
	if CombatMapStatus.get_selected_map_tile() == mapTile:
		remove_selected()
		CombatMapStatus.set_selected_map_tile(null)
	else:
		CombatMapStatus.set_selected_map_tile(mapTile)
		remove_selected()
		mapTile.selected.show()

# Buttons updater
func update_buttons() -> void:
	update_move_button()
	update_phys_attack_button()
	update_end_turn_button()

func update_move_button() -> void:
	if CombatMapStatus.get_selected_character() == null or CombatMapStatus.get_selected_map_tile() == null:
		moveButton.disabled = true
		
	elif validate_move(CombatMapStatus.get_selected_character(), CombatMapStatus.get_selected_map_tile()):
		moveButton.disabled = false
		
	else:
		moveButton.disabled = true

func update_phys_attack_button() -> void:
	if CombatMapStatus.get_selected_character() == null or CombatMapStatus.get_selected_enemy() == null:
		physAttackButton.disabled = true
	elif calc_distance(CombatMapStatus.get_selected_character().get_map_coords(), CombatMapStatus.get_selected_enemy().get_map_coords()) <= CombatMapStatus.get_selected_character().get_range():
		physAttackButton.disabled = false
	else:
		physAttackButton.disabled = true

func update_end_turn_button() -> void:
	if CombatMapStatus.get_selected_character().is_enemy():
		endTurnButton.disabled = true
		
	else:
		endTurnButton.disabled = false

# Player movement
func _on_move_button_pressed():
	var selChar = CombatMapStatus.get_selected_character()
	if validate_move(selChar, CombatMapStatus.get_selected_map_tile()):
		var tile_coords = CombatMapStatus.get_selected_map_tile().get_coords()
		var old_char_coords = CombatMapStatus.get_selected_character().get_map_coords()
		
		selChar.position = Vector3(tile_coords.x, 0.5, tile_coords.y)
		selChar.set_map_coords(Vector2(tile_coords.x, tile_coords.y))
		selChar.modify_current_movement(-calc_distance(old_char_coords, tile_coords))
		
		# Deselect mapTile
		CombatMapStatus.set_selected_map_tile(null)
		set_tile_populated(old_char_coords, false)
		set_tile_populated(tile_coords, true)
		# Remove highlights
		#remove_char_highlights()
		#remove_enemy_highlights()
		remove_highlights()
		highlight_movement(selChar)
		remove_selected()

func validate_move(character, mapTile) -> bool:
	var result = true
	
	if calc_distance(character.get_map_coords(), mapTile.get_coords()) > character.get_movement():
		result = false
	
	if mapTile.is_populated():
		result = false
		
	if not mapTile.is_traversable():
		result = false
	
	return result

func calc_distance(vect_1: Vector2, vect_2: Vector2) -> int:
	return abs(vect_1.x - vect_2.x) + abs(vect_1.y - vect_2.y)

func highlight_movement(character) -> void:
	var char_coords = character.get_map_coords()
	var mov = character.get_current_mov()
	
	var min_x = max(char_coords.x - mov, 0)
	var max_x = min(char_coords.x + mov, CombatMapStatus.get_map_x())
	
	var min_y = max(char_coords.y - mov, 0)
	var max_y = min(char_coords.y + mov, CombatMapStatus.get_map_y())
	
	for i in range(min_x, max_x + 1):
		for j in range(min_y, max_y + 1):
			if calc_distance(char_coords, Vector2(i,j)) <= mov:
				var sel_tile = get_tile_from_coords(Vector2(i, j))
				if sel_tile != null and !sel_tile.is_populated() and sel_tile.is_traversable():
					sel_tile.highlighted.show()

func remove_highlights() -> void:
	for tile in mapTileGroup.get_children():
		tile.highlighted.hide()

func remove_selected() -> void:
	for tile in mapTileGroup.get_children():
		tile.selected.hide()
		
func remove_char_highlights() -> void:
	for character in characterGroup.get_children():
		character.selectedChar.hide()

func remove_ally_highlights() -> void:
	for character in characterGroup.get_children():
		character.selectedAlly.hide()
		
func remove_enemy_highlights() -> void:
	for enemy in enemyGroup.get_children():
		enemy.selectedEnemy.hide()

func _on_phys_attack_button_pressed():
	# TODO Differenciate ranged and melee
	# TODO MapMod
	if CombatMapStatus.get_selected_character().is_ranged():
		CombatMapStatus.set_combat(CombatMapStatus.get_selected_character(), CombatMapStatus.get_selected_enemy(), "ranged", 0)
	else:
		CombatMapStatus.set_combat(CombatMapStatus.get_selected_character(), CombatMapStatus.get_selected_enemy(), "melee", 0)
	get_tree().change_scene_to_file("res://Scenes/3D/combat.tscn")

func _on_end_turn_button_pressed():
	CombatMapStatus.advance_ini()
	await start_turn()

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

# Debug
@onready
var debugLabel = $UI/Debug/DebugLabel

func update_debug_label():
	debugLabel.text = "selectedCharacter\n"
	if CombatMapStatus.get_selected_character() == null:
		debugLabel.text += "null"
	else:
		debugLabel.text += "name: " + CombatMapStatus.get_selected_character().get_char_name()
		debugLabel.text += "\ncoords: " + str(CombatMapStatus.get_selected_character().get_map_coords())
		debugLabel.text += "\nhealth: " + str(CombatMapStatus.get_selected_character().get_current_health())
		debugLabel.text += "\ncurrentMov: " + str(CombatMapStatus.get_selected_character().get_current_mov())
		
	debugLabel.text += "\n--------------\nselectedAlly\n"
	if CombatMapStatus.get_selected_ally() == null:
		debugLabel.text += "null"
	else:
		debugLabel.text += "name: " + CombatMapStatus.get_selected_ally().get_char_name()
		debugLabel.text += "\ncoords: " + str(CombatMapStatus.get_selected_ally().get_map_coords())
		debugLabel.text += "\nhealth: " + str(CombatMapStatus.get_selected_ally().get_current_health())
		debugLabel.text += "\ncurrentMov: " + str(CombatMapStatus.get_selected_ally().get_current_mov())
		
	debugLabel.text += "\n--------------\nselectedEnemy\n"
	if CombatMapStatus.get_selected_enemy() == null:
		debugLabel.text += "null"
	else:
		debugLabel.text += "name: " + CombatMapStatus.get_selected_enemy().get_char_name()
		debugLabel.text += "\ncoords: " + str(CombatMapStatus.get_selected_enemy().get_map_coords())
		debugLabel.text += "\nhealth: " + str(CombatMapStatus.get_selected_enemy().get_current_health())
		debugLabel.text += "\ncurrentMov: " + str(CombatMapStatus.get_selected_character().get_current_mov())
		
	debugLabel.text += "\n--------------\nselectedMapTile\n"
	if CombatMapStatus.get_selected_map_tile() == null:
		debugLabel.text += "null"
	else:
		debugLabel.text += "coords: " + str(CombatMapStatus.get_selected_map_tile().get_coords())
		debugLabel.text += "\nisPopulated: " + str(CombatMapStatus.get_selected_map_tile().is_populated())
		debugLabel.text += "\nname: " + str(CombatMapStatus.get_selected_map_tile().get_name())


	debugLabel.text += "\n--------------\ncombatMapStatus\n"
	debugLabel.text += "initiative: " + str(CombatMapStatus.get_initiative())
	debugLabel.text += "\ncurrentInitative: " + str(CombatMapStatus.get_current_turn_char())

extends Node3D

@onready
var cameraPivot = $Utility/CameraPivot
@onready
var camera = $Utility/CameraPivot/Camera3D
@onready
var mapTileGroup = $MapTileGroup
@onready
var moveButton = $UI/Debug/MoveButton

# Called when the node enters the scene tree for the first time.
func _ready():
	cameraPivot.position = Vector3(GameStatus.get_map_x()/2, 0, GameStatus.get_map_y()/2)
	camera.position = Vector3(0,0,GameStatus.get_map_x())
	
	for x in GameStatus.get_map_x():
		for y in GameStatus.get_map_y():
			var mapTile = Factory.MapTile.create({
				"coords": Vector2(x,y),
				"height": 0,
				"isPopulated": false,
				"isTraversable": false,
				"isObstacle": false,
				"meshPath": null
			})
			
			mapTileGroup.add_child(mapTile)
			mapTile.translate(Vector3(x, mapTile.get_height(), y))
			mapTile.connect("tile_selected", Callable(self, "tile_handler"))
	
	var i = 0
	for character in GameStatus.get_party():
		var partyMember = GameStatus.get_party_member(character)
		partyMember.scale *= Vector3(0.5, 0.5, 0.5)
		partyMember.position = Vector3(0, 0, i)
		partyMember.set_map_coords(Vector2(0, i))
		add_child(partyMember)
		
		partyMember.set_is_enemy(false)
		partyMember.connect("character_selected", Callable(self, "character_handler"))
		
		set_tile_populated(Vector2(0, i), true)
		
		i += 1
		
	i = 0
	for character in GameStatus.get_enemies():
		var enemy = GameStatus.get_enemy(character)
		enemy.scale *= Vector3(0.5, 0.5, 0.5)
		enemy.position = Vector3(GameStatus.get_map_x() - 1, 0, GameStatus.get_map_y() - i - 1)
		enemy.set_map_coords(Vector2(GameStatus.get_map_x(), GameStatus.get_map_y() - i))
		add_child(enemy)
		
		enemy.set_is_enemy(true)
		enemy.connect("character_selected", Callable(self, "character_handler"))
		
		set_tile_populated(Vector2(GameStatus.get_map_x() - 1, GameStatus.get_map_y() - 1 - i), true)
		
		i += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameStatus.debugMode:
		update_debug_label()
		
	update_buttons()
	
# Set selected enemies
func character_handler(character) -> void:
	if character.is_enemy():
		selected_checker(character, GameStatus.get_selected_enemy(), character.is_enemy())
	else:
		selected_checker(character, GameStatus.get_selected_character(), character.is_enemy())

func selected_checker(character, gameStatusCharacter, isEnemy: bool) -> void:
	if gameStatusCharacter == null:
		set_selected_character(character, isEnemy)
		if not isEnemy:
			highlight_movement(character)
	elif gameStatusCharacter.get_name() == character.get_name():
		if not isEnemy:
			remove_highlights()
		set_selected_character(null, isEnemy)
	else:
		if not isEnemy:
			remove_highlights()
		set_selected_character(character, isEnemy)
		if not isEnemy:
			highlight_movement(character)
		
func set_selected_character(character, isEnemy: bool) -> void:
	if isEnemy:
		GameStatus.set_selected_enemy(character)
	else:
		GameStatus.set_selected_character(character)

# Set populated MapTile
func get_tile_from_coords(coords: Vector2):
	for tile in mapTileGroup.get_children():
		if tile.get_coords() == coords:
			return tile
			
	print("tile {tile} not found".format({"tile": str(coords)}))
	return null

func set_tile_populated(coords: Vector2, value: bool) -> void:
	get_tile_from_coords(coords).set_is_populated(value)

# Set selected MapTile
func tile_handler(mapTile) -> void:
	if GameStatus.get_selected_map_tile() == mapTile:
		GameStatus.set_selected_map_tile(null)
	else:
		GameStatus.set_selected_map_tile(mapTile)

# Buttons updater
func update_buttons() -> void:
	if GameStatus.get_selected_character() == null or GameStatus.get_selected_map_tile() == null:
		moveButton.disabled = true
		
	elif validate_move(GameStatus.get_selected_character(), GameStatus.get_selected_map_tile()):
		moveButton.disabled = false
		
	else:
		moveButton.disabled = true

# Player movement
func _on_move_button_pressed():
	if validate_move(GameStatus.get_selected_character(), GameStatus.get_selected_map_tile()):
		var tile_coords = GameStatus.get_selected_map_tile().get_coords()
		GameStatus.get_selected_character().position = Vector3(tile_coords.x, 0.5, tile_coords.y)
		GameStatus.get_selected_character().set_map_coords(Vector2(tile_coords.x, tile_coords.y))
		
		# Deselect mapTile
		GameStatus.set_selected_map_tile(null)
		# TODO Remove once movement is capped per round
		GameStatus.set_selected_character(null)
		# Remove highlights
		remove_highlights()

func validate_move(character, mapTile) -> bool:
	var result = true
	
	if calc_distance(character.get_map_coords(), mapTile.get_coords()) > character.get_movement():
		result = false
	
	if mapTile.is_populated():
		result = false

	return result

func calc_distance(vect_1: Vector2, vect_2: Vector2) -> int:
	return abs(vect_1.x - vect_2.x) + abs(vect_1.y - vect_2.y)

func highlight_movement(character) -> void:
	var char_coords = character.get_map_coords()
	var mov = character.get_movement()
	
	var min_x = max(char_coords.x - mov, 0)
	var max_x = min(char_coords.x + mov, GameStatus.get_map_x())
	
	var min_y = max(char_coords.y - mov, 0)
	var max_y = min(char_coords.y + mov, GameStatus.get_map_y())
	
	for i in range(min_x, max_x + 1):
		for j in range(min_y, max_y + 1):
			if calc_distance(char_coords, Vector2(i,j)) <= mov:
				var sel_tile =get_tile_from_coords(Vector2(i, j))
				if sel_tile != null:
					sel_tile.selected.show()

func remove_highlights() -> void:
	for tile in mapTileGroup.get_children():
		tile.selected.hide()

# Debug
@onready
var debugLabel = $UI/Debug/DebugLabel

func update_debug_label():
	debugLabel.text = "selectedCharacter\n"
	if GameStatus.get_selected_character() == null:
		debugLabel.text += "null"
	else:
		debugLabel.text += "name: " + GameStatus.get_selected_character().get_char_name()
		debugLabel.text += "\ncoords: " + str(GameStatus.get_selected_character().get_map_coords())
		
	debugLabel.text += "\n--------------\nselectedEnemy\n"
	if GameStatus.get_selected_enemy() == null:
		debugLabel.text += "null"
	else:
		debugLabel.text += "name: " + GameStatus.get_selected_enemy().get_char_name()
		debugLabel.text += "\ncoords: " + str(GameStatus.get_selected_enemy().get_map_coords())
		
	debugLabel.text += "\n--------------\nselectedMapTile\n"
	if GameStatus.get_selected_map_tile() == null:
		debugLabel.text += "null"
	else:
		debugLabel.text += "coords: " + str(GameStatus.get_selected_map_tile().get_coords())
		debugLabel.text += "\nisPopulated: " + str(GameStatus.get_selected_map_tile().is_populated())

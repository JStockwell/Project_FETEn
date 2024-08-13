extends Node3D

@onready
var cameraPivot = $Utility/CameraPivot
@onready
var camera = $Utility/CameraPivot/Camera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	cameraPivot.position = Vector3(CombatMapStatus.get_map_x()/2, 0, CombatMapStatus.get_map_y()/2)
	camera.position = Vector3(0,0,CombatMapStatus.get_map_x())
	
	for x in CombatMapStatus.get_map_x():
		for y in CombatMapStatus.get_map_y():
			var mapTile = Factory.MapTile.create({
				"coords": Vector2(x,y),
				"height": 0,
				"isPopulated": false,
				"isTraversable": false,
				"isObstacle": false,
				"meshPath": null
			})
			
			add_child(mapTile)
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
		i += 1
		
	i = 0
	for character in GameStatus.get_enemies():
		var enemy = GameStatus.get_enemy(character)
		enemy.scale *= Vector3(0.5, 0.5, 0.5)
		enemy.position = Vector3(CombatMapStatus.get_map_x() - 1, 0, CombatMapStatus.get_map_y() - i - 1)
		enemy.set_map_coords(Vector2(CombatMapStatus.get_map_x(), CombatMapStatus.get_map_y() - i))
		add_child(enemy)
		
		enemy.set_is_enemy(true)
		enemy.connect("character_selected", Callable(self, "character_handler"))
		i += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_debug_label()
	
# Set selected enemies
func character_handler(character) -> void:
	if character.is_enemy():
		selected_checker(character, GameStatus.get_selected_enemy(), character.is_enemy())
	else:
		selected_checker(character, GameStatus.get_selected_character(), character.is_enemy())

func selected_checker(character, gameStatusCharacter, isEnemy: bool) -> void:
	if gameStatusCharacter == null:
		set_selected_character(character, isEnemy)
	elif gameStatusCharacter.get_name() == character.get_name():
		set_selected_character(null, isEnemy)
	else:
		set_selected_character(character, isEnemy)
		
func set_selected_character(character, isEnemy: bool) -> void:
	if isEnemy:
		GameStatus.set_selected_enemy(character)
	else:
		GameStatus.set_selected_character(character)

# Set selected MapTile
func tile_handler(mapTile) -> void:
	if GameStatus.get_selected_map_tile() == mapTile:
		GameStatus.set_selected_map_tile(null)
	else:
		GameStatus.set_selected_map_tile(mapTile)

# Player movement
@onready
var moveButton = $UI/Debug/MoveButton

func _on_move_button_pressed():
	var sel_char = GameStatus.get_selected_character()
	if sel_char != null and GameStatus.get_selected_map_tile() != null:
		var tile_coords = GameStatus.get_selected_map_tile().get_coords()
		sel_char.position = Vector3(tile_coords.x, 0, tile_coords.y)

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
		
	debugLabel.text += "\nselectedEnemy\n"
	if GameStatus.get_selected_enemy() == null:
		debugLabel.text += "null"
	else:
		debugLabel.text += "name: " + GameStatus.get_selected_enemy().get_char_name()
		debugLabel.text += "\ncoords: " + str(GameStatus.get_selected_enemy().get_map_coords())
		
	debugLabel.text += "\nselectedMapTile\n"
	if GameStatus.get_selected_map_tile() == null:
		debugLabel.text += "null"
	else:
		debugLabel.text += "coords: " + str(GameStatus.get_selected_map_tile().get_coords())

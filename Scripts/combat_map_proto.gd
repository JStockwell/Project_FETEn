extends Node3D

var mapTile = preload("res://Scenes/map_tile.tscn")
var character = preload("res://Scenes/character.tscn")

@onready
var cameraPivot = $Pivot

@onready
var camera = $Pivot/Camera3D

@onready
var lastMapTileLabel = $Debug/LastMapTileLabel

@onready
var inMapTileLabel = $Debug/InMapTileLabel

@onready
var mapHighlight = $Highlight

@onready
var selectedTileLabel = $Debug/SelectedTileLabel

@onready
var populatedPlayerTilesLabel = $Debug/PlayerPopulatedTilesLabel

@onready
var debugGroup = $Debug

@onready
var selectedPlayerLabel = $Debug/SelectedPlayerLabel

@onready
var characterRoot = $Characters

@onready
var moveButton = $MoveButton

@export
var debugMode = true

@export
var mapSize = 5

func _ready():
	if debugMode:
		debugGroup.show()

	for i in range(mapSize):
		for j in range(mapSize):
			var instance = mapTile.instantiate()
			add_child(instance)
			instance.position = Vector3(i * 2, 0, j * 2)
			instance.set_coords(i,j)
			
	var counter = 0
	for player in GameStatus.party:
		var instance = character.instantiate()
		characterRoot.add_child(instance)
		
		instance.position = Vector3(0, 1, counter * 2.0)
		
		GameStatus.party[player]["map_position"] = Vector2(0, counter)
		MapStatus.populate_player_tile(Vector2(0, counter))
		
		instance.set_stats(GameStatus.party[player])
		instance.set_map_position(Vector2(0, counter))
		instance.set_map_mode(true)
		
		counter += 1
	
	cameraPivot.position = Vector3(mapSize - 1, 0, mapSize - 0.9)
	camera.position.z = mapSize * 2.5

func _process(delta):
	if debugMode:
		debug_text()
		
	if MapStatus.get_selected_player() != "null" and MapStatus.selectedTile != null:
		moveButton.show()
		
	else:
		moveButton.hide()

func _input(event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and MapStatus.inMapTile:
		if MapStatus.selectedTile == null and MapStatus.check_tile_player_populated(MapStatus.lastMapTile):
			MapStatus.set_selected_tile(MapStatus.lastMapTile)
			mapHighlight.position = Vector3(MapStatus.selectedTile.x * 2,0,MapStatus.selectedTile.y * 2)
			mapHighlight.show()
		
		elif not MapStatus.check_tile_player_populated(MapStatus.lastMapTile):
			return
		
		elif MapStatus.selectedTile.x == MapStatus.lastMapTile.x and MapStatus.selectedTile.y == MapStatus.lastMapTile.y:
			MapStatus.set_selected_tile(null)
			mapHighlight.hide()

func array_to_string(arr: Array) -> String:
	var s = ""
	for i in arr:
		s += str(i)
	return s

func debug_text() -> void:
	lastMapTileLabel.text = "({x},{y})".format({"x": MapStatus.lastMapTile.x,"y": MapStatus.lastMapTile.y})
	inMapTileLabel.text = str(MapStatus.inMapTile)
	if MapStatus.selectedTile != null:
		selectedTileLabel.text = "({x},{y})".format({"x": MapStatus.selectedTile.x,"y": MapStatus.selectedTile.y})
	else:
		selectedTileLabel.text = "null"
		
	populatedPlayerTilesLabel.text = "[{array}]".format({"array": array_to_string(MapStatus.playerPopulatedTiles)})
	selectedPlayerLabel.text = MapStatus.selectedPlayer


func select_instanciated_player(playerName):
	for character in characterRoot.get_children():
		if character["characterName"] == playerName:
			return character


func _on_move_button_pressed():
	if MapStatus.selectedPlayer != null and MapStatus.selectedTile != null:
		var player = select_instanciated_player(MapStatus.selectedPlayer)
		var selectedTile = MapStatus.selectedTile
		
		if verify_move(player, selectedTile):
			# Move player
			player.position = Vector3(selectedTile.x * 2, 1, selectedTile.y * 2)
			# Remove map position list
			MapStatus.remove_player_tile(player.get_map_position())
			# Set player internal position and map position list
			player.set_map_position(Vector2(selectedTile.x, selectedTile.y))
			MapStatus.populate_player_tile(player.get_map_position())
			# Deselect
			MapStatus.set_selected_tile(null)
			MapStatus.set_selected_player("null")
			mapHighlight.hide()
			
		else:
			print("move not allowed")

func verify_move(player, tile) -> bool:
	var playerPosition = player.get_map_position()
	var distance = absi(playerPosition.x - tile.x) + absi(playerPosition.y - tile.y)
	
	if distance > player["movement"]:
		return false
	else:
		return true

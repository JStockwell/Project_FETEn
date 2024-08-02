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
var selectedEnemyLabel = $Debug/SelectedEnemyLabel

@onready
var characterRoot = $Characters

@onready
var moveButton = $MoveButton

@onready
var attackButton = $AttackButton

@onready
var enemyRoot = $Enemies

@export
var debugMode = true

@export
var mapSize = 5

func _ready():
	attackButton.hide()
	moveButton.hide()
	
	MapStatus.set_selected_enemy("null")
	MapStatus.set_selected_player("null")
	
	if debugMode:
		debugGroup.show()

	# Setup map size
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
		
		if GameStatus.party[player]["map_position"] == null:
			instance.position = Vector3(0, 1, counter * 2.0)
			
			GameStatus.party[player]["map_position"] = Vector2(0, counter)
			MapStatus.populate_player_tile(Vector2(0, counter))
			
			instance.set_is_player(true)
			instance.set_stats(GameStatus.party[player])
			instance.set_map_position(Vector2(0, counter))
			
		else:
			var map_pos = GameStatus.party[player]["map_position"]
			instance.position = Vector3(map_pos.x * 2, 1, map_pos.y * 2)
			instance.set_is_player(true)
			instance.set_stats(GameStatus.party[player])
			instance.set_map_position(map_pos)
			
		instance.set_map_mode(true)
		
		counter += 1
		
	var enemyCounter = 0
	for enemy in GameStatus.enemies:
		var instance = character.instantiate()
		enemyRoot.add_child(instance)
		
		instance.position = Vector3((mapSize - 1) * 2, 1, (mapSize - 1 - enemyCounter) * 2)
		instance.rotation.y = PI
		
		GameStatus.enemies[enemy]["map_position"] = Vector2(mapSize - 1, mapSize - 1 - enemyCounter)
		MapStatus.populate_enemy_tile(Vector2(mapSize - 1, mapSize - 1 - enemyCounter))
		
		instance.set_stats(GameStatus.enemies[enemy])
		instance.set_map_position(Vector2(mapSize - 1, mapSize - 1 - enemyCounter))
		instance.set_map_mode(true)
		
		enemyCounter += 1
	
	cameraPivot.position = Vector3(mapSize - 1, 0, mapSize - 0.9)
	camera.position.z = mapSize * 2.5

func _process(delta):
	if debugMode:
		debug_text()
		
	if MapStatus.get_selected_player() != "null" and MapStatus.selectedTile != null:
		moveButton.show()
	else:
		moveButton.hide()
		
	if MapStatus.get_selected_enemy() != "null" and MapStatus.get_selected_player() != "null":
		if calculate_combat_distance():
			attackButton.show()
		else:
			attackButton.hide()

func _input(event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and MapStatus.inMapTile:
		if MapStatus.selectedTile == null and MapStatus.check_tile_populated(MapStatus.lastMapTile):
			MapStatus.set_selected_tile(MapStatus.lastMapTile)
			mapHighlight.position = Vector3(MapStatus.selectedTile.x * 2,0,MapStatus.selectedTile.y * 2)
			mapHighlight.show()
		
		elif not MapStatus.check_tile_populated(MapStatus.lastMapTile):
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
	selectedEnemyLabel.text = MapStatus.selectedEnemy


func select_instanciated_player(playerName):
	for character in characterRoot.get_children():
		if character["characterName"] == playerName:
			return character

func select_instanciated_enemy(enemyName):
	for enemy in enemyRoot.get_children():
		if enemy["characterName"] == enemyName:
			return enemy


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
			GameStatus.party[player.get_stats()["name"]] = player.get_stats()
			MapStatus.populate_player_tile(player.get_map_position())
			# Deselect
			MapStatus.set_selected_tile(null)
			MapStatus.set_selected_player("null")
			mapHighlight.hide()
			
		else:
			print("move not allowed")

func verify_move(player, tile) -> bool:
	var playerPosition = player.get_map_position()
	var distance = point_distance(playerPosition, tile)
	
	if distance > player["movement"]:
		return false
	else:
		return true
		
func calculate_combat_distance():
	var player_pos = select_instanciated_player(MapStatus.get_selected_player()).get_map_position()
	var enemy_pos = select_instanciated_enemy(MapStatus.get_selected_enemy()).get_map_position()
	
	if point_distance(player_pos, enemy_pos) <= select_instanciated_player(MapStatus.get_selected_player())["movement"]:
		return true
	else:
		false

func point_distance(vec1: Vector2, vec2: Vector2) -> int:
	return absi(vec1.x - vec2.x) + absi(vec1.y - vec2.y)


func _on_attack_button_pressed():
	GameStatus.set_active_player(GameStatus.party[MapStatus.get_selected_player()])
	GameStatus.set_active_enemy(MapStatus.get_selected_enemy(), GameStatus.enemies[MapStatus.get_selected_enemy()])
	get_tree().change_scene_to_file("res://Scenes/combat_proto.tscn")

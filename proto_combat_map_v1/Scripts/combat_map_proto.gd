extends Node3D

var mapTile = preload("res://proto_combat_map_v1/Scenes/map_tile.tscn")
var character = preload("res://proto_combat_map_v1/Scenes/character.tscn")

@onready
var cameraPivot = $Pivot

@onready
var camera = $Pivot/Camera3D

@onready
var mapHighlight = $Highlight

@onready
var characterRoot = $Characters

@onready
var enemyRoot = $Enemies

@onready
var debugLabel = $UI/DebugLabel

@onready
var moveButton = $UI/MoveButton

@onready
var attackButton = $UI/AttackButton

@onready
var playerStatsLabel = $UI/PlayerStatsLabel

@onready
var enemyStatsLabel = $UI/EnemyStatsLabel

@export
var debugMode = true

@export
var mapSize = 5

func _ready():
	attackButton.hide()
	moveButton.hide()
	
	MapStatus_map_v1.set_selected_enemy("null")
	MapStatus_map_v1.set_selected_player("null")
	
	if debugMode:
		debugLabel.show()
		
	# Min map size
	if mapSize < len(GameStatus_map_v1.enemies.keys()):
		mapSize = len(GameStatus_map_v1.enemies.keys())

	# Setup map size
	for i in range(mapSize):
		for j in range(mapSize):
			var instance = mapTile.instantiate()
			add_child(instance)
			instance.position = Vector3(i * 2, 0, j * 2)
			instance.set_coords(i,j)
			
	
	var counter = 0
	for player in GameStatus_map_v1.party:
		if GameStatus_map_v1.party[player]["current_health"] > 0:
			var instance = character.instantiate()
			characterRoot.add_child(instance)
			
			if GameStatus_map_v1.party[player]["map_position"] == null:
				instance.position = Vector3(0, 1, counter * 2.0)
				
				GameStatus_map_v1.party[player]["map_position"] = Vector2(0, counter)
				MapStatus_map_v1.populate_player_tile(Vector2(0, counter))
				
				instance.set_stats(GameStatus_map_v1.party[player])
				instance.set_map_position(Vector2(0, counter))
				
			else:
				var map_pos = GameStatus_map_v1.party[player]["map_position"]
				instance.position = Vector3(map_pos.x * 2, 1, map_pos.y * 2)
				instance.set_stats(GameStatus_map_v1.party[player])
				instance.set_map_position(map_pos)
				
			instance.set_is_player(true)
			instance.set_map_mode(true)
		
		counter += 1
		
	var enemyCounter = 0
	for enemy in GameStatus_map_v1.enemies:
		if GameStatus_map_v1.enemies[enemy]["current_health"] > 0:
			var instance = character.instantiate()
			enemyRoot.add_child(instance)
			instance.rotation.y = PI
			
			if GameStatus_map_v1.enemies[enemy]["map_position"] == null:
				instance.position = Vector3((mapSize - 1) * 2, 1, (mapSize - 1 - enemyCounter) * 2)
				
				GameStatus_map_v1.enemies[enemy]["map_position"] = Vector2(mapSize - 1, mapSize - 1 - enemyCounter)
				MapStatus_map_v1.populate_enemy_tile(Vector2(mapSize - 1, mapSize - 1 - enemyCounter))
				
				instance.set_stats(GameStatus_map_v1.enemies[enemy])
				instance.set_map_position(Vector2(mapSize - 1, mapSize - 1 - enemyCounter))
				
			else:
				var map_pos = GameStatus_map_v1.enemies[enemy]["map_position"]
				instance.position = Vector3(map_pos.x * 2, 1, map_pos.y * 2)
				instance.set_stats(GameStatus_map_v1.enemies[enemy])
				instance.set_map_position(map_pos)
				
			instance.set_map_mode(true)
		
		enemyCounter += 1
	
	cameraPivot.position = Vector3(mapSize - 1, 0, mapSize - 0.9)
	camera.position.z = mapSize * 2.5

func _process(delta):
	if debugMode:
		debug_text()
		
	if MapStatus_map_v1.get_selected_player() != "null" and MapStatus_map_v1.selectedTile != null:
		moveButton.show()
	else:
		moveButton.hide()
		
	if MapStatus_map_v1.get_selected_enemy() != "null" and MapStatus_map_v1.get_selected_player() != "null":
		if calculate_combat_distance():
			attackButton.show()
		else:
			attackButton.hide()
			
	if MapStatus_map_v1.get_selected_player() != "null":
		set_character_stats_label(GameStatus_map_v1.party[MapStatus_map_v1.get_selected_player()], playerStatsLabel)
		
	else:
		playerStatsLabel.hide()
		
	if MapStatus_map_v1.get_selected_enemy() != "null":
		set_character_stats_label(GameStatus_map_v1.enemies[MapStatus_map_v1.get_selected_enemy()], enemyStatsLabel)
		
	else:
		enemyStatsLabel.hide()

func _input(event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and MapStatus_map_v1.inMapTile:
		if MapStatus_map_v1.selectedTile == null and MapStatus_map_v1.check_tile_populated(MapStatus_map_v1.lastMapTile):
			MapStatus_map_v1.set_selected_tile(MapStatus_map_v1.lastMapTile)
			mapHighlight.position = Vector3(MapStatus_map_v1.selectedTile.x * 2,0,MapStatus_map_v1.selectedTile.y * 2)
			mapHighlight.show()
		
		elif not MapStatus_map_v1.check_tile_populated(MapStatus_map_v1.lastMapTile):
			return
		
		elif MapStatus_map_v1.selectedTile.x == MapStatus_map_v1.lastMapTile.x and MapStatus_map_v1.selectedTile.y == MapStatus_map_v1.lastMapTile.y:
			MapStatus_map_v1.set_selected_tile(null)
			mapHighlight.hide()

func set_character_stats_label(selectedPlayer, label):
	var playerStatsLabelDict = {
		"name": selectedPlayer["name"],
		"hp": selectedPlayer["max_health"],
		"curr_hp": selectedPlayer["current_health"],
		"att": selectedPlayer["attack"],
		"def": selectedPlayer["defense"],
		"mov": selectedPlayer["movement"]
	}
	label.text = "Name: {name}\nMax HP: {hp}\nCurrent HP: {curr_hp}\nAttack: {att}\nDefense: {def}\nMovement: {mov}".format(playerStatsLabelDict)
	label.show()

func array_to_string(arr: Array) -> String:
	var s = ""
	for i in arr:
		s += str(i) + ", "
	return s.left(s.length() - 2)

func debug_text() -> void:
	var debugTexts = {
		"last_x": MapStatus_map_v1.lastMapTile.x,
		"last_y": MapStatus_map_v1.lastMapTile.y,
		"sel_x": "null",
		"sel_y": "null",
		"in_map": str(MapStatus_map_v1.inMapTile),
		"player_array": array_to_string(MapStatus_map_v1.playerPopulatedTiles),
		"enemy_array": array_to_string(MapStatus_map_v1.enemyPopulatedTiles),
		"sel_player": MapStatus_map_v1.selectedPlayer,
		"sel_enemy": MapStatus_map_v1.selectedEnemy
	}
	
	if MapStatus_map_v1.selectedTile != null:
		debugTexts["sel_x"] = MapStatus_map_v1.selectedTile.x
		debugTexts["sel_y"] = MapStatus_map_v1.selectedTile.y
	
	var dText = "lastMapTile:({last_x}, {last_y})\nselectedTile: ({sel_x}, {sel_y})\ninMapTile: {in_map}\n"
	dText += "playerPopulatedTiles: {player_array}\nenemyPopulatedTiles: {enemy_array}\nselectedPlayer: {sel_player}\nselectedEnemy: {sel_enemy}"
	
	debugLabel.text = dText.format(debugTexts)


func select_instanciated_player(playerName):
	for character in characterRoot.get_children():
		if character["characterName"] == playerName:
			return character

func select_instanciated_enemy(enemyName):
	for enemy in enemyRoot.get_children():
		if enemy["characterName"] == enemyName:
			return enemy


func _on_move_button_pressed():
	if MapStatus_map_v1.selectedPlayer != null and MapStatus_map_v1.selectedTile != null:
		var player = select_instanciated_player(MapStatus_map_v1.selectedPlayer)
		var selectedTile = MapStatus_map_v1.selectedTile
		
		if verify_move(player, selectedTile):
			# Move player
			player.position = Vector3(selectedTile.x * 2, 1, selectedTile.y * 2)
			# Remove map position list
			MapStatus_map_v1.remove_player_tile(player.get_map_position())
			# Set player internal position and map position list
			player.set_map_position(Vector2(selectedTile.x, selectedTile.y))
			GameStatus_map_v1.party[player.get_stats()["name"]] = player.get_stats()
			MapStatus_map_v1.populate_player_tile(player.get_map_position())
			# Deselect
			MapStatus_map_v1.set_selected_tile(null)
			MapStatus_map_v1.set_selected_player("null")
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
	var player_pos = select_instanciated_player(MapStatus_map_v1.get_selected_player()).get_map_position()
	var enemy_pos = select_instanciated_enemy(MapStatus_map_v1.get_selected_enemy()).get_map_position()
	
	if point_distance(player_pos, enemy_pos) <= 1:
		return true
	else:
		false

func point_distance(vec1: Vector2, vec2: Vector2) -> int:
	return absi(vec1.x - vec2.x) + absi(vec1.y - vec2.y)


func _on_attack_button_pressed():
	GameStatus_map_v1.set_active_player(GameStatus_map_v1.party[MapStatus_map_v1.get_selected_player()])
	GameStatus_map_v1.set_active_enemy(MapStatus_map_v1.get_selected_enemy(), GameStatus_map_v1.enemies[MapStatus_map_v1.get_selected_enemy()])
	get_tree().change_scene_to_file("res://proto_combat_map_v1/Scenes/combat_proto.tscn")

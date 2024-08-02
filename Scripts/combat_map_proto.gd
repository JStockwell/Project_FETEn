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
	#for player in GameStatus.party:
	for i in range(2):
		var instance = character.instantiate()
		add_child(instance)
		instance.position = Vector3(0, 1, counter * 2.0)
		MapStatus.populate_player_tile(Vector2(0, counter))
		counter += 1
	
	cameraPivot.position = Vector3(mapSize - 1, 0, mapSize - 0.9)
	camera.position.z = mapSize * 2.5

func _process(delta):
	if debugMode:
		debug_text()

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

func debug_text():
	lastMapTileLabel.text = "({x},{y})".format({"x": MapStatus.lastMapTile.x,"y": MapStatus.lastMapTile.y})
	inMapTileLabel.text = str(MapStatus.inMapTile)
	if MapStatus.selectedTile != null:
		selectedTileLabel.text = "({x},{y})".format({"x": MapStatus.selectedTile.x,"y": MapStatus.selectedTile.y})
	else:
		selectedTileLabel.text = "null"
		
	populatedPlayerTilesLabel.text = "[{array}]".format({"array": array_to_string(MapStatus.playerPopulatedTiles)})

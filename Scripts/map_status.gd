extends Node

var lastMapTile = Vector2(0,0)

var inMapTile = false

var selectedTile = null

var playerPopulatedTiles = []
var enemyPopulatedTiles = []

var selectedPlayer = "null"

func set_selected_player(name):
	selectedPlayer = name

func get_selected_player() -> String:
	return selectedPlayer

func set_last_map_tile(coords):
	lastMapTile = coords
	
func set_in_map_tile(value):
	inMapTile = value

func set_selected_tile(tile):
	selectedTile = tile

func populate_player_tile(tile):
	playerPopulatedTiles.append(tile)
	
func remove_player_tile(tile):
	playerPopulatedTiles.remove_at(playerPopulatedTiles.find(tile))

func check_tile_player_populated(tile: Vector2) -> bool:
	return playerPopulatedTiles.find(tile) == -1

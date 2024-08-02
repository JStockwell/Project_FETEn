extends Node

var lastMapTile = Vector2(0,0)

var inMapTile = false

var selectedTile = null

var playerPopulatedTiles = []
var enemyPopulatedTiles = []

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

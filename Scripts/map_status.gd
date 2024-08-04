extends Node

var lastMapTile = Vector2(0,0)

var inMapTile = false

var selectedTile = null

var playerPopulatedTiles = []
var enemyPopulatedTiles = []

var selectedPlayer = "null"
var selectedEnemy = "null"

func set_selected_player(name):
	selectedPlayer = name

func get_selected_player() -> String:
	return selectedPlayer
	
func set_selected_enemy(name):
	selectedEnemy = name

func get_selected_enemy() -> String:
	return selectedEnemy

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
	
func populate_enemy_tile(tile):
	enemyPopulatedTiles.append(tile)

func remove_enemy_tile(tile):
	enemyPopulatedTiles.remove_at(enemyPopulatedTiles.find(tile))

func check_tile_populated(tile: Vector2) -> bool:
	return playerPopulatedTiles.find(tile) == -1 and enemyPopulatedTiles.find(tile) == -1

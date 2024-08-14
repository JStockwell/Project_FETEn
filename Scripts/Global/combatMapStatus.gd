extends Node

var enemies: Dictionary

var mapX = 11
var mapY = 11

var selectedCharacter
var selectedEnemy
var selectedAlly
var selectedMapTile

var attackerStats: Dictionary
var defenderStats: Dictionary

var attackType: String
var mapMod: int
var attackSkill: String = ""

var isStartCombat: bool
var initiative: Array = []
var currentIni: int

var hasAttacked: bool

var mapTileMatrix: Array = []

# Enemy
func set_enemies(enemyList: Array) -> void:
	var counter = 0
	for enemy in enemyList:
		enemies[enemy + "_" + str(counter)] = GameStatus.enemySet[enemy].duplicate()
		counter += 1
		
func get_enemies() -> Dictionary:
	return enemies

func get_enemy(charName: String):
	if charName in enemies.keys():
		return enemies[charName]
		
	else:
		print("character {n} not in enemies".format({"n": charName}))

# Attacker and Defender
func set_active_characters(attack: Dictionary, defend: Dictionary) -> void:
	attackerStats = attack
	defenderStats = defend

func get_attacker_stats() -> Dictionary:
	return attackerStats

func get_defender_stats() -> Dictionary:
	return defenderStats

# Combat
func set_combat(char, enem, attType: String, mm: int, attSkill: String = "") -> void:
	set_active_characters(char.get_stats(), enem.get_stats())
	attackType = attType
	mapMod = mm
	if attSkill != "":
		attackSkill = attSkill

func is_start_combat() -> bool:
	return isStartCombat

func set_is_start_combat(value: bool) -> void:
	isStartCombat = value
	
func set_initiative(array: Array) -> void:
	initiative = array
	currentIni = 0
	
func get_current_turn_char():
	return initiative[currentIni]

func advance_ini() -> void:
	currentIni += 1
	if currentIni >= len(initiative):
		currentIni = 0

func set_has_attacked(value: bool) -> void:
	hasAttacked = value
	
#func set_map_active_character(character) -> void:
	#activeCharacter = character
	#
#func get_map_active_character():
	#return activeCharacter

# Selected Entities
func set_selected_character(character) -> void:
	selectedCharacter = character

func get_selected_character():
	return selectedCharacter

func set_selected_enemy(character) -> void:
	selectedEnemy = character

func get_selected_enemy():
	return selectedEnemy
	
func set_selected_ally(character) -> void:
	selectedAlly = character
	
func get_selected_ally():
	return selectedAlly
	
func set_selected_map_tile(mapTile) -> void:
	selectedMapTile = mapTile

func get_selected_map_tile():
	return selectedMapTile

# Map
func get_map_x() -> int:
	return mapX

func get_map_y() -> int:
	return mapY

func get_map_dimensions() -> Vector2:
	return Vector2(mapX, mapY)

func set_map_size(x: int, y: int) -> void:
	mapX = x
	mapY = y

func get_map_tile_matrix() -> Array:
	return mapTileMatrix

func add_map_tile_row(row: Array) -> void:
	mapTileMatrix.append(row)

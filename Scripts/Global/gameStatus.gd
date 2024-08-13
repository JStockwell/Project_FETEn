extends Node

# Map combat variables
var selectedCharacter
var selectedEnemy
var selectedMapTile

var attackerStats: Dictionary
var defenderStats: Dictionary

var playableCharacters: Dictionary
var enemySet: Dictionary

var skillSet: Dictionary
var party: Dictionary
var enemies: Dictionary

var mapX = 11
var mapY = 11

var debugMode = true

func set_playable_characters(characterDict: Dictionary) -> void:
	playableCharacters = characterDict
	
func set_party(playerList: Array) -> void:
	for member in playerList:
		party[member] = Factory.Character.create(playableCharacters[member])
		
func set_enemy_set(enemyDict: Dictionary) -> void:
	enemySet = enemyDict
	
func set_enemies(enemyList: Array) -> void:
	var counter = 0
	for enemy in enemyList:
		enemies[enemy + "_" + str(counter)] = Factory.Character.create(enemySet[enemy]).duplicate()
		counter += 1
		
func get_party() -> Dictionary:
	return party
	
func get_party_member(charName: String):
	if charName in party.keys():
		return party[charName]
		
	else:
		print("character {n} not in party".format({"n": charName}))

func get_enemies() -> Dictionary:
	return enemies
	
func get_enemy(charName: String):
	if charName in enemies.keys():
		return enemies[charName]
		
	else:
		print("character {n} not in enemies".format({"n": charName}))

func set_active_characters(attack: Dictionary, defend: Dictionary) -> void:
	attackerStats = attack
	defenderStats = defend
	
func get_attacker_stats() -> Dictionary:
	return attackerStats
	
func get_defender_stats() -> Dictionary:
	return defenderStats
	
func set_selected_character(character) -> void:
	selectedCharacter = character

func get_selected_character():
	return selectedCharacter

func set_selected_enemy(character) -> void:
	selectedEnemy = character

func get_selected_enemy():
	return selectedEnemy

# Combat map getters and Setters
func get_map_x() -> int:
	return mapX
	
func get_map_y() -> int:
	return mapY

func get_map_dimensions() -> Vector2:
	return Vector2(mapX, mapY)

func set_map_size(x: int, y: int) -> void:
	mapX = x
	mapY = y
	
func set_selected_map_tile(mapTile) -> void:
	selectedMapTile = mapTile
	
func get_selected_map_tile():
	return selectedMapTile

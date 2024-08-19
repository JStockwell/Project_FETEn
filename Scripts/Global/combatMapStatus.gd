extends Node

var maxCameraHeight = 33.75 # 16x16
var minCameraHeight = 20.6 # 9x9

var enemies: Dictionary

var mapSpawn: Vector3
var combatSpawn: Vector3
var mapX
var mapY
const MAX_MAP_DIMENSION = 15
const MIN_MAP_DIMENSION = 9

var selectedCharacter
var selectedEnemy
var selectedAlly
var selectedMapTile

var attackerStats: Dictionary
var defenderStats: Dictionary

var mapMod: int
var attackRange: int
var attackSkill: String = ""

var isStartCombat: bool
var initiative: Array = []
var currentIni: int

var hasAttacked: bool
var hasMoved: bool

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

func set_attack_skill(skillName: String) -> void:
	attackSkill = skillName

# Combat
func set_combat(char, enem, ran: int, mm: int, attSkill: String = "") -> void:
	set_active_characters(char.get_stats(), enem.get_stats())
	attackRange = ran
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

func get_initiative() -> Array:
	return initiative

func advance_ini() -> void:
	currentIni += 1
	if currentIni >= len(initiative):
		currentIni = 0
		
func get_current_ini() -> int:
	return currentIni

func set_current_ini(val: int) -> void:
	currentIni = val

func remove_character_ini(map_id: int) -> void:
	initiative.remove_at(initiative.find(map_id))

func set_has_attacked(value: bool) -> void:
	hasAttacked = value
	
func set_has_moved(value: bool) -> void:
	hasMoved = value

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
func calculate_map_spawn(spawn: Vector3) -> void:
	mapSpawn = Vector3(-mapX / 2, 0.5, -mapY / 2) + spawn
	
	if mapX % 2 == 0:
		mapSpawn.x += 0.5
		
	if mapY % 2 == 0:
		mapSpawn.z += 0.5
	
func get_map_spawn() -> Vector3:
	return mapSpawn
	
func set_combat_spawn(spawn: Vector3) -> void:
	combatSpawn = spawn
	
func get_combat_spawn() -> Vector3:
	return combatSpawn

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

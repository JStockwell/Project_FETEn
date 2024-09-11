extends Node

var stageId: String
var mapId: String

# TODO Implement properly post TFG
enum Status {START = 0, BATTLE = 1, CASTING = 2, END = 3, PAUSED = 4}
var currentStatus: int = Status.START

var maxCameraHeight = 33.75 # 16x16
var minCameraHeight = 20.6 # 9x9

var mapPath: String
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

var effectRange: int
var effectSkill: String = ""

var isStartCombat: bool
var initiative: Array = []
var currentIni: int

var hitBlocked: bool
var hasAttacked: bool
var hasMoved: bool

var mapTileMatrix: Array = []

func set_map_stage(myMapStage: String) -> void:
	stageId = myMapStage
	
func get_map_stage() -> String:
	return stageId

func set_map_id(myMapId: String) -> void:
	mapId = myMapId
	
func get_map_id() -> String:
	return mapId

func set_status(myStatus: int) -> void:
	currentStatus = myStatus
	
func get_status() -> int:
	return currentStatus

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
func set_combat(char, enem, ran: int, attSkill: String = "") -> void:
	set_active_characters(char.get_stats(), enem.get_stats())
	attackRange = ran
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
	var index = initiative.find(map_id)
	initiative.remove_at(index)
	
	if map_id == selectedCharacter.get_map_id():
		hasAttacked == false
		hasMoved == false
	
	if CombatMapStatus.get_current_ini() > index:
		CombatMapStatus.set_current_ini(CombatMapStatus.get_current_ini() - 1)
		
	if CombatMapStatus.get_current_ini() > len(CombatMapStatus.get_initiative()) - 1:
		CombatMapStatus.set_current_ini(CombatMapStatus.get_current_ini() - 1)

func set_has_attacked(value: bool) -> void:
	hasAttacked = value
	
func set_has_moved(value: bool) -> void:
	hasMoved = value
	
func set_hit_blocked(value: bool) -> void:
	hitBlocked = value
	
func is_hit_blocked() -> bool:
	return hitBlocked

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
func set_map_path(path: String) -> void:
	mapPath = path
	
func get_map_path() -> String:
	return mapPath
	
func calculate_map_spawn(spawn: Vector3) -> void:
	mapSpawn = Vector3(-mapX / 2 + 0.5, 0.5, -mapY / 2) + spawn

func set_map_spawn(vector: Vector3) -> void:
	mapSpawn = vector

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

func set_map_size(vec: Vector2) -> void:
	mapX = vec.x
	mapY = vec.y

func get_map_tile_matrix() -> Array:
	return mapTileMatrix

func add_map_tile_row(row: Array) -> void:
	mapTileMatrix.append(row)

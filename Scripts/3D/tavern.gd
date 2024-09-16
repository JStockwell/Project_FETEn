extends Node3D

var CombatMap = preload("res://Scenes/3D/mapCombat.tscn")
var Combat = preload("res://Scenes/3D/combat.tscn")

var setCam = 1

@onready
var mapCenter = $Base/SpawnPoints/MapCenter
@onready
var combatCenter = $Base/SpawnPoints/CombatCenter
@onready
var mapBase = $Base/MapBase
@onready
var characterSelect = $Base/CharSelect/CharacterSelect
@onready
var campaignCam = $Base/Campaign/Camera3D
@onready
var mapCam = $Base/Cameras/MapCam/Camera3D

@onready
var debugLabel = $Debug/Label

var cm
var com
func _ready():
	characterSelect.camera.current = true

func _on_campaign_start() -> void:
	campaignCam.current = true
	
func start_map_combat():
	var mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	var mapSize = Utils.string_to_vector2(mapDict["size"])
	CombatMapStatus.set_map_size(mapSize)
	CombatMapStatus.set_is_start_combat(true)
	CombatMapStatus.calculate_map_spawn(mapCenter.position)
	var mapSpawn = CombatMapStatus.get_map_spawn()
	
	mapBase.mesh.size.x = (mapSize.x + 1) * GameStatus.mapScale
	mapBase.mesh.size.z = (mapSize.y + 1) * GameStatus.mapScale
		
	CombatMapStatus.set_map_spawn(mapSpawn)
	CombatMapStatus.set_combat_spawn(combatCenter.position)
	
	cm = CombatMap.instantiate()
	add_child(cm)
	cm.position = CombatMapStatus.get_map_spawn()
	cm.scale *= GameStatus.mapScale
	
	mapCam.position.z = CombatMapStatus.get_camera_position()
	mapCam.current = true
	
	cm.connect("start_turn_signal", Callable(self, "_on_start_turn"))
	cm.connect("combat_start", Callable(self, "_on_combat_start"))
	cm.connect("change_camera", Callable(self, "_on_change_camera"))
	

func _on_start_turn() -> void:
	mapCam.current = true

func _on_combat_start() -> void:
	GameStatus.set_current_game_state(GameStatus.GameState.COMBAT)
	com = Combat.instantiate()
	#com.position = combatCenter.position
	cm.ui.hide()
	cm.globalButtons.hide()
	add_child(com)
	com.connect("combat_end", Callable(self, "_on_combat_end"))
	com.camera.current = true

func _on_combat_end() -> void:
	GameStatus.set_current_game_state(GameStatus.GameState.MAP)
	cm.ui.show()
	cm.globalButtons.show()
	com.queue_free()
	cm.purge_the_dead()
	cm.reset_to_tavern()
	cm.setCam = 1

func _on_change_camera() -> void:
	pass

func _on_campaign_map_start_map_combat() -> void:
	start_map_combat()


func _on_debug_h_scroll_bar_value_changed(value: float) -> void:
	mapCam.position.z = value
	debugLabel.text = str(value)


func _on_debug_progress_bar_value_changed(value: float) -> void:
	mapBase.position.y = value
	debugLabel.text = str(value)

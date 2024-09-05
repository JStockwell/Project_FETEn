extends Node3D

var CombatMap = preload("res://Scenes/3D/mapCombat.tscn")
var Combat = preload("res://Scenes/3D/combat.tscn")

var setCam = 1

@onready
var tavernCamPivot = $World/Tavern
@onready
var tavernCam = $World/Tavern/Camera3D
@onready
var topTavernPivot = $World/TopDown
@onready
var topTavernCam = $World/TopDown/Camera3D
@onready
var mapCenter = $SpawnPoints/MapCenter
@onready
var combatCenter = $SpawnPoints/CombatCenter
@onready
var mapBase = $MapBase

var cm
var com

func _ready():
	var mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	var mapSize = Utils.string_to_vector2(mapDict["size"])
	CombatMapStatus.set_map_size(mapSize)
	CombatMapStatus.set_is_start_combat(true)
	CombatMapStatus.calculate_map_spawn(mapCenter.position)
	var mapSpawn = CombatMapStatus.get_map_spawn()
	
	mapBase.mesh.size = Vector3(mapSize.x + 1, 0.36, mapSize.y + 1)
		
	if CombatMapStatus.get_map_y() % 2 == 0:
		mapBase.position.z += 0.5
		mapSpawn.z += 0.5
		
	CombatMapStatus.set_map_spawn(mapSpawn)
	CombatMapStatus.set_combat_spawn(combatCenter.position)
	
	cm = CombatMap.instantiate()
	add_child(cm)
	cm.position = CombatMapStatus.get_map_spawn()
	
	cm.connect("start_turn_signal", Callable(self, "_on_start_turn"))
	cm.connect("combat_start", Callable(self, "_on_combat_start"))
	cm.connect("change_camera", Callable(self, "_on_change_camera"))
	
	setup_cameras()
	
func setup_cameras():
	var camHeights = []
	var mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	
	# TODO make camera based on json
	if not "camera" in mapDict.keys():
		for i in range(0, CombatMapStatus.MAX_MAP_DIMENSION - CombatMapStatus.MIN_MAP_DIMENSION + 1):
			camHeights.append(CombatMapStatus.minCameraHeight + i * (CombatMapStatus.maxCameraHeight - CombatMapStatus.minCameraHeight) / (CombatMapStatus.MAX_MAP_DIMENSION - CombatMapStatus.MIN_MAP_DIMENSION))
		
		tavernCam.position.z = camHeights[CombatMapStatus.mapY - CombatMapStatus.MIN_MAP_DIMENSION]
		
	else:
		tavernCam.position.z = mapDict["camera"]
	
	topTavernPivot.position = Vector3(0, 15, 0)
	if CombatMapStatus.get_map_x() >= CombatMapStatus.get_map_y():
		if CombatMapStatus.get_map_y() % 2 != 0:
			topTavernPivot.position.z = -0.5
			
		topTavernCam.size = CombatMapStatus.get_map_y() + 1
		topTavernCam.rotation_degrees = Vector3(0, 0, 0)
		
	else:
		topTavernCam.size = CombatMapStatus.get_map_x() + 1
		topTavernCam.rotation_degrees = Vector3(0, 0, 90)

func _on_start_turn() -> void:
	tavernCam.make_current()
	setCam = 1

func _on_combat_start() -> void:
	com = Combat.instantiate()
	add_child(com)
	com.connect("combat_end", Callable(self, "_on_combat_end"))
	com.position = combatCenter.position
	com.camera.current = true
	cm.ui.hide()
	cm.changeCameraButton.hide()

func _on_combat_end() -> void:
	tavernCam.current = true
	cm.ui.show()
	cm.changeCameraButton.show()
	com.queue_free()
	cm.purge_the_dead()
	cm.reset_to_tavern()
	cm.setCam = 1

func _on_change_camera() -> void:
	if setCam == 1:
		topTavernCam.make_current()
		cm.ui.hide()
		setCam = 2
	else:
		tavernCam.make_current()
		cm.ui.show()
		setCam = 1

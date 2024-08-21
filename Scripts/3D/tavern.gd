extends Node3D

var CombatMap = preload("res://Scenes/3D/mapCombat.tscn")
var Combat = preload("res://Scenes/3D/combat.tscn")

@onready
var tavernCam = $World/Marker3D/Camera3D
@onready
var mapCenter = $SpawnPoints/MapCenter
@onready
var combatCenter = $SpawnPoints/CombatCenter

var cm
var com

func _ready():
	var mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	CombatMapStatus.calculate_map_spawn(mapCenter.position)
	CombatMapStatus.set_combat_spawn(combatCenter.position)
	
	cm = CombatMap.instantiate()
	add_child(cm)
	cm.position = CombatMapStatus.get_map_spawn()
	
	cm.connect("combat_start", Callable(self, "_on_combat_start"))
	
	var camHeights = []
	
	for i in range(0, CombatMapStatus.MAX_MAP_DIMENSION - CombatMapStatus.MIN_MAP_DIMENSION + 1):
		camHeights.append(CombatMapStatus.minCameraHeight + i * (CombatMapStatus.maxCameraHeight - CombatMapStatus.minCameraHeight) / (CombatMapStatus.MAX_MAP_DIMENSION - CombatMapStatus.MIN_MAP_DIMENSION))
		
	tavernCam.position.z = camHeights[CombatMapStatus.mapY - CombatMapStatus.MIN_MAP_DIMENSION]

func _on_combat_start():
	com = Combat.instantiate()
	
	add_child(com)
	
	com.connect("combat_end", Callable(self, "_on_combat_end"))
	
	com.position = combatCenter.position
	com.camera.current = true
	cm.ui.hide()

func _on_combat_end():
	tavernCam.current = true
	cm.ui.show()
	com.queue_free()
	cm.purge_the_dead()
	cm.reset_to_tavern()

extends Node3D

var CombatMap = preload("res://Scenes/3D/mapCombat.tscn")

@onready
var tavernCam = $World/Marker3D/Camera3D

func _ready():
	CombatMapStatus.calculate_map_spawn()
	var cm = CombatMap.instantiate()
	add_child(cm)
	cm.position = CombatMapStatus.get_map_spawn()
	
	var camHeights = []
	
	for i in range(0, 7):
		camHeights.append(CombatMapStatus.minCameraHeight + i * (CombatMapStatus.maxCameraHeight - CombatMapStatus.minCameraHeight) / 6)
		
	tavernCam.position.z = camHeights[CombatMapStatus.mapY - 9]

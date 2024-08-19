extends Node3D

var CombatMap = preload("res://Scenes/3D/mapCombat.tscn")

@onready
var combatMapSpawn = $CombatMapSpawn

func _ready():
	CombatMapStatus.set_map_spawn(combatMapSpawn.position)
	
	var cm = CombatMap.instantiate()
	add_child(cm)
	cm.position = combatMapSpawn.position
	cm.camera.current = true

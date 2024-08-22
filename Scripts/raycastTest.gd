extends Node3D

@onready
var mapTile4HitCollision = $Maptiles/MapTile4/HitDetection/CollisionShape3D

func _on_button_pressed():
	mapTile4HitCollision.disabled = false
	
	var ray = RayCast3D.new()
	
	ray.position = Vector3(0, 3, 0)
	ray.target_position = Vector3(2, 0, 1)
	
	add_child(ray)

extends Node3D

@export
var coordinates = Vector2(0,0)

func set_coords(i,j):
	coordinates = Vector2(i,j)

func _on_static_body_3d_mouse_entered():
	MapStatus.set_last_map_tile(coordinates)
	MapStatus.set_in_map_tile(true)


func _on_static_body_3d_mouse_exited():
	MapStatus.set_in_map_tile(false)

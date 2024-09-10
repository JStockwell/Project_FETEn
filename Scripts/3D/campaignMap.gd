extends Node3D

var highlighted_province: String

func _on_province_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			print(highlighted_province)

func _on_cordoba_mouse_entered() -> void:
	highlighted_province = "Cordoba"

func _on_sevilla_mouse_entered() -> void:
	highlighted_province = "Sevilla"

func _on_huelva_mouse_entered() -> void:
	highlighted_province = "Huelva"

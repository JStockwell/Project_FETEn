extends Node3D

signal start_map_combat

var highlighted_province: String

func _on_province_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and GameStatus.get_current_game_state() == GameStatus.GameState.CAMPAIGN:
		if event.button_index == 1 and event.pressed:
			match highlighted_province:
				"Cordoba":
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv2_4.json")
				"Sevilla":
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv4_1.json")
				"Huelva":
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv3_2.json")
				"Cádiz":
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv3_1.json")
				"Málaga":
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv2_3.json")
				"Jaén":
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv2_2.json")
				"Granada":
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv2_1.json")
				"Almería":
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv1_2.json")
				"Murcia":
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv1_1.json")
				"Badajoz":
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv3_3.json")
					
			print(CombatMapStatus.get_map_path())
			GameStatus.set_current_game_state(GameStatus.GameState.MAP)
			start_map_combat.emit()

func _on_cordoba_mouse_entered() -> void:
	highlighted_province = "Cordoba"

func _on_sevilla_mouse_entered() -> void:
	highlighted_province = "Sevilla"
	
func _on_huelva_mouse_entered() -> void:
	highlighted_province = "Huelva"
	
func _on_cadiz_mouse_entered() -> void:
	highlighted_province = "Cádiz"

func _on_malaga_mouse_entered() -> void:
	highlighted_province = "Málaga"
	
func _on_jaen_mouse_entered() -> void:
	highlighted_province = "Jaén"
	
func _on_granada_mouse_entered() -> void:
	highlighted_province = "Granada"
	
func _on_almeria_mouse_entered() -> void:
	highlighted_province = "Almería"
	
func _on_murcia_mouse_entered() -> void:
	highlighted_province = "Murcia"
	
func _on_badajoz_mouse_entered() -> void:
	highlighted_province = "Badajoz"
	

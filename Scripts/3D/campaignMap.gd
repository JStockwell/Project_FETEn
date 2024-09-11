extends Node3D

const DEBUG_MAPS = [
	"res://Assets/json/maps/combatMap_lv1_1.json",
	"res://Assets/json/maps/combatMap_lv1_2.json",
	"res://Assets/json/maps/combatMap_lv2_1.json",
	"res://Assets/json/maps/combatMap_lv2_2.json",
	"res://Assets/json/maps/combatMap_lv2_3.json",
	"res://Assets/json/maps/combatMap_lv2_4.json",
	"res://Assets/json/maps/combatMap_lv3_1.json",
	"res://Assets/json/maps/combatMap_lv3_2.json",
	"res://Assets/json/maps/combatMap_lv3_3.json",
	"res://Assets/json/maps/combatMap_lv4_1.json",
	"res://Assets/json/maps/testMaps/test_map_no_enemies.json"
]

@onready
var debugMapChoice = $Debug/MapChoice

@onready
var sevillaCol = $Map/Sevilla/CollisionPolygon3D
@onready
var sevillaText = $Map/Sevilla/Label3D
@onready
var sevillaDisabled = $Map/Sevilla/Disabled
@onready
var sevillaHighlight = $Map/Sevilla/Highlight

@onready
var cordobaCol = $Map/Cordoba/CollisionPolygon3D
@onready
var cordobaText = $Map/Cordoba/Label3D
@onready
var cordobaDisabled = $Map/Cordoba/Disabled
@onready
var cordobaHighlight = $Map/Cordoba/Highlight

@onready
var huelvaCol = $Map/Huelva/CollisionPolygon3D
@onready
var huelvaText = $Map/Huelva/Label3D
@onready
var huelvaDisabled = $Map/Huelva/Disabled
@onready
var huelvaHighlight = $Map/Huelva/Highlight

@onready
var cadizCol = $Map/Cadiz/CollisionPolygon3D
@onready
var cadizText = $Map/Cadiz/Label3D
@onready
var cadizDisabled = $Map/Cadiz/Disabled
@onready
var cadizHighlight = $Map/Cadiz/Highlight

@onready
var malagaCol = $Map/Malaga/CollisionPolygon3D
@onready
var malagaText = $Map/Malaga/Label3D
@onready
var malagaDisabled = $Map/Malaga/Disabled
@onready
var malagaHighlight = $Map/Malaga/Highlight

@onready
var jaenCol = $Map/Jaen/CollisionPolygon3D
@onready
var jaenText = $Map/Jaen/Label3D
@onready
var jaenDisabled = $Map/Jaen/Disabled
@onready
var jaenHighlight = $Map/Jaen/Highlight

@onready
var granadaCol = $Map/Granada/CollisionPolygon3D
@onready
var granadaText = $Map/Granada/Label3D
@onready
var granadaDisabled = $Map/Granada/Disabled
@onready
var granadaHighlight = $Map/Granada/Highlight

@onready
var almeriaCol = $Map/Almeria/CollisionPolygon3D
@onready
var almeriaText = $Map/Almeria/Label3D
@onready
var almeriaDisabled = $Map/Almeria/Disabled
@onready
var almeriaHighlight = $Map/Almeria/Highlight

@onready
var murciaCol = $Map/Murcia/CollisionPolygon3D
@onready
var murciaText = $Map/Murcia/Label3D
@onready
var murciaDisabled = $Map/Murcia/Disabled
@onready
var murciaHighlight = $Map/Murcia/Highlight

@onready
var badajozCol = $Map/Badajoz/CollisionPolygon3D
@onready
var badajozText = $Map/Badajoz/Label3D
@onready
var badajozDisabled = $Map/Badajoz/Disabled
@onready
var badajozHighlight = $Map/Badajoz/Highlight

signal start_map_combat

var highlighted_province: String
var save: Dictionary

func _ready() -> void:
	save = GameStatus.get_save()
	# TODO Remove testMode and test once finished
	if not GameStatus.testMode:
		validate_levels()
	
	if GameStatus.debugMode:
		debugMapChoice.show()
	
# TODO Test once done
# TODO Do with rest of levels
func validate_levels() -> void:
	var unlocks = save["unlocks"]["stages"]
	
	if not unlocks["stage_2"]:
		granadaCol.disabled = true
		granadaDisabled.show()
		
		jaenCol.disabled = true
		jaenDisabled.show()
		
		malagaCol.disabled = true
		malagaDisabled.show()
		
		cordobaCol.disabled = true
		cordobaDisabled.show()
	
	if not unlocks["stage_3"]:
		cadizCol.disabled = true
		cadizDisabled.show()
		
		huelvaCol.disabled = true
		huelvaDisabled.show()
		
		badajozCol.disabled = true
		badajozDisabled.show()
		
		
	if not unlocks["stage_4"]:
		sevillaCol.disabled = true
		sevillaDisabled.show()

func _on_province_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and GameStatus.get_current_game_state() == GameStatus.GameState.CAMPAIGN:
		if event.button_index == 1 and event.pressed:
			match highlighted_province:
				"Cordoba":
					CombatMapStatus.set_map_id("cordoba")
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv2_4.json")
				"Sevilla":
					CombatMapStatus.set_map_id("sevilla")
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv4_1.json")
				"Huelva":
					CombatMapStatus.set_map_id("huelva")
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv3_2.json")
				"Cádiz":
					CombatMapStatus.set_map_id("cadiz")
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv3_1.json")
				"Málaga":
					CombatMapStatus.set_map_id("malaga")
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv2_3.json")
				"Jaén":
					CombatMapStatus.set_map_id("jaen")
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv2_2.json")
				"Granada":
					CombatMapStatus.set_map_id("granada")
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv2_1.json")
				"Almería":
					CombatMapStatus.set_map_id("almeria")
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv1_2.json")
				"Murcia":
					CombatMapStatus.set_map_id("murcia")
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv1_1.json")
				"Badajoz":
					CombatMapStatus.set_map_id("badajoz")
					CombatMapStatus.set_map_path("res://Assets/json/maps/combatMap_lv3_3.json")
					
			GameStatus.set_current_game_state(GameStatus.GameState.MAP)
			debugMapChoice.hide()
			start_map_combat.emit()

func _on_cordoba_mouse_entered() -> void:
	cordobaHighlight.show()
	highlighted_province = "Cordoba"

func _on_sevilla_mouse_entered() -> void:
	sevillaHighlight.show()
	highlighted_province = "Sevilla"
	
func _on_huelva_mouse_entered() -> void:
	huelvaHighlight.show()
	highlighted_province = "Huelva"
	
func _on_cadiz_mouse_entered() -> void:
	cadizHighlight.show()
	highlighted_province = "Cádiz"

func _on_malaga_mouse_entered() -> void:
	malagaHighlight.show()
	highlighted_province = "Málaga"
	
func _on_jaen_mouse_entered() -> void:
	jaenHighlight.show()
	highlighted_province = "Jaén"
	
func _on_granada_mouse_entered() -> void:
	granadaHighlight.show()
	highlighted_province = "Granada"
	
func _on_almeria_mouse_entered() -> void:
	almeriaHighlight.show()
	highlighted_province = "Almería"
	
func _on_murcia_mouse_entered() -> void:
	murciaHighlight.show()
	highlighted_province = "Murcia"
	
func _on_badajoz_mouse_entered() -> void:
	badajozHighlight.show()
	highlighted_province = "Badajoz"


func _on_cordoba_mouse_exited() -> void:
	cordobaHighlight.hide()


func _on_sevilla_mouse_exited() -> void:
	sevillaHighlight.hide()


func _on_huelva_mouse_exited() -> void:
	huelvaHighlight.hide()


func _on_cadiz_mouse_exited() -> void:
	cadizHighlight.hide()


func _on_malaga_mouse_exited() -> void:
	malagaHighlight.hide()


func _on_jaen_mouse_exited() -> void:
	jaenHighlight.hide()


func _on_granada_mouse_exited() -> void:
	granadaHighlight.hide()


func _on_almeria_mouse_exited() -> void:
	almeriaHighlight.hide()


func _on_murcia_mouse_exited() -> void:
	murciaHighlight.hide()


func _on_badajoz_mouse_exited() -> void:
	badajozHighlight.hide()


func _on_debug_map_choice_item_selected(index: int) -> void:
	CombatMapStatus.set_map_path(DEBUG_MAPS[index])
	GameStatus.set_current_game_state(GameStatus.GameState.MAP)
	debugMapChoice.hide()
	start_map_combat.emit()

extends Control

@onready
var chooseProto = $Buttons/ChooseProto

@onready
var startButton = $Buttons/Start

@onready
var errorText = $Labels/Error

@onready
var errorTimer = $ErrorTimer

var chosenProto = -1


func _on_choose_proto_item_selected(index):
	chosenProto = chooseProto.get_selected_id()


func _on_start_pressed():
	errorText.hide()
	match chosenProto:
		-1:
			errorText.show()
			errorTimer.start()
			
		0:
			get_tree().change_scene_to_file("res://prototypes/proto_combat_v1/Scenes/combat_proto.tscn")
			
		1:
			get_tree().change_scene_to_file("res://prototypes/proto_combat_v2/Scenes/main_menu.tscn")
			
		2:
			get_tree().change_scene_to_file("res://prototypes/proto_combat_v3/Scenes/main_menu.tscn")
			
		3:
			get_tree().change_scene_to_file("res://prototypes/proto_combat_v4/Scenes/main_menu.tscn")
			
		4:
			get_tree().change_scene_to_file("res://prototypes/proto_combat_v5/Scenes/main_menu.tscn")
			
		5:
			get_tree().change_scene_to_file("res://prototypes/proto_combat_map_v1/Scenes/main_menu.tscn")


func _on_error_timer_timeout():
	errorText.hide()

extends Node3D

@onready
var ui = $UI
@onready
var camera = $Camera3D

signal return_to_tavern
func _on_return_button_pressed():
	ui.hide()
	MusicPlayer.play_fx(MusicPlayer.SOUNDS.UI__CLICK)
	return_to_tavern.emit()

extends Node3D

func _on_return_button_pressed():
	MusicPlayer.play_fx(MusicPlayer.SOUNDS.UI__CLICK)
	get_tree().change_scene_to_file("res://Scenes/UI/mainMenu.tscn")

extends Control

func _on_return_button_pressed():
	MusicPlayer.play_fx("click")
	get_tree().change_scene_to_file("res://Scenes/UI/mainMenu.tscn")

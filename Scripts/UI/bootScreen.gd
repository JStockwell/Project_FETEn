extends Control

func _ready():
	await wait(2)
	get_tree().change_scene_to_file("res://Scenes/UI/mainMenu.tscn")

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

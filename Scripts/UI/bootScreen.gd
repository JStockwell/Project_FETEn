extends Control

func _ready():
	if not GameStatus.debugMode:
		await wait(2)
	get_tree().change_scene_to_file("res://Scenes/3D/newTavern.tscn")

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

extends Control

var playableCharacters = Utils.read_json("res://Assets/json/players.json")
var enemySet = Utils.read_json("res://Assets/json/enemies.json")
var skillSet = Utils.read_json("res://Assets/json/skills.json")

func _ready():
	GameStatus.set_playable_characters(playableCharacters)
	GameStatus.set_enemy_set(enemySet)

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/characterSelect.tscn")

func _on_credits_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/credits.tscn")

extends Control

var playableCharacters = Utils.read_json("res://Assets/json/players.json")
var enemySet = Utils.read_json("res://Assets/json/enemies.json")

func _ready():
	GameStatus.load_save()
	update_unlocks()
	GameStatus.set_playable_characters(playableCharacters)
	GameStatus.set_enemy_set(enemySet)
	GameStatus.party = {}
	CombatMapStatus.isStartCombat = true

func update_unlocks() -> void:
	var updateFlag = false
	var tempSave = GameStatus.save.duplicate()
	pass

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/characterSelect.tscn")

func _on_credits_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/credits.tscn")

func _on_exit_button_pressed():
	get_tree().quit()

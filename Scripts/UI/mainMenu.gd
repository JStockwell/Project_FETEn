extends Control

@onready
var background = $Background
@onready
var buttons = $Buttons
@onready
var resetConfirmation = $ResetConfirmation
@onready
var debugUnlockButton = $Buttons/DebugUnlock

func _ready():
	MusicPlayer.play_main_cafe_music()
	
	if GameStatus.debugMode:
		debugUnlockButton.show()
		
	background.show()
	buttons.show()
	resetConfirmation.hide()
	GameStatus.load_save()
	update_unlocks()
	GameStatus.party = {}
	CombatMapStatus.isStartCombat = true

# TODO Test
func update_unlocks() -> void:
	var tempSave = GameStatus.get_save()
	
	for i in range(1, GameStatus.get_stage_count()):
		tempSave = verify_unlock("stage_" + str(i + 1), "stage_" + str(i), tempSave)
	
	GameStatus.save_game(tempSave)

# TODO Test
func verify_unlock(stage: String, previousStage: String, tempSave: Dictionary) -> Dictionary:
	var unlockFlag = true
	
	for level in tempSave["level_clears"][previousStage].values():
		unlockFlag = unlockFlag and level
		
	if unlockFlag:
		tempSave["unlocks"]["stages"][stage] = true
		
	else:
		tempSave["unlocks"]["stages"][stage] = false
			
	return tempSave

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/3D/newTavern.tscn")

func _on_credits_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/credits.tscn")

func _on_exit_button_pressed():
	get_tree().quit()

# TODO Test
func _on_reset_button_pressed() -> void:
	background.hide()
	buttons.hide()
	resetConfirmation.show()

# TODO Test
func _on_reset_save_no_pressed() -> void:
	background.show()
	buttons.show()
	resetConfirmation.hide()

# TODO Test
func _on_reset_save_yes_pressed() -> void:
	GameStatus.save_game(Utils.read_json("res://Assets/json/save_reference.json"))
	background.show()
	buttons.show()
	resetConfirmation.hide()


func _on_debug_unlock_pressed() -> void:
	var tempSave = GameStatus.get_save()
	
	for stage in tempSave["level_clears"]:
		for level in tempSave["level_clears"][stage]:
			tempSave["level_clears"][stage][level] = true
			
	for stage in tempSave["unlocks"]["stages"]:
		tempSave["unlocks"]["stages"][stage] = true
		
	GameStatus.save_game(tempSave)

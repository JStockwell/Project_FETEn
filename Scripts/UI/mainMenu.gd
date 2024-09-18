extends Node

signal game_start

@onready
var background = $OldUI/Background
@onready
var buttons = $OldUI/Buttons
@onready
var resetConfirmation = $OldUI/ResetConfirmation
@onready
var debugUnlockButton = $OldUI/Buttons/DebugUnlock

var playableCharacters = Utils.read_json("res://Assets/json/players.json")
var enemySet = Utils.read_json("res://Assets/json/enemies.json")

func start():
	MusicPlayer.play_music(MusicPlayer.SOUNDS.CAFE_MUSIC)
	
	if GameStatus.debugMode:
		debugUnlockButton.show()
		
	resetConfirmation.hide()
	GameStatus.load_save()
	update_unlocks()
	GameStatus.party = {}
	CombatMapStatus.isStartCombat = true
	reset_highlights()

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

func verify_click(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		return verify_game_status() and event is InputEventMouseButton and event.button_index == 1 and event.pressed
	else:
		return false

func verify_game_status() -> bool:
	return GameStatus.get_current_game_state() == GameStatus.GameState.MAIN_MENU

func _on_debug_unlock_pressed() -> void:
	var tempSave = GameStatus.get_save()
	
	for stage in tempSave["level_clears"]:
		for level in tempSave["level_clears"][stage]:
			tempSave["level_clears"][stage][level] = true
			
	for stage in tempSave["unlocks"]["stages"]:
		tempSave["unlocks"]["stages"][stage] = true
		
	GameStatus.save_game(tempSave)

func reset_highlights() -> void:
	startGameHighlight.hide()
	exitGameHighlight.hide()
	resetDataHighlight.hide()

@onready
var startGameHighlight = $Buttons/StartGame/Highlighted
func _on_start_button_pressed(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if verify_click(event):
		MusicPlayer.play_fx(MusicPlayer.SOUNDS.UI__CLICK)
		game_start.emit()

func _on_start_game_mouse_entered() -> void:
	if verify_game_status():
		startGameHighlight.show()

func _on_start_game_mouse_exited() -> void:
	if verify_game_status():
		startGameHighlight.hide()

@onready
var exitGameHighlight = $Buttons/ExitGame/Highlighted
func _on_exit_button_pressed(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if verify_click(event):
		MusicPlayer.play_fx(MusicPlayer.SOUNDS.UI__CLICK)
		get_tree().quit()

func _on_exit_game_mouse_entered() -> void:
	if verify_game_status():
		exitGameHighlight.show()

func _on_exit_game_mouse_exited() -> void:
	if verify_game_status():
		exitGameHighlight.hide()

@onready
var resetDataHighlight = $Buttons/ResetData/Highlighted
# TODO Test
func _on_reset_button_pressed(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if verify_click(event):
		MusicPlayer.play_fx(MusicPlayer.SOUNDS.UI__CLICK)
		resetConfirmation.show()

func _on_reset_data_mouse_entered() -> void:
	if verify_game_status():
		resetDataHighlight.show()

func _on_reset_data_mouse_exited() -> void:
	if verify_game_status():
		resetDataHighlight.hide()

# TODO Test
func _on_reset_save_no_pressed() -> void:
	MusicPlayer.play_fx(MusicPlayer.SOUNDS.UI__CLICK)
	resetConfirmation.hide()

# TODO Test
func _on_reset_save_yes_pressed() -> void:
	MusicPlayer.play_fx(MusicPlayer.SOUNDS.UI__CLICK)
	GameStatus.save_game(Utils.read_json("res://Assets/json/save_reference.json"))
	resetConfirmation.hide()

@onready
var creditsHighlight = $Buttons/Credits/Highlighted
signal switch_to_credits
func _on_credits_button_pressed(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if verify_click(event):
		MusicPlayer.play_fx(MusicPlayer.SOUNDS.UI__CLICK)
		switch_to_credits.emit()

func _on_credits_mouse_entered() -> void:
	creditsHighlight.show()

func _on_credits_mouse_exited() -> void:
	creditsHighlight.hide()

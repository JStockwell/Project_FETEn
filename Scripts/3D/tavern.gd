extends Node3D

var CombatMap = preload("res://Scenes/3D/mapCombat.tscn")
var Combat = preload("res://Scenes/3D/combat.tscn")

var setCam: int = 1

@onready
var characterSelect = $Base/CharSelect/CharacterSelect
@onready
var campaign = $Base/Campaign/CampaignMap
@onready
var mainMenu = $MainMenu
@onready
var credits = $Room/Credits

@onready
var mapCenter = $Base/SpawnPoints/MapCenter
@onready
var combatCenter = $Base/SpawnPoints/CombatCenter
@onready
var mapBase = $Base/MapBase
@onready
var campaignCam = $Base/Campaign/Camera3D
@onready
var mapCam = $Base/Cameras/MapCam/Camera3D
@onready
var mapCamPivot = $Base/Cameras/MapCam

@onready
var cam1 = $MainMenuCameras/Camera1/Camera3D
@onready
var cam1Pivot = $MainMenuCameras/Camera1
@onready
var cam2 = $MainMenuCameras/Camera2/Camera3D
@onready
var cam2Pivot = $MainMenuCameras/Camera2
@onready
var cam3 = $MainMenuCameras/Camera3/Camera3D
@onready
var cam3Pivot = $MainMenuCameras/Camera3

@onready
var mainMenuCam = $MainMenu/CamPivot/Camera3D

var mainMenuCams: Array
var camPointer: int = 0

@onready
var preMainMenuLabel = $PreMainMenuLabel

@onready
var debugLabel = $Debug/Label

var cm
var com

func _ready():
	reset_game()

func reset_game():
	GameStatus.set_playable_characters(Utils.read_json("res://Assets/json/players.json"))
	GameStatus.set_enemy_set(Utils.read_json("res://Assets/json/enemies.json"))
	
	var skillSet = Utils.read_json("res://Assets/json/skills.json")
	var i = 0
	for skillName in skillSet:
		GameStatus.skillSet[skillName] = Factory.Skill.create(skillSet[skillName])
		GameStatus.skillSet[skillName].set_skill_menu_id(i)
		i += 1
	
	MusicPlayer.play_music(MusicPlayer.SOUNDS.CAFE, -20)
	
	GameStatus.reset_game()
	CombatMapStatus.reset_game()
	
	#preMainMenuLabel.show()
	mainMenuCams = [cam1, cam2, cam3]
	
	choose_main_menu_camera()
	
	if not cm == null:
		cm.endScreen.hide()

func _input(event):
	if event is InputEventMouseButton and event.button_index == 1:
		if GameStatus.get_current_game_state() == GameStatus.GameState.PRE_MAIN_MENU:
			_on_main_menu_start()
	if not cm == null:
		if event.is_action_pressed("ui_up"):
			mapCam.rotation_degrees.x += 5
				
		elif event.is_action_pressed("ui_down"):
			mapCam.rotation_degrees.x -= 5
			
		if event.is_action_pressed("ui_left"):
			mapCamPivot.rotation_degrees.y +=5
			
		elif event.is_action_pressed("ui_right"):
			mapCamPivot.rotation_degrees.y -=5

func _process(delta):
	if GameStatus.currentGameState == GameStatus.GameState.PRE_MAIN_MENU:
		match camPointer:
			0:
				cam1Pivot.rotation_degrees.y += 0.2
				if cam1Pivot.rotation_degrees.y >= 75:
					reset_cameras()
					
			1:
				cam2Pivot.position.z += 0.001
				if cam2Pivot.position.z >= 0.3:
					reset_cameras()
			2:
				cam3.position.z -= 0.009
				if cam3.position.z <= 0.9:
					reset_cameras()

func reset_cameras() -> void:
	camPointer += 1
	
	if camPointer >= mainMenuCams.size():
		camPointer = 0
		
	cam1Pivot.rotation_degrees.y = -75
	cam2Pivot.position.z = -0.325
	cam3.position.z = 5.2
	
	mainMenuCams[camPointer].current = true

func choose_main_menu_camera() -> void:
	camPointer = randi_range(0, mainMenuCams.size() - 1)
	reset_cameras()

func _on_main_menu_start() -> void:
	mainMenuCam.current = true
	preMainMenuLabel.hide()
	GameStatus.set_current_game_state(GameStatus.GameState.MAIN_MENU)
	mainMenu.start()

func _on_game_start() -> void:
	GameStatus.set_current_game_state(GameStatus.GameState.CHAR_SELECT)
	characterSelect.setup()
	characterSelect.camera.current = true
	characterSelect.ui.show()
	
	if not cm == null:
		cm.free()

func _on_campaign_start() -> void:
	GameStatus.set_current_game_state(GameStatus.GameState.CAMPAIGN)
	campaign.setup()
	campaignCam.current = true
	
func start_map_combat():
	var mapDict = Utils.read_json(CombatMapStatus.get_map_path())
	var mapSize = Utils.string_to_vector2(mapDict["size"])
	CombatMapStatus.set_map_size(mapSize)
	CombatMapStatus.set_is_start_combat(true)
	CombatMapStatus.calculate_map_spawn(mapCenter.position)
	var mapSpawn = CombatMapStatus.get_map_spawn()
	
	mapBase.mesh.size.x = (mapSize.x + 1) * GameStatus.mapScale
	mapBase.mesh.size.z = (mapSize.y + 1) * GameStatus.mapScale
		
	CombatMapStatus.set_map_spawn(mapSpawn)
	CombatMapStatus.set_combat_spawn(combatCenter.position)
	
	cm = CombatMap.instantiate()
	add_child(cm)
	cm.position = CombatMapStatus.get_map_spawn()
	cm.scale *= GameStatus.mapScale
	
	mapCam.position.z = CombatMapStatus.get_camera_position()
	mapCam.current = true
	
	cm.connect("start_turn_signal", Callable(self, "_on_start_turn"))
	cm.connect("combat_start", Callable(self, "_on_combat_start"))
	cm.connect("change_camera", Callable(self, "_on_change_camera"))
	cm.connect("reset_game", Callable(self, "reset_game"))
	

func _on_start_turn() -> void:
	mapCam.current = true

func _on_combat_start() -> void:
	GameStatus.set_current_game_state(GameStatus.GameState.COMBAT)
	com = Combat.instantiate()
	#com.position = combatCenter.position
	cm.ui.hide()
	cm.globalButtons.hide()
	add_child(com)
	com.connect("combat_end", Callable(self, "_on_combat_end"))
	com.camera.current = true

func _on_combat_end() -> void:
	GameStatus.set_current_game_state(GameStatus.GameState.MAP)
	cm.ui.show()
	cm.globalButtons.show()
	com.queue_free()
	cm.purge_the_dead()
	cm.reset_to_tavern()
	cm.setCam = 1

func _on_change_camera() -> void:
	pass

func _on_campaign_map_start_map_combat() -> void:
	start_map_combat()

func _on_debug_h_scroll_bar_value_changed(value: float) -> void:
	mapCam.position.z = value
	debugLabel.text = str(value)

func _on_debug_progress_bar_value_changed(value: float) -> void:
	mapBase.position.y = value
	debugLabel.text = str(value)

@onready
var creditsHangingLight = $Room/Lights/HangingLights/HangingLight2
func _on_main_menu_switch_to_credits() -> void:
	creditsHangingLight.hide()
	credits.camera.current = true
	credits.ui.show()

func _on_credits_return_to_tavern() -> void:
	creditsHangingLight.show()
	_on_main_menu_start()

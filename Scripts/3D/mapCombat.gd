extends Node3D

@onready
var cameraPivot = $Utility/CameraPivot
@onready
var camera = $Utility/CameraPivot/Camera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	cameraPivot.position = Vector3(CombatMapStatus.get_map_x()/2, 0, CombatMapStatus.get_map_y()/2)
	camera.position = Vector3(0,0,CombatMapStatus.get_map_x())
	
	for x in CombatMapStatus.get_map_x():
		for y in CombatMapStatus.get_map_y():
			var mapTile = Factory.MapTile.create({
				"coords": Vector2(x,y),
				"height": 0,
				"isPopulated": false,
				"isTraversable": false,
				"isObstacle": false,
				"meshPath": null
			})
			
			add_child(mapTile)
			mapTile.translate(Vector3(x, mapTile.get_height(), y))
	
	var i = 0
	for character in GameStatus.get_party():
		var partyMember = GameStatus.get_party_member(character)
		partyMember.scale *= Vector3(0.5, 0.5, 0.5)
		# TODO remove adjust once Pablo fixes the fucking character models
		partyMember.translate(Vector3(-1.465, 0.815 + 1, i * 2))
		partyMember.set_map_coords(Vector2(0, i))
		add_child(partyMember)
		
		partyMember.connect("character_selected", Callable(self, "character_handler"))
		i += 1
		
	i = 0
	for character in GameStatus.get_enemies():
		var enemy = GameStatus.get_enemy(character)
		enemy.scale *= Vector3(0.5, 0.5, 0.5)
		# TODO remove adjust once Pablo fixes the fucking character models
		enemy.translate(Vector3(CombatMapStatus.get_map_x() + 2 - 1.465, 0.815 + 1, CombatMapStatus.get_map_y() + 2 - i * 2))
		enemy.set_map_coords(Vector2(CombatMapStatus.get_map_x(), CombatMapStatus.get_map_y() - i))
		add_child(enemy)
		
		enemy.connect("character_selected", Callable(self, "character_handler"))
		i += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_debug_label()
	
func character_handler(character) -> void:
	if GameStatus.get_selected_character() == null:
		GameStatus.set_selected_character(character)
	elif GameStatus.get_selected_character().get_name() == character.get_name():
		GameStatus.set_selected_character(null)
	else:
		GameStatus.set_selected_character(character)

# Debug
@onready
var debugLabel = $UI/Debug/DebugLabel

func update_debug_label():
	debugLabel.text = "selectedCharacter\n"
	if GameStatus.get_selected_character() == null:
		debugLabel.text += "null"
	else:
		debugLabel.text += "name: " + GameStatus.get_selected_character().get_char_name()
		debugLabel.text += "\ncoords: " + str(GameStatus.get_selected_character().get_map_coords())

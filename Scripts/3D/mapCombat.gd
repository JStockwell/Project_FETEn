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
			
			mapTile.translate(Vector3(x, 0, y))
	
	var i = 0
	for character in GameStatus.get_party():
		var partyMember = GameStatus.get_party_member(character)
		partyMember.scale *= Vector3(0.5, 0.5, 0.5)
		# TODO remove adjust once Pablo fixes the fucking character models
		partyMember.translate(Vector3(-1.465, 0.815, i * 2))
		add_child(partyMember)
		i += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_debug_label()

# Debug
@onready
var debugLabel = $UI/Debug/DebugLabel

func update_debug_label():
	debugLabel.text = str(GameStatus.get_highlighted_node())
	

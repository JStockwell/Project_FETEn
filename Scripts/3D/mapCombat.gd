extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
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
			
	#for character in GameStatus.get_party():
		#pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

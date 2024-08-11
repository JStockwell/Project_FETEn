extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var mapTile = Factory.MapTile.create({
		"coords": Vector2(0,0),
		"height": 0,
		"isPopulated": false,
		"isTraversable": false,
		"isObstacle": false,
		"meshPath": null
	})
	
	add_child(mapTile)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

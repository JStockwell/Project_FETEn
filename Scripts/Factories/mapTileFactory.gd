class_name MapTileFactory

const MapTile = preload("res://Scenes/Entities/mapTile.tscn")

# MapTileDict = coords, height, isPopulated, isTraversable, isObstacle, meshPath
static func create(args: Dictionary):
	var validator = true
	
	var coords: Vector2 = Utils.string_to_vector2(args["coords"])
	var height: int = args["height"]
	var idt: int = args["idt"]
	var isPopulated: bool = args["isPopulated"]
	var isTraversable: bool = args["isTraversable"]
	var obstacleType: int = args["obstacleType"]
	
	if coords.x < 0 or coords.y <0:
		validator = false
		
	if obstacleType == 2 and isTraversable:
		validator = false
		
	if isPopulated and not isTraversable:
		validator = false
		
	if height < -1 or height > 1:
		validator = false
		
	if validator:
		var myMapTile = MapTile.instantiate()
		
		myMapTile.coords = coords
		myMapTile.height = height
		myMapTile.isDifficultTerrain = idt
		myMapTile.isPopulated = isPopulated
		myMapTile.isTraversable = isTraversable
		myMapTile.obstacleType = obstacleType
		
		var path = args["meshPath"]
		if path == "":
			path = "res://Assets/MapTiles/placeholder_tile.glb"
		
		myMapTile.add_child(load(path).instantiate())
		return myMapTile
		
	else:
		push_error("incorrect maptile")

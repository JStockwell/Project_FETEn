extends Node3D

var mapX = 15
var mapY = 15

var mapMatrix: Array

@onready
var mapTileGroup = $MapTileGroup
@onready
var cam = $World/Camera3D

func _ready():
	cam.size = max(mapX, mapY) * 2
	cam.position.x = -mapX / 2
	cam.position.z = mapY / 2
	generate_buttons()

func generate_buttons():
	for i in range(0, mapX):
		for j in range(0, mapY):
			var op = OptionButton.new()
			add_child(op)
			op.position = Vector2(128 + 64 * i, 384 + 40 * j)

func generate_map():
	for x in range(0, mapX):
		var row = []
		for y in range(0, mapY):
			var mapTile = Factory.MapTile.create({
				"coords": Vector2(x,y),
				"height": 0,
				"idt": false,
				"isPopulated": false,
				"isTraversable": true,
				"isObstacle": false,
				"meshPath": ""
			})
			
			mapTileGroup.add_child(mapTile, true)
			mapTile.position = Vector3(x, 0, y)
			
			row.append(mapTile.get_variables().duplicate())
		mapMatrix.append(row)


func _on_regen_pressed():
	generate_map()

extends Node3D

var mapDict = Utils.read_json("res://Assets/json/maps/map1.json")
var selectedTile
var setCam = 1

var origin: Vector2
var end: Vector2

@onready
var mapTileGroup = $MapTileGroup
@onready
var mainCam = $World/MainCam/Camera3D
@onready
var topDownCam = $World/TopDown/Camera3D
@onready
var forwardCam = $World/Forward/Camera3D
@onready
var debugText = $DebugText

func _ready():
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	
	var row = []
	for tile in mapDict["tiles"]:
		var mapTile = Factory.MapTile.create(tile)
		mapTileGroup.add_child(mapTile, true)
		mapTile.position = Vector3(mapTile.get_coords().x, mapTile.get_height() * 0.1, mapTile.get_coords().y)
		mapTile.connect("tile_selected", Callable(self, "tile_handler"))
		
		if mapTile.is_obstacle():
			mapTile.set_odz(false)
		
		row.append(mapTile.get_variables().duplicate())
		if mapTile.get_coords().x == CombatMapStatus.get_map_x():
			CombatMapStatus.add_map_tile_row(row)
			row = []

func _process(delta):
	if origin != Vector2.ZERO and end != Vector2.ZERO:
		debugText.text = "Origin: " + str(origin)
		debugText.text += "\nEnd: " + str(end)

func _on_button_pressed():
	var ray = RayCast3D.new()
	
	ray.set_collide_with_areas(true)
	
	ray.position = Vector3(origin.x, -5, origin.y)
	ray.target_position = Vector3(end.x - origin.x, 0, end.y - origin.y)
	
	add_child(ray)
	ray.force_raycast_update()
	
	print(ray.is_colliding())
	ray.free()

func tile_handler(tile):
	selectedTile = tile
	
	for tempTile in mapTileGroup.get_children():
		tempTile.selected.hide()
		
	tile.selected.show()

func _on_change_cam_pressed():
	if setCam == 1:
		topDownCam.current = true
		mainCam.current = false
		setCam = 2
	elif setCam == 2:
		forwardCam.current = true
		topDownCam.current = false
		setCam = 3
	else:
		mainCam.current = true
		forwardCam.current = false
		setCam = 1

func _on_set_origin_pressed():
	if selectedTile != null:
		origin = selectedTile.get_coords()
		for tempTile in mapTileGroup.get_children():
			tempTile.highlighted.hide()
		selectedTile.highlighted.show()

func _on_set_end_pressed():
	if selectedTile != null:
		end = selectedTile.get_coords()
		for tempTile in mapTileGroup.get_children():
			tempTile.enemy.hide()
		selectedTile.enemy.show()

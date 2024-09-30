extends Node3D

var mapDict = Utils.read_json("res://Assets/json/maps/testMaps/demo_line_of_sight.json")
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
	GameStatus.debugMode = true
	CombatMapStatus.set_map_size(Utils.string_to_vector2(mapDict["size"]))
	CombatMapStatus.set_is_start_combat(true)
	
	var row = []
	for tile in mapDict["tiles"]:
		var mapTile = Factory.MapTile.create(tile)
		mapTileGroup.add_child(mapTile, true)
		mapTile.position = Vector3(mapTile.get_coords().x, mapTile.get_height() * 0.2, mapTile.get_coords().y)
		mapTile.connect("tile_selected", Callable(self, "tile_handler"))
		
		if mapTile.get_obstacle_type() in [1, 2]:
			mapTile.init_odz()
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
	#var origin = CombatMapStatus.get_selected_character().get_map_coords()
	#var end = CombatMapStatus.get_selected_enemy().get_map_coords()
	ray.position = Vector3(origin.x, -5, origin.y)
	ray.target_position = Vector3(end.x - origin.x, 0, end.y - origin.y)
	
	add_child(ray)
	ray.set_collide_with_areas(true)
	
	# endFlag, hasCollidedFull, mapMod
	var result = [false, false, []]
	
	for i in range(0, 1000):
		result = collision_loop(ray, result)
		
		if result[0] == true:
			break
		
	for tile in result[2]:
		tile.set_odz(false)
		
	if result[1]:
		print("Big Collision!")
		return 
	
	else:
		if len(result[2]) == 0:
			print("No Collision!")
			
		else:
			print(result[2])

# args: endFlag: bool, noLoS: bool, foundTiles: Array
func collision_loop(ray, args: Array):
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var tile = ray.get_collider().get_parent()
		
		if tile.get_obstacle_type() == 2:
			ray.free()
			args[0] = true
			args[1] = true
		
		elif tile.get_obstacle_type() == 1:
			args[2].append(tile)
			tile.set_odz(true)
			
	else:
		args[0] = true
		
	return args

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

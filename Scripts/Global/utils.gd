class_name Utils

static func calc_distance(vect_1: Vector2, vect_2: Vector2) -> int:
	return abs(vect_1.x - vect_2.x) + abs(vect_1.y - vect_2.y)

static func read_json(jsonPath: String):
	if FileAccess.file_exists(jsonPath):
		var dataFile = FileAccess.open(jsonPath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		
		if parsedResult is Dictionary:
			return parsedResult
		else:
			print("Error reading file " + jsonPath)
			
	else:
		print("File {path} doesn't exist!".format({"path": jsonPath}))
		
static func generate_rolls() -> Array:
	# true_hit_flag, dice_1, dice_2, crit_roll
	return [randi_range(1, 2), randi_range(1, 100), randi_range(1, 100), randi_range(1, 100)]

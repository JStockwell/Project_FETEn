class_name Utils

static func reset_all():
	reset_gs()
	reset_cms()
	
static func reset_gs():
	GameStatus.playableCharacters = {}
	GameStatus.enemySet = {}
	GameStatus.skillSet = {}

	GameStatus.party = {}

static func reset_cms():
	CombatMapStatus.enemies = {}

	CombatMapStatus.mapX = 0
	CombatMapStatus.mapY = 0

	CombatMapStatus.selectedCharacter = null
	CombatMapStatus.selectedEnemy = null
	CombatMapStatus.selectedAlly = null
	CombatMapStatus.selectedMapTile = null

	CombatMapStatus.attackerStats = {}
	CombatMapStatus.defenderStats = {}

	CombatMapStatus.mapMod = 0
	CombatMapStatus.attackRange = 0
	CombatMapStatus.attackSkill = ""

	CombatMapStatus.isStartCombat = true
	CombatMapStatus.initiative = []
	CombatMapStatus.currentIni = 0

	CombatMapStatus.hasAttacked = false
	CombatMapStatus.hasAttacked = false

	CombatMapStatus.mapTileMatrix = []

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

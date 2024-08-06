extends GutTest


var Character = load("res://Scripts/character.gd")

var char = null
enum skills {SKILL_1, SKILL2}

func before_each():
	char = Character.new()
	
func after_each():
	char.free()

func test_not_null():
	assert_not_null(char)
	
func test_set_stats():
	var stats = {
		"name": "Player1",
		"max_health": 24,
		"attack": 16,
		"dexterity": 16,
		"defense": 6,
		"movement": 5,
		"ini_magic": 5,
		"max_magic": 20,
		"reg_magic": 5,
		"range": 4,
		"skills": skills
	}
	
	char.set_stats(stats)
	
	var checker = char.get_stats()
	
	assert_eq(stats, checker, "The stats are not the same")

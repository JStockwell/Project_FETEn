extends GutTest

var Character = load("res://Scripts/character.gd")
var char = null
var stats = null

func before_each():
	char = Character.new()
	
func after_each():
	char.free()

func test_not_null():
	assert_not_null(char)
	
func test_get_stats():
	var stats = {
		"name": "Samael",
		"max_health": 24,
		"current_health": 2,
		"attack": 16,
		"defense": 6,
		"movement": 3,
		"map_position": null
	}
	
	char.set_stats(stats)
	
	var checker = char.get_stats()
	
	assert_eq(stats, checker, "Yo que se pibe v2")

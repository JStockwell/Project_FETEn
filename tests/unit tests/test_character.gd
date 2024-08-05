extends GutTest

var Character = load("res://Scripts/character.gd")
var char = null

func before_each():
	char = Character.new()
	
func after_each():
	char.free()

func test_something():
	char.free()
	assert_not_null(char)
	

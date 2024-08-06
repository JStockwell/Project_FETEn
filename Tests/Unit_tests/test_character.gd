extends GutTest

var Character = load("res://Scripts/character.gd")

var char = null
enum skills {SKILL_1, SKILL2}
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
	"skills": skills,
	"special": 5
}

func before_each():
	char = Character.new()
	
func after_each():
	char.free()

func test_not_null():
	assert_not_null(char)
	
func test_set_stats():
	char.set_stats(stats)
	
	var checker = char.get_stats()
	
	assert_eq(stats, checker, "The stats are not the same")

func test_set_initial_current_stats():
	char.set_stats(stats)
	
	var initial_current_stats = {
		"current_health": char.get_stats().get("max_health"),
		"current_magic": char.get_stats().get("ini_magic")
	}
	
	char.set_current_stats(initial_current_stats)
	
	var checker = char.get_current_stats()
	
	assert_eq(initial_current_stats, checker, "The stats are not the same")
	
func test_set_current_stats():
	var current_stats = {
		"current_health": 12,
		"current_magic": 8
	}
	
	char.set_current_stats(current_stats)
	
	var checker = char.get_current_stats()
	
	assert_eq(current_stats, checker, "The stats are not the same")
	
func test_current_not_bigger_than_max_stats():
	char.set_stats(stats)
	
	var current_stats = {
		"current_health": char.get_stats().get("max_health") + 1,
		"current_magic": char.get_stats().get("max_magic") + 1
	}
	
	char.set_current_stats(current_stats)
	
	var checker = char.get_current_stats()
	
	assert_ne(current_stats, checker, "The current stats can not be bigger than the max")
	
func test_current_stats_not_negative():
	char.set_stats(stats)

	var current_stats = {
		"current_health": char.get_stats().get("max_health") - 8000,
		"current_magic": char.get_stats().get("max_magic") - 8000
	}
	
	char.set_current_stats(current_stats)
	
	var checker = char.get_current_stats()
	
	assert_ne(current_stats, checker, "The current stats can not be negative")

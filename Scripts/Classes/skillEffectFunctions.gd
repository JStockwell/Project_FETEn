class_name SEF extends Node

var Character = preload("res://Scenes/Entities/character.tscn")

static func run(Combat, sefName:String, attacker, defender, spa: int = 0, imd = 0):
	match sefName:
		"hello_world":
			hello_world()
		"nero_nero":
			nero_nero(Combat, attacker, defender, spa, imd)

static func hello_world():
	print("Hello World!")

static func nero_nero(Combat, attacker, defender, spa: int, imd: int):
	var dmg = Combat.calc_damage(attacker.get_stats()["attack"], defender.get_stats()["defense"], spa, imd)
	Combat.deal_damage(dmg,1,defender)

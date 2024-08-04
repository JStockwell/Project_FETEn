extends Node

func set_active_player(stats):
	activePlayer = stats

func set_active_enemy(id, stats):
	activeEnemy = stats
	activeEnemy["id"] = id
	
func set_active_player_hp(hp):
	activePlayer["current_health"] = hp
	
func set_active_enemy_hp(hp):
	activeEnemy["current_health"] = hp

var activePlayer = {
		"name": null,
		"max_health": null,
		"current_health": null,
		"attack": null,
		"defense": null,
		"map_position": null
	}

var activeEnemy = {
		"id": null,
		"name": null,
		"max_health": null,
		"current_health": null,
		"attack": null,
		"defense": null
	}
	
var party = {
	
}

var enemies = {
	"Goblin_1": {
		"name": "Goblin_1",
		"max_health": 16,
		"current_health": 16,
		"attack": 5,
		"defense": 3,
		"movement": 3,
		"map_position": null
	},
	"Orc_1": {
		"name": "Orc_1",
		"max_health": 45,
		"current_health": 45,
		"attack": 10,
		"defense": 6,
		"movement": 1,
		"map_position": null
	}
}

var playerList = {
	"Dick": {
		"name": "Dick",
		"max_health": 30,
		"current_health": 30,
		"attack": 16,
		"defense": 6,
		"movement": 2,
		"map_position": null
	},
	"Samael": {
		"name": "Samael",
		"max_health": 24,
		"current_health": 2,
		"attack": 16,
		"defense": 6,
		"movement": 3,
		"map_position": null
	},
	"Azrael": {
		"name": "Azrael",
		"max_health": 1,
		"current_health": 1,
		"attack": 1,
		"defense": 0,
		"movement": 3,
		"map_position": null
	}
}

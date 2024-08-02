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
	"Goblin_1" = {
		"name": "Goblin",
		"max_health": 16,
		"current_health": 16,
		"attack": 5,
		"defense": 3
	},
	"Goblin_2" = {
		"name": "Goblin",
		"max_health": 16,
		"current_health": 16,
		"attack": 5,
		"defense": 3
	},
	"Orc_1" = {
		"name": "Orc",
		"max_health": 45,
		"current_health": 45,
		"attack": 10,
		"defense": 6
	}
}

var playerList = {
	"Dick": {
		"name": "Dick",
		"max_health": 30,
		"current_health": 30,
		"attack": 16,
		"defense": 6,
		"movement": 2
	},
	"Samael": {
		"name": "Samael",
		"max_health": 24,
		"current_health": 24,
		"attack": 16,
		"defense": 6,
		"movement": 3
	},
	"Azrael": {
		"name": "Azrael",
		"max_health": 1,
		"current_health": 1,
		"attack": 1,
		"defense": 0,
		"movement": 3
	}
}

extends Node

var activePlayer = {
		"name": null,
		"max_health": null,
		"current_health": null,
		"attack": null,
		"defense": null
	}

var activeEnemy = {
		"name": "Goblin",
		"max_health": 15,
		"current_health": 15,
		"attack": 5,
		"defense": 3
	}

var playerList = {
	"Dick": {
		"name": "Dick",
		"max_health": 30,
		"current_health": 30,
		"attack": 16,
		"defense": 6
	},
	"Samael": {
		"name": "Samael",
		"max_health": 24,
		"current_health": 24,
		"attack": 16,
		"defense": 6
	},
	"Azrael": {
		"name": "Azrael",
		"max_health": 1,
		"current_health": 1,
		"attack": 1,
		"defense": 0
	}
}

extends Control

@onready
var dropdownParty = $DropdownParty

@onready
var dropdownEnemies = $DropdownEnemy

@onready
var partyHP = $Labels/PartyHP

@onready
var enemyHP = $Labels/EnemyHP

@onready
var errorLabel = $Labels/ErrorLabel

func _ready():
	errorLabel.hide()
	
	for character in GameStatus.party.keys():
		dropdownParty.add_item(character)
		partyHP.text += "{character}: {currentHP}/{maxHP}\n".format({"character":character,"currentHP":GameStatus.party[character]["current_health"],"maxHP":GameStatus.party[character]["max_health"]})
		
	for enemy in GameStatus.enemies.keys():
		dropdownEnemies.add_item(enemy)
		enemyHP.text += "{enemy}: {currentHP}/{maxHP}\n".format({"enemy":enemy,"currentHP":GameStatus.enemies[enemy]["current_health"],"maxHP":GameStatus.enemies[enemy]["max_health"]})


func _on_start_battle_pressed():
	GameStatus.set_active_player(GameStatus.party[dropdownParty.get_item_text(dropdownParty.get_selected_id())])
	GameStatus.set_active_enemy(dropdownEnemies.get_item_text(dropdownEnemies.get_selected_id()), GameStatus.enemies[dropdownEnemies.get_item_text(dropdownEnemies.get_selected_id())])
	if GameStatus.activePlayer["current_health"] > 0 and GameStatus.activeEnemy["current_health"] > 0:
		get_tree().change_scene_to_file("res://Scenes/combat_proto.tscn")
	else:
		errorLabel.show()

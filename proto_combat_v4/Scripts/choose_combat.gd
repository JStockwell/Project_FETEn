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
	
	for character in GameStatus_v4.party.keys():
		dropdownParty.add_item(character)
		partyHP.text += "{character}: {currentHP}/{maxHP}\n".format({"character":character,"currentHP":GameStatus_v4.party[character]["current_health"],"maxHP":GameStatus_v4.party[character]["max_health"]})
		
	for enemy in GameStatus_v4.enemies.keys():
		dropdownEnemies.add_item(enemy)
		enemyHP.text += "{enemy}: {currentHP}/{maxHP}\n".format({"enemy":enemy,"currentHP":GameStatus_v4.enemies[enemy]["current_health"],"maxHP":GameStatus_v4.enemies[enemy]["max_health"]})


func _on_start_battle_pressed():
	GameStatus_v4.set_active_player(GameStatus_v4.party[dropdownParty.get_item_text(dropdownParty.get_selected_id())])
	GameStatus_v4.set_active_enemy(dropdownEnemies.get_item_text(dropdownEnemies.get_selected_id()), GameStatus_v4.enemies[dropdownEnemies.get_item_text(dropdownEnemies.get_selected_id())])
	if GameStatus_v4.activePlayer["current_health"] > 0 and GameStatus_v4.activeEnemy["current_health"] > 0:
		get_tree().change_scene_to_file("res://proto_combat_v4/Scenes/combat_proto.tscn")
	else:
		errorLabel.show()

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
	
	for character in GameStatus_v5.party.keys():
		dropdownParty.add_item(character)
		partyHP.text += "{character}: {currentHP}/{maxHP}\n".format({"character":character,"currentHP":GameStatus_v5.party[character]["current_health"],"maxHP":GameStatus_v5.party[character]["max_health"]})
		
	for enemy in GameStatus_v5.enemies.keys():
		dropdownEnemies.add_item(enemy)
		enemyHP.text += "{enemy}: {currentHP}/{maxHP}\n".format({"enemy":enemy,"currentHP":GameStatus_v5.enemies[enemy]["current_health"],"maxHP":GameStatus_v5.enemies[enemy]["max_health"]})


func _on_start_battle_pressed():
	GameStatus_v5.set_active_player(GameStatus_v5.party[dropdownParty.get_item_text(dropdownParty.get_selected_id())])
	GameStatus_v5.set_active_enemy(dropdownEnemies.get_item_text(dropdownEnemies.get_selected_id()), GameStatus_v5.enemies[dropdownEnemies.get_item_text(dropdownEnemies.get_selected_id())])
	if GameStatus_v5.activePlayer["current_health"] > 0 and GameStatus_v5.activeEnemy["current_health"] > 0:
		get_tree().change_scene_to_file("res://proto_combat_v5/Scenes/combat_proto.tscn")
	else:
		errorLabel.show()

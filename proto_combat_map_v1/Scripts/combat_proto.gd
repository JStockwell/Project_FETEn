extends Node3D

@onready
var Player = $Player

@onready
var Enemy = $Enemy

@onready
var hpLabelPlayer = $UI/HPPlayer

@onready
var hpLabelEnemy = $UI/HPEnemy

@onready
var buttonAttack = $UI/ButtonAttack

@onready
var phaseText = $UI/PhaseText

@onready
var endText = $UI/EndText

@onready
var damageIndicator = $"UI/DamageIndicator"

@onready
var playerStatsLabel = $UI/StatsLabel/PlayerStatsLabel

@onready
var enemyStatsLabel = $UI/StatsLabel/EnemyStatsLabel

var playerAttacked = false

# Called when the node enters the scene tree for the first time.
func _ready():
	buttonAttack.disabled = true
	
	Player.set_stats(GameStatus_map_v1.activePlayer)
	Enemy.set_stats(GameStatus_map_v1.activeEnemy)
	
	setStatsLabel(playerStatsLabel, GameStatus_map_v1.activePlayer)
	setStatsLabel(enemyStatsLabel, GameStatus_map_v1.activeEnemy)
	
	hpLabelEnemy.text = str(Enemy.get_health())
	hpLabelPlayer.text = str(Player.get_health())
	
	change_phase()

	
func change_phase():
	buttonAttack.disabled = true
	
	if playerAttacked:
		phaseText.text = "Enemy Phase"
		print(GameStatus_map_v1.activeEnemy)
		GameStatus_map_v1.enemies[GameStatus_map_v1.activeEnemy["id"]] = GameStatus_map_v1.activeEnemy
	else:
		phaseText.text = "Player Phase"
	
	phaseText.show()
	await wait(2.0)
	phaseText.hide()
	
	if playerAttacked:
		enemy_attack()
	else:
		buttonAttack.disabled = false

func _on_button_attack_pressed():
	buttonAttack.disabled = true
	attack_calculation(Enemy, Player.get_attack(), hpLabelEnemy)
	
func enemy_attack():
	attack_calculation(Player, Enemy.get_attack(), hpLabelPlayer)
		
func attack_calculation(defender, attack, label):
	var finalHP = defender.get_health()
	var damage = await damage_calculation(attack, defender.get_defense())
	finalHP -= damage
	defender.set_health(finalHP)
	label.text = str(max(0,finalHP))
	
	if finalHP > 0:
		if not playerAttacked:
			GameStatus_map_v1.set_active_enemy_hp(finalHP)
			playerAttacked = !playerAttacked
			change_phase()
			
		else:
			GameStatus_map_v1.set_active_player_hp(finalHP)
			await wait(1.5)
			get_tree().change_scene_to_file("res://proto_combat_map_v1/Scenes/combat_map_proto.tscn")
		
	else:
		buttonAttack.disabled = true
		
		if playerAttacked:
			phaseText.text = "YOU LOST"
			GameStatus_map_v1.set_active_player_hp(0)
			MapStatus_map_v1.remove_player_tile(GameStatus_map_v1.activePlayer["map_position"])
		else:
			phaseText.text = "ENEMY DEFEATED"
			GameStatus_map_v1.set_active_enemy_hp(0)
			MapStatus_map_v1.remove_enemy_tile(GameStatus_map_v1.activeEnemy["map_position"])
			
		phaseText.show()
		defender.death(damage)
		save_result()
		await wait(1.5)

		if not playerAttacked:
			var enemyHealthPool = 0
			for enemy in GameStatus_map_v1.enemies:
				enemyHealthPool += GameStatus_map_v1.enemies[enemy]["current_health"]
			
			if enemyHealthPool <= 0:
				get_tree().change_scene_to_file("res://proto_combat_map_v1/Scenes/victory.tscn")
			else:
				get_tree().change_scene_to_file("res://proto_combat_map_v1/Scenes/combat_map_proto.tscn")

		else:
			var playerHealthPool = 0
			for player in GameStatus_map_v1.party:
				playerHealthPool += GameStatus_map_v1.party[player]["current_health"]
				
			if playerHealthPool <= 0:
				get_tree().change_scene_to_file("res://proto_combat_map_v1/Scenes/lose.tscn")
			else:
				get_tree().change_scene_to_file("res://proto_combat_map_v1/Scenes/combat_map_proto.tscn")


func damage_calculation(att, def):
	var damage = 0
	damage = int(att * (1 - 0.1 * def) + randi_range(0, 3))
	damageIndicator.text = "-" + str(damage)
	damageIndicator.show()
	await wait(1.0)
	damageIndicator.hide()
	return damage
	
func setStatsLabel(label, statsSet):
	label.text = "Name: {name}\nMax HP: {maxHP}\nAttack: {att}\nDefense: {def}".format({"name": statsSet["name"], "maxHP": statsSet["max_health"], "att": statsSet["attack"], "def": statsSet["defense"]})

func save_result():
	GameStatus_map_v1.party[GameStatus_map_v1.activePlayer["name"]] = GameStatus_map_v1.activePlayer
	var enemyId = GameStatus_map_v1.activeEnemy["id"]
	GameStatus_map_v1.activeEnemy.erase("id")
	GameStatus_map_v1.enemies[enemyId] = GameStatus_map_v1.activeEnemy

# Utility functions
func wait(time):
	await get_tree().create_timer(time).timeout


func _on_player_mouse_entered():
	playerStatsLabel.show()


func _on_player_mouse_exited():
	playerStatsLabel.hide()


func _on_enemy_mouse_entered():
	enemyStatsLabel.show()


func _on_enemy_mouse_exited():
	enemyStatsLabel.hide()

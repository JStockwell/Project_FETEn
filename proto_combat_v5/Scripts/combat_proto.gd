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
	
	Player.set_stats(GameStatus_v5.activePlayer)
	Enemy.set_stats(GameStatus_v5.activeEnemy)
	
	setStatsLabel(playerStatsLabel, GameStatus_v5.activePlayer)
	setStatsLabel(enemyStatsLabel, GameStatus_v5.activeEnemy)
	
	hpLabelEnemy.text = str(Enemy.get_health())
	hpLabelPlayer.text = str(Player.get_health())
	
	change_phase()

	
func change_phase():
	buttonAttack.disabled = true
	
	if playerAttacked:
		phaseText.text = "Enemy Phase"
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
			GameStatus_v5.set_active_enemy_hp(finalHP)
			playerAttacked = !playerAttacked
			change_phase()
			
		else:
			GameStatus_v5.set_active_player_hp(finalHP)
			await wait(1.5)
			get_tree().change_scene_to_file("res://proto_combat_v5/Scenes/choose_combat.tscn")
		
	else:
		buttonAttack.disabled = true
		
		if playerAttacked:
			phaseText.text = "YOU LOST"
			GameStatus_v5.set_active_player_hp(0)
		else:
			phaseText.text = "ENEMY DEFEATED"
			GameStatus_v5.set_active_enemy_hp(0)
			
		phaseText.show()
		defender.death(damage)
		save_result()
		await wait(1.5)

		if not playerAttacked:
			var enemyHealthPool = 0
			for enemy in GameStatus_v5.enemies:
				enemyHealthPool += GameStatus_v5.enemies[enemy]["current_health"]
			
			if enemyHealthPool <= 0:
				get_tree().change_scene_to_file("res://proto_combat_v5/Scenes/victory.tscn")
			else:
				get_tree().change_scene_to_file("res://proto_combat_v5/Scenes/choose_combat.tscn")

		else:
			var playerHealthPool = 0
			for player in GameStatus_v5.party:
				playerHealthPool += GameStatus_v5.party[player]["current_health"]
				
			if playerHealthPool <= 0:
				print("HELP")
				get_tree().change_scene_to_file("res://proto_combat_v5/Scenes/lose.tscn")
			else:
				get_tree().change_scene_to_file("res://proto_combat_v5/Scenes/choose_combat.tscn")


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
	GameStatus_v5.party[GameStatus_v5.activePlayer["name"]] = GameStatus_v5.activePlayer
	var enemyId = GameStatus_v5.activeEnemy["id"]
	GameStatus_v5.activeEnemy.erase("id")
	GameStatus_v5.enemies[enemyId] = GameStatus_v5.activeEnemy

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

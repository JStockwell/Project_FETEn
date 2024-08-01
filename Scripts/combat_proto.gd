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

var isPlayerPhase = true

signal quitGame

# Called when the node enters the scene tree for the first time.
func _ready():
	Player.set_stats(GameStatus.activePlayer)
	Enemy.set_stats(GameStatus.activeEnemy)
	
	setStatsLabel(playerStatsLabel, GameStatus.activePlayer)
	setStatsLabel(enemyStatsLabel, GameStatus.activeEnemy)
	
	buttonAttack.disabled = true
	hpLabelEnemy.text = str(Enemy.get_health())
	hpLabelPlayer.text = str(Player.get_health())
	change_phase()
	
func _input(event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		emit_signal("quitGame")

	
func change_phase():
	buttonAttack.disabled = true
	if isPlayerPhase:
		phaseText.text = "Player Phase"
	else:
		phaseText.text = "Enemy Phase"
	
	phaseText.show()
	await wait(2.0)
	phaseText.hide()
	
	if isPlayerPhase:
		buttonAttack.disabled = false
	else:
		enemy_attack()
		
	isPlayerPhase = !isPlayerPhase


func _on_button_attack_pressed():
	attack_calculation(Enemy, Player.get_attack(), hpLabelEnemy, true)
	
func enemy_attack():
	attack_calculation(Player, Enemy.get_attack(), hpLabelPlayer, false)
		
func attack_calculation(defender, attack, label, isPlayer):
	var finalHP = defender.get_health()
	var damage = await damage_calculation(attack, defender.get_defense())
	finalHP -= damage
	defender.set_health(finalHP)
	label.text = str(max(0,finalHP))
	
	if finalHP > 0:
		change_phase()
	else:
		buttonAttack.disabled = true
		
		if isPlayer:
			phaseText.text = "VICTORY"
		else:
			phaseText.text = "YOU LOST"
			
		phaseText.show()
		defender.death(damage)
		await wait(1.5)
		endText.show()
		await Signal(self,"quitGame")
		get_tree().quit()
	
func damage_calculation(att, def):
	var damage = 0
	damage = int(att * 0.1 * def + randi_range(0, 3))
	damageIndicator.text = "-" + str(damage)
	damageIndicator.show()
	await wait(1.0)
	damageIndicator.hide()
	return damage
	
func setStatsLabel(label, statsSet):
	label.text = "Name: {name}\nMax HP: {maxHP}\nAttack: {att}\nDefense: {def}".format({"name": statsSet["name"], "maxHP": statsSet["max_health"], "att": statsSet["attack"], "def": statsSet["defense"]})
	
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

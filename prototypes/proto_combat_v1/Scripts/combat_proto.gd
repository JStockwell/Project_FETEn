extends Node3D

@onready
var hpLabelPlayer = $UI/HPPlayer

@onready
var hpLabelEnemy = $UI/HPEnemy

@onready
var buttonAttack = $UI/ButtonAttack

@onready
var phaseText = $UI/PhaseText

@onready
var damageIndicator = $"UI/DamageIndicator"

# Stats: HP, Att, Def
@export
var playerStats = [45, 14, 6]
@export
var enemyStats = [30, 10, 3]

var isPlayerPhase = true

var playerHP = playerStats[0]
var enemyHP = enemyStats[0]

# Called when the node enters the scene tree for the first time.
func _ready():
	buttonAttack.disabled = true
	hpLabelEnemy.text = str(enemyHP)
	hpLabelPlayer.text = str(playerHP)
	change_phase()

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
	enemyHP = await attack_calculation(enemyHP, hpLabelEnemy, playerStats[1], enemyStats[2])
	if enemyHP > 0:
		change_phase()
	else:
		buttonAttack.disabled = true
		phaseText.text = "VICTORY"
		phaseText.show()
		
		await wait(2.0)
		get_tree().quit()


func enemy_attack():
	playerHP = await attack_calculation(playerHP, hpLabelPlayer, enemyStats[1], playerStats[2])
	if enemyHP > 0:
		change_phase()


func attack_calculation(hp, label, att, def):
	hp -= await damage_calculation(att, def)
	label.text = str(hp)
	return hp


func damage_calculation(att, def):
	var damage = 0
	damage = int(att * 0.1 * def + randi_range(0, 3))
	damageIndicator.text = "-" + str(damage)
	damageIndicator.show()
	await wait(1.0)
	damageIndicator.hide()
	return damage
	
func wait(time):
	await get_tree().create_timer(time).timeout

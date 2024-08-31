extends Control

@onready
var debugSlider = $DebugSlider
@onready
var healthBar = $HealthBar

func _process(delta):
	print(debugSlider.get_value())
	healthBar.set_value_no_signal(debugSlider.get_value())

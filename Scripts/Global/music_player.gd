extends AudioStreamPlayer

var music

func _play(music: AudioStream, volume = 0.0):
	if stream == music: return
	
	stream = music
	volume_db = volume
	play()
	

func play_main_cafe_music():
	music = load("res://Assets/Music/Menu/Cafe theme v1.mp3")
	_play(music)


func play_mapCombat_music(song):
	music = load(song)
	_play(music)


func play_fx(volume = -10.0):
	var effect = load("res://Assets/Music/Weapons/MeleeSwingsPack_96khz_Stereo_NormalSwings39.wav")
	var fx = AudioStreamPlayer.new()
	fx.stream = effect
	fx.volume_db = volume
	add_child(fx)
	fx.play()
	
	await fx.finished
	fx.queue_free()
	
	
func play_crit(volume = 0.0):
	var path
	var r = randi_range(1,10)
	if r == 1:
		path = load("res://Assets/Music/Combat/Crit/10crit.mp3")
	else:
		path = load("res://Assets/Music/Combat/Crit/90crit.mp3")
	
	var fx = AudioStreamPlayer.new()
	fx.stream = path
	fx.volume_db = volume
	add_child(fx)
	fx.play()
	
	await fx.finished
	fx.queue_free()
	
	
# TODO wait until the end
func play_click(volume = -10.0):
	var effect = load("res://Assets/Music/UI/Click.mp3")
	var click = AudioStreamPlayer.new()
	click.stream = effect
	click.volume_db = volume
	add_child(click)
	click.play()
	
	await click.finished
	
	click.queue_free()

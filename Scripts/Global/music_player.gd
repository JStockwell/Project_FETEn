extends AudioStreamPlayer

var music

func _play(music: AudioStream, volume):
	if stream == music: return
	
	stream = music
	volume_db = volume
	play()
	
	
func play_music(music_path, volume = 0.0):
	if GameStatus.testMode == false:
		if music_path == "main_music":
			music_path = "res://Assets/Music/Menu/Cafe and music v1.mp3"
		
		var music = load(music_path)
		_play(music, volume)
		

func play_fx(fx_path, volume = 5.0):
	if GameStatus.testMode == false:
		if fx_path == "crit":
			var r = randi_range(1,10)
			if r == 1:
				fx_path = "res://Assets/Music/Combat/Crit/10crit.mp3"
			else:
				fx_path = "res://Assets/Music/Combat/Crit/90crit.mp3"
				
		if fx_path == "click":
			fx_path = "res://Assets/Music/UI/Click.mp3"
		
		var fx = AudioStreamPlayer.new()
		fx.stream = load(fx_path)
		fx.volume_db = volume
		add_child(fx)
		fx.play()
		
		await fx.finished
		fx.queue_free()

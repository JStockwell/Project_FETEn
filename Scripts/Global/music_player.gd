extends AudioStreamPlayer

var music

# Songs
enum SOUNDS {
	PHYS_MISS = 0,
	MAGIC_MISS = 1, 
	ADRAN__ANCHORING_STRIKE = 2,
	ADRAN__BLADESONG = 3,
	ADRAN__FLAMING_DAGGERS = 4,
	AZ_SAM__BOOST_LV1 = 5,
	AZ_SAM__BOOST_LV2 = 6,
	EDGAR__MEND_FLESH = 7,
	EDGAR__NERO_NERO = 8,
	EDGAR__SHADOW_BALL = 9,
	LYSTRA__BESTOW_LIFE = 10,
	LYSTRA__CREATORS_TOUCH = 11,
	LYSTRA__ROCK_THROW = 12,
	MAGE_ORC__ICICLE = 13,
	SALVADOR__ACTION_SURGE = 14,
	DAGGER_MELEE = 15,
	SWORD_MELEE = 16,
	SALVADOR_RANGED = 17,
	GOBLIN_RANGED = 18,
	ORC_RANGED = 19,
	UI__CLICK = 20,
	UI__START_BATTLE = 21,
	END_COMBAT__DEFEAT = 22,
	END_COMBAT__VICTORY = 23,
	STAGE_1_2 = 24,
	STAGE_3_4 = 25,
	CAFE = 26,
	CAFE_MUSIC = 27,
	CRIT_90 = 28,
	CRIT_10 = 29
}


const soundArray = [
	"res://Assets/Music/Fx/Combat/Miss/Phys miss.mp3",
	"res://Assets/Music/Fx/Combat/Miss/Magic miss.mp3",
	"res://Assets/Music/Fx/Combat/Skills/Adran - Anchoring Strike.mp3",
	"res://Assets/Music/Fx/Combat/Skills/Adran - Bladesong.mp3",
	"res://Assets/Music/Fx/Combat/Skills/Adran - Flaming Daggers.mp3",
	"res://Assets/Music/Fx/Combat/Skills/AzSam - Boost lv1.mp3",
	"res://Assets/Music/Fx/Combat/Skills/AzSam - Boost lv2.mp3",
	"res://Assets/Music/Fx/Combat/Skills/Edgar - Mend Flesh.mp3",
	"res://Assets/Music/Fx/Combat/Skills/Edgar - Nero Nero.mp3",
	"res://Assets/Music/Fx/Combat/Skills/Edgar - Shadow Ball.mp3",
	"res://Assets/Music/Fx/Combat/Skills/Lystra - Bestow Life.mp3",
	"res://Assets/Music/Fx/Combat/Skills/Lystra - Creators Touch.mp3",
	"res://Assets/Music/Fx/Combat/Skills/Lystra - Rock Throw.mp3",
	"res://Assets/Music/Fx/Combat/Skills/Mage Orc - Icicle.mp3",
	"res://Assets/Music/Fx/Combat/Skills/Salvador - Action Surge.mp3",
	"res://Assets/Music/Fx/Combat/Weapons/Dagger Melee.mp3",
	"res://Assets/Music/Fx/Combat/Weapons/Sword Melee.mp3",
	"res://Assets/Music/Fx/Combat/Weapons/Salvador Ranged.mp3",
	"res://Assets/Music/Fx/Combat/Weapons/Goblin Ranged.mp3",
	"res://Assets/Music/Fx/Combat/Weapons/Orc Ranged.mp3",
	"res://Assets/Music/Fx/UI/Click.mp3",
	"res://Assets/Music/Fx/UI/Start Battle.mp3",
	"res://Assets/Music/Songs/CombatMap/EndCombat/Defeat.mp3",
	"res://Assets/Music/Songs/CombatMap/EndCombat/Victory.mp3",
	"res://Assets/Music/Songs/CombatMap/Stages/Stage_12.mp3",
	"res://Assets/Music/Songs/CombatMap/Stages/Stage_34.mp3",
	"res://Assets/Music/Songs/Menu/Just Cafe v2.mp3",
	"res://Assets/Music/Songs/Menu/Cafe and music v1.mp3",
	"res://Assets/Music/Fx/Combat/Crit/90crit.mp3",
	"res://Assets/Music/Fx/Combat/Crit/10crit.mp3"
]


# Funcs
func _play(music: AudioStream, volume):
	if stream == music: return
	
	stream = music
	volume_db = volume
	play()
	
	
func play_music(music_path, volume = 0.0):
	if GameStatus.testMode == false:
		if music_path is int:
			music_path = soundArray[music_path]
		
		var music = load(music_path)
		_play(music, volume)
		

func play_fx(fx_path, volume = 5.0):
	if GameStatus.testMode == false:
		if fx_path is String and fx_path == "crit":
			var r = randi_range(1,10)
			if r == 1:
				fx_path = MusicPlayer.SOUNDS.CRIT_10
			else:
				fx_path = MusicPlayer.SOUNDS.CRIT_90
				
		if fx_path is int:
			fx_path = soundArray[fx_path]
		
		var fx = AudioStreamPlayer.new()
		fx.stream = load(fx_path)
		fx.volume_db = volume
		add_child(fx)
		fx.play()
		
		await fx.finished
		fx.queue_free()
		
		

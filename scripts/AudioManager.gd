extends Node

var playback:AudioStreamPlaybackPolyphonic
var master_id
var sfx_id
#Audio list
var audio_list = {
	"button":AudioData.new(preload("res://sound/button_randomizer.tres")),
	"task_finish":AudioData.new(preload("res://sound/confirmation_002.ogg"),-10)
}

func _enter_tree():
	master_id = AudioServer.get_bus_index("Master")
	sfx_id = AudioServer.get_bus_index("SFX")
	
	# Create an audio player
	var player := AudioStreamPlayer.new()
	add_child(player)

	# Create a polyphonic stream so we can play sounds directly from it
	var stream = AudioStreamPolyphonic.new()
	stream.polyphony = 32
	player.stream = stream
	player.bus = "SFX"
	player.play()
	# Get the polyphonic playback stream to play sounds
	playback = player.get_stream_playback()

	get_tree().node_added.connect(_on_node_added)

func play_audio(name:String):
	var audio: AudioData = audio_list[name]
	playback.play_stream(audio.path,0,audio.volume,audio.pitch)

class AudioData:
	var path : AudioStream
	var volume : float
	var pitch : float

	func _init(n_path:AudioStream, n_volume:float = 0., n_pitch:float = 1.):
		path = n_path
		volume = n_volume
		pitch = n_pitch

func _on_node_added(node:Node):
	if not (node is Button):
		return
	if not node.is_connected("pressed", play_audio_button):
		node.pressed.connect(play_audio_button)
		
func play_audio_button():
	play_audio("button")

#region Audio Bus get set
func set_sfx_db(db):
	AudioServer.set_bus_volume_db(sfx_id, db)

func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(sfx_id, linear_to_db(value))
	AudioServer.set_bus_mute(sfx_id, value < .05)

func get_sfx_db():
	return AudioServer.get_bus_volume_db(sfx_id)
	
func get_sfx_value():
	return db_to_linear(get_sfx_db())
#endregion

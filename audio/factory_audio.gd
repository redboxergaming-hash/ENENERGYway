extends Node
var effects: AudioStreamPlayer
var motor: AudioStreamPlayer3D

func _ready() -> void:
	var session := get_parent()
	effects = AudioStreamPlayer.new()
	effects.volume_db = -9.0
	add_child(effects)
	motor = AudioStreamPlayer3D.new()
	var stream := preload("res://audio/machine_loop.wav").duplicate() as AudioStreamWAV
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = 22050
	motor.stream = stream
	motor.volume_db = -18.0
	motor.unit_size = 4.0
	motor.position = session.mixer.position
	add_child(motor)
	session.player.grabber.held_changed.connect(func(item):
		if item != null: _play(preload("res://audio/pickup.wav")))
	session.mixer.state_changed.connect(func(_a, b):
		if b == MachineBase.State.PROCESSING: motor.play()
		else: motor.stop())
	session.filler.can_created.connect(func(_item): _play(preload("res://audio/can_ready.wav")))
	session.orders.delivery_accepted.connect(func(_count): _play(preload("res://audio/delivery.wav")))
	session.orders.order_settled.connect(func(success, _amount):
		if success: _play(preload("res://audio/order_complete.wav")))

func _play(stream: AudioStream) -> void:
	effects.stream = stream
	effects.play()

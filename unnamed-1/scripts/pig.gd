extends CharacterBody2D

@export var speed: float = 30.0
@export var max_hp: int = 3
@export var walk_time_min: float = 0.8
@export var walk_time_max: float = 2.0
@export var idle_time_min: float = 0.5
@export var idle_time_max: float = 1.5
@export var oink_time_min: float = 3.0 # heo kêu ụt ịt ngẫu nhiên mỗi 3-8 giây
@export var oink_time_max: float = 8.0
@export var knockback_force: float = 130.0 # lực đẩy lùi khi trúng đạn
@export var panic_time: float = 2.2 # thời gian bỏ chạy hoảng loạn
@export var panic_speed_mult: float = 3.0 # chạy nhanh gấp mấy lần lúc hoảng
@export var pork_scene: PackedScene = preload("res://scenes/pork.tscn")

@onready var body: AnimatedSprite2D = $Body
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var oink_sound: AudioStreamPlayer2D = $OinkSound
@onready var blood: CPUParticles2D = $BloodParticles

var _hp: int
var _dir: Vector2 = Vector2.ZERO
var _state_timer: float = 0.0
var _oink_timer: float = 0.0
var _dead: bool = false
var _knockback: Vector2 = Vector2.ZERO # vận tốc đẩy lùi, tắt dần
var _panic_timer: float = 0.0 # > 0 nghĩa là đang hoảng loạn
var _panic_turn_timer: float = 0.0 # hẹn giờ đổi hướng loạn xạ

func _ready() -> void:
	_hp = max_hp
	# Lệch pha ngẫu nhiên để đàn heo không cử động cùng lúc
	_state_timer = randf_range(0.0, idle_time_max)
	_oink_timer = randf_range(oink_time_min, oink_time_max)


func _physics_process(delta: float) -> void:
	# Tiếng heo kêu bình thường, ngẫu nhiên theo thời gian
	_oink_timer -= delta
	if _oink_timer <= 0.0:
		_oink_timer = randf_range(oink_time_min, oink_time_max)
		if not hurt_sound.playing: # đang kêu đau thì thôi khỏi ụt ịt
			oink_sound.pitch_scale = randf_range(0.9, 1.1) # mỗi lần kêu hơi khác nhau
			oink_sound.play()

	var move_speed := speed
	if _panic_timer > 0.0:
		# Đang hoảng loạn: chạy nhanh, thỉnh thoảng bẻ hướng loạn xạ
		_panic_timer -= delta
		_panic_turn_timer -= delta
		if _panic_turn_timer <= 0.0:
			_panic_turn_timer = randf_range(0.15, 0.45)
			# Bẻ hướng ngẫu nhiên quanh hướng đang chạy (zigzag)
			_dir = _dir.rotated(randf_range(-1.2, 1.2)).normalized()
		move_speed = speed * panic_speed_mult
		if _panic_timer <= 0.0:
			_dir = Vector2.ZERO # hết hoảng thì đứng thở
			_state_timer = randf_range(idle_time_min, idle_time_max)
	else:
		# Đi lang thang bình thường
		_state_timer -= delta
		if _state_timer <= 0.0:
			_pick_next_state()

	# Đẩy lùi tắt dần theo thời gian
	_knockback = _knockback.move_toward(Vector2.ZERO, 600.0 * delta)
	velocity = _dir * move_speed + _knockback
	move_and_slide()

	if _dir != Vector2.ZERO:
		body.play("walk")
		body.flip_h = _dir.x < 0.0
		# Hoảng loạn thì chân chạy nhanh hơn
		body.speed_scale = 1.8 if _panic_timer > 0.0 else 1.0
	else:
		body.play("idle")
		body.speed_scale = 1.0


# Luân phiên: đứng nghỉ -> đi hướng ngẫu nhiên -> đứng nghỉ ...
func _pick_next_state() -> void:
	if _dir == Vector2.ZERO:
		_dir = Vector2.RIGHT.rotated(randf_range(0.0, TAU))
		_state_timer = randf_range(walk_time_min, walk_time_max)
	else:
		_dir = Vector2.ZERO
		_state_timer = randf_range(idle_time_min, idle_time_max)


# Đạn gọi hàm này khi trúng heo; hit_dir = hướng viên đạn đang bay
func take_damage(amount: int, hit_dir: Vector2 = Vector2.ZERO) -> void:
	if _dead:
		return
	_hp -= amount
	# Tiếng heo kêu đau khi dính đạn
	oink_sound.stop()
	hurt_sound.pitch_scale = randf_range(0.95, 1.1)
	hurt_sound.play()
	# Văng máu theo hướng viên đạn
	blood.direction = hit_dir if hit_dir != Vector2.ZERO else Vector2.DOWN
	blood.restart()
	if _hp <= 0:
		_die()
		return
	# Đẩy lùi theo hướng đạn
	_knockback = hit_dir * knockback_force
	# Bỏ chạy hoảng loạn theo hướng bị bắn (chạy xa khỏi nguồn đạn)
	_panic_timer = panic_time
	_panic_turn_timer = randf_range(0.15, 0.45)
	_dir = hit_dir.rotated(randf_range(-0.5, 0.5)).normalized() if hit_dir != Vector2.ZERO else Vector2.RIGHT.rotated(randf_range(0.0, TAU))
	# Nhấp nháy đỏ khi trúng đạn
	body.modulate = Color(1.0, 0.35, 0.35)
	create_tween().tween_property(body, "modulate", Color.WHITE, 0.15)


# Heo chết: rớt ra cục thịt tại chỗ, ẩn xác nhưng chờ tiếng kêu xong mới xoá
func _die() -> void:
	_dead = true
	if pork_scene != null:
		var pork := pork_scene.instantiate()
		get_parent().add_child(pork)
		pork.global_position = global_position
	# Ẩn heo + tắt va chạm ngay, để node sống thêm cho tiếng kêu + máu phát hết
	set_physics_process(false)
	body.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	hurt_sound.finished.connect(queue_free)
	# Dự phòng: nếu tiếng kêu không phát được thì vẫn xoá heo sau 2 giây
	get_tree().create_timer(2.0).timeout.connect(queue_free)

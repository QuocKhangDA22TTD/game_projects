extends CharacterBody2D

@export var speed: float = 30.0
@export var max_hp: int = 3
@export var walk_time_min: float = 0.8
@export var walk_time_max: float = 2.0
@export var idle_time_min: float = 0.5
@export var idle_time_max: float = 1.5

@onready var body: AnimatedSprite2D = $Body

var _hp: int
var _dir: Vector2 = Vector2.ZERO
var _state_timer: float = 0.0

func _ready() -> void:
	_hp = max_hp
	# Lệch pha ngẫu nhiên để đàn heo không cử động cùng lúc
	_state_timer = randf_range(0.0, idle_time_max)


func _physics_process(delta: float) -> void:
	_state_timer -= delta
	if _state_timer <= 0.0:
		_pick_next_state()

	velocity = _dir * speed
	move_and_slide()

	if _dir != Vector2.ZERO:
		body.play("walk")
		body.flip_h = _dir.x < 0.0
	else:
		body.play("idle")


# Luân phiên: đứng nghỉ -> đi hướng ngẫu nhiên -> đứng nghỉ ...
func _pick_next_state() -> void:
	if _dir == Vector2.ZERO:
		_dir = Vector2.RIGHT.rotated(randf_range(0.0, TAU))
		_state_timer = randf_range(walk_time_min, walk_time_max)
	else:
		_dir = Vector2.ZERO
		_state_timer = randf_range(idle_time_min, idle_time_max)


# Đạn gọi hàm này khi trúng heo
func take_damage(amount: int) -> void:
	_hp -= amount
	if _hp <= 0:
		queue_free()
		return
	# Nhấp nháy đỏ khi trúng đạn
	body.modulate = Color(1.0, 0.35, 0.35)
	create_tween().tween_property(body, "modulate", Color.WHITE, 0.15)

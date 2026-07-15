extends CharacterBody2D

@export var speed: float = 120.0
@export var fire_rate: float = 0.2
@export var bullet_scene: PackedScene

@onready var body: AnimatedSprite2D = $Body
@onready var gun_pivot: Node2D = $GunPivot
@onready var gun_sprite: Sprite2D = $GunPivot/GunSprite
@onready var muzzle: Marker2D = $GunPivot/Muzzle

var _fire_cooldown: float = 0.0

func _physics_process(delta: float) -> void:
	_move()
	_aim()
	_shoot(delta)


func _move() -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	move_and_slide()
	if dir != Vector2.ZERO:
		body.play("walk")
	else:
		body.play("idle")


func _aim() -> void:
	var to_mouse := get_global_mouse_position() - global_position
	gun_pivot.rotation = to_mouse.angle()
	# Lật thân theo hướng chuột
	body.flip_h = to_mouse.x < 0.0
	# Khi súng chĩa sang trái, lật dọc để súng không bị lộn ngược
	gun_sprite.flip_v = absf(gun_pivot.rotation) > PI / 2.0


func _shoot(delta: float) -> void:
	_fire_cooldown -= delta
	if bullet_scene == null:
		return
	if Input.is_action_pressed("shoot") and _fire_cooldown <= 0.0:
		_fire_cooldown = fire_rate
		var bullet := bullet_scene.instantiate()
		bullet.global_position = muzzle.global_position
		bullet.direction = Vector2.RIGHT.rotated(gun_pivot.rotation)
		get_parent().add_child(bullet)

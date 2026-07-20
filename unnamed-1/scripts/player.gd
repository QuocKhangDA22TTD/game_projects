extends CharacterBody2D

@export var speed: float = 60.0
@export var fire_rate: float = 0.2
@export var bullet_scene: PackedScene
@export var recoil_distance: float = 12.0 # súng giật lùi bao nhiêu px mỗi phát
@export var shake_strength: float = 0.25 # độ rung màn hình khi bắn

@onready var body: AnimatedSprite2D = $Body
@onready var gun_pivot: Node2D = $GunPivot
@onready var gun_sprite: Sprite2D = $GunPivot/GunSprite
@onready var muzzle: Marker2D = $GunPivot/Muzzle
@onready var camera: Camera2D = $Camera2D

var _fire_cooldown: float = 0.0
var _gun_rest_position: Vector2
var _shake: float = 0.0

func _ready() -> void:
	_gun_rest_position = gun_sprite.position


func _physics_process(delta: float) -> void:
	_move()
	_aim()
	_shoot(delta)
	_update_effects(delta)


func _move() -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	move_and_slide()
	if dir != Vector2.ZERO:
		body.play("walk")
	else:
		body.play("idle")


func _aim() -> void:
	var to_mouse := get_global_mouse_position() - gun_pivot.global_position
	gun_pivot.rotation = to_mouse.angle()
	# Lật thân theo hướng chuột
	body.flip_h = to_mouse.x < 0.0
	# Khi súng chĩa sang trái, lật dọc để súng không bị lộn ngược
	gun_sprite.flip_v = absf(gun_pivot.rotation) > PI / 2.0
	muzzle.position.y = 1.0 if gun_sprite.flip_v else -1.0


func _shoot(delta: float) -> void:
	_fire_cooldown -= delta
	if bullet_scene == null:
		return
	# is_action_just_pressed: mỗi lần nhấp chuột chỉ bắn 1 phát (semi-auto)
	if Input.is_action_just_pressed("shoot") and _fire_cooldown <= 0.0:
		_fire_cooldown = fire_rate
		var bullet := bullet_scene.instantiate()
		bullet.global_position = muzzle.global_position
		bullet.direction = Vector2.RIGHT.rotated(gun_pivot.rotation)
		get_parent().add_child(bullet)
		_apply_recoil()


# Giật súng lùi về phía sau + rung màn hình
func _apply_recoil() -> void:
	gun_sprite.position = _gun_rest_position + Vector2(-recoil_distance, 0)
	_shake = shake_strength


# Mỗi frame: súng trượt về vị trí cũ, camera rung tắt dần
func _update_effects(delta: float) -> void:
	gun_sprite.position = gun_sprite.position.lerp(_gun_rest_position, 12.0 * delta)
	if _shake > 0.05:
		_shake = lerpf(_shake, 0.0, 10.0 * delta)
		camera.offset = Vector2(randf_range(-_shake, _shake), randf_range(-_shake, _shake))
	else:
		_shake = 0.0
		camera.offset = Vector2.ZERO


# InventoryUI gọi khi click ô: thả item ra đất cạnh chân, lụm lại được sau cooldown
func drop_item(id: String) -> void:
	var scene: PackedScene = Inventory.ITEM_DB[id].scene
	var item := scene.instantiate()
	item.pickup_cooldown = 0.8
	get_parent().add_child(item)
	item.global_position = global_position + Vector2.RIGHT.rotated(randf_range(0.0, TAU)) * 14.0

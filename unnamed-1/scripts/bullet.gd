extends Area2D

@export var speed: float = 460.0 # bay nhanh + có lực hơn (cũ: 260)
@export var lifetime: float = 2.0
@export var damage: int = 1
@export var trail_length: int = 12 # số điểm tối đa của vệt bóng mờ

var direction: Vector2 = Vector2.RIGHT

@onready var trail: Line2D = $Trail

func _ready() -> void:
	rotation = direction.angle()
	# Trail dùng top_level nên vẽ theo toạ độ global, khởi tạo tại vị trí đạn
	trail.clear_points()


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	_update_trail()
	lifetime -= delta
	if lifetime <= 0.0:
		_fade_out()


func _update_trail() -> void:
	trail.add_point(global_position)
	while trail.get_point_count() > trail_length:
		trail.remove_point(0)


func _on_body_entered(body: Node2D) -> void:
	# Gây sát thương nếu vật thể có hàm take_damage (heo, enemy sau này)
	if body.has_method("take_damage"):
		body.take_damage(damage)
	_fade_out()


# Ẩn đạn nhưng để vệt bóng mờ tan dần rồi mới xoá hẳn
func _fade_out() -> void:
	set_physics_process(false)
	set_deferred("monitoring", false)
	$Sprite2D.visible = false
	$Glow.visible = false
	$Light.visible = false
	var tw := create_tween()
	tw.tween_property(trail, "modulate:a", 0.0, 0.12)
	tw.tween_callback(queue_free)

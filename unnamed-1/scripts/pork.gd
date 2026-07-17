extends Area2D

# Đồ vừa thả ra có thời gian chờ ngắn để không dính ngay lại vào túi
var pickup_cooldown: float = 0.0

func _ready() -> void:
	# Hiệu ứng nảy nhẹ khi cục thịt rớt ra
	scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.15)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)


func _physics_process(delta: float) -> void:
	if pickup_cooldown > 0.0:
		pickup_cooldown -= delta
		return
	# Tự nhặt khi player chạm (poll để xử lý cả khi player đứng đè sẵn lên thịt)
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			if Inventory.add_item("pork"):
				queue_free()
			return

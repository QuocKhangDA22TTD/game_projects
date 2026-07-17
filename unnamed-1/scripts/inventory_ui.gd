extends Control

# UI túi đồ 3x3 — chỉ vẽ lại khi dữ liệu Inventory đổi (signal changed).

@onready var grid: GridContainer = $Panel/Grid

func _ready() -> void:
	Inventory.changed.connect(_refresh)
	for i in grid.get_child_count():
		grid.get_child(i).pressed.connect(_on_slot_pressed.bind(i))
	_refresh()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		visible = not visible


func _refresh() -> void:
	for i in grid.get_child_count():
		var button: Button = grid.get_child(i)
		var slot = Inventory.slots[i]
		if slot == null:
			button.icon = null
			button.text = ""
		else:
			button.icon = Inventory.ITEM_DB[slot.id].icon
			button.text = "x%d" % slot.count


# Click vào ô có đồ: bớt 1 và thả ra đất cạnh player (lụm lại được)
func _on_slot_pressed(index: int) -> void:
	var id := Inventory.remove_one(index)
	if id == "":
		return
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.drop_item(id)

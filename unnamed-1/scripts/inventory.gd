extends Node

# Túi đồ singleton (autoload) — dữ liệu tách khỏi UI.
# Mỗi ô: null hoặc {"id": String, "count": int}

signal changed

const SIZE := 9

# Thêm item mới chỉ cần thêm 1 dòng: icon hiển thị + scene khi thả ra đất
const ITEM_DB := {
	"pork": {
		"icon": preload("res://assets/pork.png"),
		"scene": preload("res://scenes/pork.tscn"),
	},
}

var slots: Array = [null, null, null, null, null, null, null, null, null]


# Nhặt vào túi: ưu tiên chồng vào ô cùng loại, hết thì ô trống đầu tiên.
# Trả về false nếu túi đầy (item nằm lại đất, không mất).
func add_item(id: String, count: int = 1) -> bool:
	for slot in slots:
		if slot != null and slot.id == id:
			slot.count += count
			changed.emit()
			return true
	for i in SIZE:
		if slots[i] == null:
			slots[i] = {"id": id, "count": count}
			changed.emit()
			return true
	return false


# Bớt 1 khỏi ô index, trả về id vừa bớt ("" nếu ô trống).
func remove_one(index: int) -> String:
	var slot = slots[index]
	if slot == null:
		return ""
	var id: String = slot.id
	slot.count -= 1
	if slot.count <= 0:
		slots[index] = null
	changed.emit()
	return id

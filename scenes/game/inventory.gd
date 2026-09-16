extends Node

signal coupons_changed(new_value: int)
signal items_changed(new_items: Array[Item])

var nostalgia_coupons: int:
	get:
		return _nostalgia_coupons

var items: Array[Item]:
	get:
		var read_only_items: Array[Item] = _items.duplicate()
		read_only_items.make_read_only()
		return read_only_items

var _nostalgia_coupons: int = 0
#TODO: remove once fishing adds item
var _items: Array[Item] = [Item.new(ItemCatalog.RUSTY_KEY, Item.Deterioration.DIRTY)]

func spend_coupons(cost: int) -> bool:
	assert(cost >= 0)
	if nostalgia_coupons >= cost:
		_nostalgia_coupons -= cost
		coupons_changed.emit(nostalgia_coupons)
		return true
	return false

func earn_money(amount: int) -> void:
	assert(amount >= 0)
	_nostalgia_coupons += amount
	coupons_changed.emit(nostalgia_coupons)

func use_item(item: Item) -> bool:
	if item in _items:
		_items.erase(item)
		items_changed.emit(items)
		return true
	return false

func add_item(item: Item) -> void:
	_items.append(item)
	items_changed.emit(items)

func get_first_restorable_item(deterioration: Item.Deterioration) -> Item:
	for item in _items:
		if item.deterioration == deterioration:
			return item
	return null

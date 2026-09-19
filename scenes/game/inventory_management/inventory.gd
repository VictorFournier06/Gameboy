extends Node

signal coupons_changed(new_value: int)
signal items_changed(new_items: Array[Item])

var nostalgia_coupons: int:
	get:
		return _nostalgia_coupons

var items: Array[Item]:
	get:
		var read_only_items: Array[Item] = _inventory_items.duplicate()
		read_only_items.make_read_only()
		return read_only_items

var _nostalgia_coupons: int = 0
var _inventory_items: Array[Item] = []
var _item_pool: Array[ItemType] = [] #stack

func _ready() -> void:
	for item_type in ItemCatalog.ARTEFACTS:
		for _i in maxi(1, item_type.broken_pieces.size()):
			_item_pool.append(item_type)
	_item_pool.shuffle()

func spend_coupons(cost: int) -> bool:
	assert(cost >= 0)
	if nostalgia_coupons >= cost:
		_nostalgia_coupons -= cost
		coupons_changed.emit(nostalgia_coupons)
		return true
	return false

func earn_coupons(amount: int) -> void:
	assert(amount >= 0)
	_nostalgia_coupons += amount
	coupons_changed.emit(nostalgia_coupons)

func use_item(item: Item) -> bool:
	if item in _inventory_items:
		_inventory_items.erase(item)
		items_changed.emit(items)
		return true
	return false

func add_item(item: Item) -> void:
	_inventory_items.append(item)
	items_changed.emit(items)

func get_first_restorable_item(deteriorations: Array[Item.Deterioration]) -> Item:
	for item in _inventory_items:
		if item.deterioration in deteriorations:
			return item
	return null

func get_random_item_from_pool() -> ItemType:
	if _item_pool.is_empty():
		return null
	return _item_pool.pop_back() #remove from pool

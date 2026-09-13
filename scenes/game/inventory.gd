extends Node

signal money_changed(new_value: int)
signal items_changed(new_items: Array[Item])

var money: int:
	get:
		return _money

var items: Array[Item]:
	get:
		var read_only_items: Array[Item] = _items.duplicate()
		read_only_items.make_read_only()
		return read_only_items

var _money: int = 0
var _items: Array[Item] = [Item.new(ItemCatalog.RUSTY_KEY, Item.Deterioration.DIRTY)] #WIP

func spend_money(cost: int) -> bool:
	assert(cost >= 0)
	if money >= cost:
		_money -= cost
		money_changed.emit(money)
		return true
	return false

func earn_money(amount: int) -> void:
	assert(amount >= 0)
	_money += amount
	money_changed.emit(money)

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

extends Resource
class_name SlotData

const max_stack_size: int = 99

@export var item_data: ItemData
@export_range(1, max_stack_size) var quantity: int = 1: set = set_quantity 

func set_quantity(value: int) -> void: 
	quantity = value 
	if quantity > 1 and not item_data.stackable:
		quantity = 1
		push_error("%s is not stackable, setting quantity to 1" % item_data.name)

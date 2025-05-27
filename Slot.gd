extends PanelContainer

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var quantity_label: Label = $QuantityLabel

func set_slot_data(slot_data: SlotData) -> void: 
	if slot_data == null or slot_data.item_data == null:
		texture_rect.texture = null
		tooltip_text = ""
		quantity_label.hide()
	else:
		var item_data = slot_data.item_data
		texture_rect.texture = item_data.texture 
		tooltip_text = "%s\n%s\n%s" % [item_data.name, item_data.type, item_data.description]

	if slot_data.quantity > 1:
		quantity_label.text= "x%s" % slot_data.quantity
		quantity_label.show()

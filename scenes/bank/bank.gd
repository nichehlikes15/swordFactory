extends Node

@export var cash_label : Label

@export var Slot1 : Node
@export var Slot2 : Node
@export var Slot3 : Node
@export var Slot4 : Node
@export var Slot5 : Node
@export var Slot6 : Node
@export var Slot7 : Node
@export var Slot8 : Node

@export var Slot1AscenderButton : Button
@export var Slot2AscenderButton : Button
@export var Slot3AscenderButton : Button
@export var Slot4AscenderButton : Button
@export var Slot5AscenderButton : Button
@export var Slot6AscenderButton : Button
@export var Slot7AscenderButton : Button
@export var Slot8AscenderButton : Button

var rarities = preload("uid://b4sjsweht8pq1").new()
var save_manager = preload("uid://cyeqeyfigsnwc").new()
var occupied_stations = {
	"Slot1": false,
	"Slot2": false,
	"Slot3": false,
	"Slot4": false,
	"Slot5": false,
	"Slot6": false,
	"Slot7": false,
	"Slot8": false
}

func _ready():
	check_banked_items()
	update_cash_value_label()

func update_cash_value_label() -> void:
	cash_label.text = "Cash : £%s" % save_manager.get_value("cash")

func check_banked_items():
	var banked_items = save_manager.get_value("banked_items")
	print("BANKED ITEMS", banked_items)
	if banked_items and banked_items is Dictionary:
		for slot in banked_items.keys():
			if banked_items[slot] != null:
				print(slot, " : ", banked_items[slot])
				create_sword(slot, banked_items[slot])
			else:
				print(slot, " : No data")
	else:
		print("No banked items found.")

func create_sword(slot: String, slot_data: Dictionary) -> void:
	if occupied_stations[slot]:
		print("Slot is already occupied.")
		return

	occupied_stations[slot] = true
	print("Creating sword in ", slot)

	var container : Node
	var button : Button

	match slot:
		"Slot1": container = Slot1; button = Slot1AscenderButton
		"Slot2": container = Slot2; button = Slot2AscenderButton
		"Slot3": container = Slot3; button = Slot3AscenderButton
		"Slot4": container = Slot4; button = Slot4AscenderButton
		"Slot5": container = Slot5; button = Slot5AscenderButton
		"Slot6": container = Slot6; button = Slot6AscenderButton
		"Slot7": container = Slot7; button = Slot7AscenderButton
		"Slot8": container = Slot8; button = Slot8AscenderButton
		_:
			print("Invalid slot!")
			return

	if button == null:
		print("Error: Button for", slot, "is null!")
		return
	
	print("INFO: ", container, button)

	var sword_container := Node.new()
	container.get_parent().add_child(sword_container)
	
	occupied_stations[slot] = sword_container

	# Create a new panel for the sword
	var new_panel := Panel.new()
	new_panel.size = Vector2(130, 150)
	new_panel.position = container.global_position

	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.2, 0.2, 0.2, 0.5)
	new_panel.add_theme_stylebox_override("panel", stylebox)
	sword_container.add_child(new_panel)

	# Sword Button
	var new_button := TextureButton.new()
	sword_container.add_child(new_button)
	new_button.texture_normal = load("res://images/Regular_sword.webp")
	new_button.ignore_texture_size = true
	new_button.stretch_mode = TextureButton.STRETCH_SCALE
	new_button.size = Vector2(120, 120)
	new_button.position = container.global_position

	if slot_data is Dictionary:
		print("SLOT DATA: ", slot_data)
		for key in slot_data.keys():
			print(key, slot_data[key])
			new_panel.set_meta(key, slot_data[key])
	else:
		print("Slot data is not in expected format for ", slot)
	
	print("META DATA: ", new_panel.get_meta_list())

	var molder_rarity = new_panel.get_meta("molderRarities")
	var polisher_rarity = new_panel.get_meta("polisherRarities")
	
	print("DATRATAA: ", new_panel.get_meta_list())

	var molder_multiplier = rarities.molderRarities.get(molder_rarity, {}).get("value_multiplier", 1)
	var polisher_multiplier = rarities.polisherRarities.get(polisher_rarity, {}).get("value_multiplier", 1)

	var base_value = 10
	var total_value = base_value * molder_multiplier * polisher_multiplier

	new_panel.set_meta("value", total_value)

	# Rarity Label
	var new_label := Label.new()
	new_label.text = "Rarity: " + str(total_value)
	new_label.add_theme_font_size_override("font_size", 16)
	new_label.add_theme_color_override("font_color", Color.WHITE)
	new_label.size_flags_horizontal = Control.SIZE_FILL
	new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	new_label.size = Vector2(130, 30)
	new_label.position = new_button.position + Vector2(0, 115)
	sword_container.add_child(new_label)

	# Rarity Labels
	var mold_label := Label.new()
	mold_label.text = molder_rarity
	mold_label.add_theme_font_size_override("font_size", 14)
	mold_label.add_theme_color_override("font_color", Color.WHITE)
	mold_label.size_flags_horizontal = Control.SIZE_FILL
	mold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	mold_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mold_label.size = Vector2(130, 30)
	mold_label.position = new_button.position + Vector2(135, 0)
	sword_container.add_child(mold_label)

	var polish_label := Label.new()
	polish_label.text = polisher_rarity
	polish_label.add_theme_font_size_override("font_size", 14)
	polish_label.add_theme_color_override("font_color", Color.WHITE)
	polish_label.size_flags_horizontal = Control.SIZE_FILL
	polish_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	polish_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	polish_label.size = Vector2(130, 30)
	polish_label.position = new_button.position + Vector2(135, 20)
	sword_container.add_child(polish_label)

	button.show()

	new_button.pressed.connect(_on_new_button_pressed.bind(container, new_button, new_label, new_panel))

func _on_new_button_pressed(container, new_button, new_label, new_panel):
	print("Sword button pressed!")

func serialize_node_to_dict(panel: Panel) -> Dictionary:
	var data = {}
	for meta_key in panel.get_meta_list():
		data[meta_key] = panel.get_meta(meta_key)
	return data

func _on_ascender_button_pressed() -> void:
	if save_manager.get_value("ascender") == null:
		var button := get_viewport().gui_get_focus_owner()
		if button == null:
			print("No button in focus.")
			return

		var node : Node = occupied_stations[button.get_parent().name]
		var panel : Panel = null
		for child in node.get_children():
			if child is Panel:
				panel = child
				break

		if node and panel:
			var new_banked = save_manager.get_value("banked_items")
			
			new_banked[button.get_parent().name] = null
			save_manager.set_value("banked_items", new_banked)
			
			save_manager.set_value("ascender", serialize_node_to_dict(panel))
			
			node.queue_free()
	else:
		print("ascender full!")

func _on_sell_button_pressed() -> void:
	var button := get_viewport().gui_get_focus_owner()
	if button == null:
		print("No button in focus.")
		return

	var slot_container := button.get_parent()
	if slot_container == null:
		print("Button has no parent (slot container).")
		return

	# Find the first child of the slot that is just a Node (not Control)
	var partner_node : Node = null
	for child in slot_container.get_children():
		if child != button and child.get_class() == "Node":
			partner_node = child
			break

	if partner_node == null:
		print("No partner node found.")
		return

	# Look for a Panel node under the partner
	var panel : Panel = null
	var label : Label = null
	for partner_child in partner_node.get_children():
		if partner_child is Panel:
			panel = partner_child
		elif partner_child is Label:
			label = partner_child

	if panel == null:
		print("No panel found under the partner node.")
		return

	var rarity = label.text
	var sell_price = panel.get_meta("value")
	save_manager.set_value("cash", save_manager.get_value("cash") + sell_price)
	
	var new_banked = save_manager.get_value("banked_items")
	print(slot_container)
	new_banked[slot_container.name] = null
	save_manager.set_value("banked_items", new_banked)
	
	print("Sold a ", rarity, "sword for $", sell_price, "!")

	partner_node.queue_free()
	update_cash_value_label()

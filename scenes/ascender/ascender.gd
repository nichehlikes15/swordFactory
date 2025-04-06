extends Control

var rarities = preload("uid://b4sjsweht8pq1").new()
var save_manager = preload("uid://cyeqeyfigsnwc").new()

var ascender_occupied = false
var current_ascender_value = ""

@export var cash_label : Label

@export var container : Node
@export var sword_holder : Panel
@export var raritie_label : Label

@export var stop_upgrade : Button
@export var bank : Button
@export var upgrade_mold : Button
@export var upgrade_polish : Button

var sword_container : Node = null
var new_panel : Panel = null

func _ready():
	check_ascender()
	update_cash_value_label()

func update_cash_value_label() -> void:
	cash_label.text = "Cash : £%s" % save_manager.get_value("cash")

func check_ascender():
	var ascender_items = save_manager.get_value("ascender")
	if ascender_items and ascender_items is Dictionary:
		print("ASCENDER DATA: ", ascender_items)
		edit_upgrade_buttons(false)
		create_sword(ascender_items)
	else:
		edit_upgrade_buttons()
		print("No ascender item was found. ", save_manager.get_value("ascender"))
		save_manager.set_value("ascender", null)

func create_sword(slot_data: Dictionary) -> void:
	if ascender_occupied == true:
		print("Slot is already occupied.")
		return

	ascender_occupied = true
	print("Creating sword")

	sword_container = Node.new()
	sword_holder.get_parent().add_child(sword_container)

	# Create a new panel for the sword
	new_panel = Panel.new()
	new_panel.size = Vector2(130, 150)
	new_panel.position = sword_holder.global_position

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
	new_button.position = sword_holder.global_position

	# Set metadata
	if slot_data is Dictionary:
		for key in slot_data.keys():
			new_panel.set_meta(key, slot_data[key])
	else:
		print("Slot data is not in expected format")
	
	print("META DATA: ", new_panel.get_meta_list())

	var molder_rarity = new_panel.get_meta("molderRarities")
	var polisher_rarity = new_panel.get_meta("polisherRarities")

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

	new_button.pressed.connect(_on_new_button_pressed.bind(sword_holder, new_button, new_label, new_panel))


func _on_new_button_pressed(sword_holder, new_button, new_label, new_panel):
	print("Sword button pressed!")

func edit_upgrade_buttons(hide = null):
	if hide == true:
		stop_upgrade.visible = true
		bank.visible = false
		upgrade_mold.visible = false
		upgrade_polish.visible = false

	elif hide == false:
		current_ascender_value = ""
		raritie_label.text = ""
		stop_upgrade.visible = false
		bank.visible = true
		upgrade_mold.visible = true
		upgrade_polish.visible = true
	
	elif hide == null:
		raritie_label.text = "Waiting for sword.."
		stop_upgrade.visible = false
		bank.visible = false
		upgrade_mold.visible = false
		upgrade_polish.visible = false
		

func update_label_rarity_info(rarity, value, upgrade : bool):
	if upgrade == true:
		raritie_label.text = "Your sword has been upgraded!\n(" + rarity + ") [RNG: 1/" + str(value) + "]"
	elif upgrade == false:
		raritie_label.text = "Your sword has not been upgraded\n(" + rarity + ") [RNG: 1/" + str(value) + "]"

func node_to_find():
	for child in container.get_children():
		if child.get_children().size() > 0:
			for grandchild in child.get_children():
				if grandchild is Panel:
					return grandchild
	print("No node found!")

func _on_upgradeMold_button_pressed() -> void:
	current_ascender_value = "molder"
	edit_upgrade_buttons(true)
	while current_ascender_value == "molder":
		var rarity = rarities.get_rarity(rarities.molderRarities)
		var sword_node = node_to_find()
		var sword_value = sword_node.get_meta("molderRarities")
		
		var new_rarity = rarities.molderRarities[rarity]["value_multiplier"]

		if new_rarity > rarities.molderRarities[sword_value]["value_multiplier"]:
			print("Upgrading sword to: ", rarity, " From: ", sword_value)
			sword_node.set_meta("molderRarities", rarity)
			update_label_rarity_info(rarity, new_rarity, true)
		else:
			update_label_rarity_info(rarity, new_rarity, false)

		await get_tree().create_timer(1.0).timeout

func _on_upgradePolish_button_pressed() -> void:
	current_ascender_value = "polisher"
	edit_upgrade_buttons(true)
	while current_ascender_value == "polisher":
		var rarity = rarities.get_rarity(rarities.polisherRarities)
		var sword_node = node_to_find()
		var sword_value = sword_node.get_meta("polisherRarities")
		
		var new_rarity = rarities.polisherRarities[rarity]["value_multiplier"]

		if new_rarity > rarities.polisherRarities[sword_value]["value_multiplier"]:
			print("Upgrading sword to: ", rarity, " From: ", sword_value)
			sword_node.set_meta("polisherRarities", rarity)
			update_label_rarity_info(rarity, new_rarity, true)
		else:
			update_label_rarity_info(rarity, new_rarity, false)

		await get_tree().create_timer(1.0).timeout

func _on_stop_upgrade_button_pressed() -> void:
	edit_upgrade_buttons(false)

func check_banked_items():
	var banked_items = save_manager.get_value("banked_items")
	if banked_items and banked_items is Dictionary:
		for slot in banked_items.keys():
			if banked_items[slot] == null:
				print("returned banked slot")
				return slot
		print("- No banked items found.")
	else:
		print("- No banked items found.")

func serialize_node_to_dict(node: Node) -> Dictionary:
	var data = {}
	for meta_key in node.get_meta_list():
		data[meta_key] = node.get_meta(meta_key)
	return data

func _on_bank_button_pressed() -> void:
	var slot = check_banked_items()
	if slot:
		edit_upgrade_buttons()
		print(slot)
		var new_banked = save_manager.get_value("banked_items")
		new_banked[slot] = serialize_node_to_dict(new_panel)
		save_manager.set_value("banked_items", new_banked)
		
		save_manager.set_value("ascender", null)
		
		sword_container.queue_free()
	else:
		print(slot)

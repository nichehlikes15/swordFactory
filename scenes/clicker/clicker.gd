class_name Clicker
extends Control

var is_sword_moving : bool = false  

@export var cash_label : Label
@export var dev_button : Button
@export var sword_container : Node

@export var Spawner : Panel
@export var Molder : Panel
@export var Polisher : Panel
@export var Classifier : Panel
@export var Upgrader : Panel
@export var Enchanter : Panel
@export var Appraiser : Panel
@export var SellArea : Panel

@export var SpawnerContainer : Node
@export var MolderContainer : Node
@export var PolisherContainer : Node
@export var ClassifierContainer : Node
@export var UpgraderContainer : Node
@export var EnchanterContainer : Node
@export var AppraiserContainer : Node
@export var SellAreaContainer : Node

@export var sell_button : Button

const rarities = preload("uid://b4sjsweht8pq1")
var rarities_instance = rarities.new()

var save_manager = preload("uid://cyeqeyfigsnwc").new()

var stations := {}
var occupied_stations := {}

var molder_locked := true
var polisher_locked := true
var classifier_locked := true
var upgrader_locked := true
var enchanter_locked := true
var appraiser_locked := true

func _ready() -> void:
	var unlocked_stations = save_manager.get_value("unlocked_stations")
	
	if unlocked_stations:
		molder_locked = not unlocked_stations.get("Molder", false)
		polisher_locked = not unlocked_stations.get("Polisher", false)
		classifier_locked = not unlocked_stations.get("Classifier", false)
		upgrader_locked = not unlocked_stations.get("Upgrader", false)
		enchanter_locked = not unlocked_stations.get("Enchanter", false)
		appraiser_locked = not unlocked_stations.get("Appraiser", false)

	# 🔒 Hide TextureRect child for each unlocked station
	if not molder_locked:
		var texture = Molder.get_child(0)
		if texture is TextureRect:
			texture.hide()

	if not polisher_locked:
		var texture = Polisher.get_child(0)
		if texture is TextureRect:
			texture.hide()

	if not classifier_locked:
		var texture = Classifier.get_child(0)
		if texture is TextureRect:
			texture.hide()

	if not upgrader_locked:
		var texture = Upgrader.get_child(0)
		if texture is TextureRect:
			texture.hide()

	if not enchanter_locked:
		var texture = Enchanter.get_child(0)
		if texture is TextureRect:
			texture.hide()

	if not appraiser_locked:
		var texture = Appraiser.get_child(0)
		if texture is TextureRect:
			texture.hide()
			
	var save_data = save_manager.load_game()
	if save_data:
		load_saved_data(save_data)
		
	stations = {
		"Spawner": Spawner,
		"Molder": Molder,
		"Polisher": Polisher,
		"Classifier": Classifier,
		"Upgrader": Upgrader,
		"Enchanter": Enchanter,
		"Appraiser": Appraiser,
		"SellArea": SellArea
	}
	
	occupied_stations = {
		"Spawner": false,
		"Molder": false,
		"Polisher": false,
		"Classifier": false,
		"Upgrader": false,
		"Enchanter": false,
		"Appraiser": false,
		"SellArea": false
	}
	update_cash_value_label()


func load_saved_data(save_data: Dictionary):
	if "occupied_stations" in save_data:
		occupied_stations = save_data["occupied_stations"]

	update_cash_value_label()
	print("Game loaded!")



func update_cash_value_label() -> void:
	cash_label.text = "Cash : £%s" % save_manager.get_value("cash")

func create_cash(amount: int = 1) -> void:
	save_manager.set_value("cash", save_manager.get_value("cash") + amount)
	update_cash_value_label()

func _on_dev_button_pressed() -> void:
	DirAccess.open("user://").file_exists("data.json") and DirAccess.open("user://").remove("data.json")
	#rarities_instance.get_rarity_loop()
	#create_cash(10000000)

func create_sword() -> void:
	if is_sword_moving or occupied_stations["Spawner"]:
		return

	is_sword_moving = true  
	occupied_stations["Spawner"] = true  

	var container := Node.new()
	SpawnerContainer.add_child(container)

	# Background Panel
	var new_panel := Panel.new()
	new_panel.size = Vector2(130, 150)
	new_panel.position = Spawner.global_position
	
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.2, 0.2, 0.2, 0.5)  
	new_panel.add_theme_stylebox_override("panel", stylebox)  
	container.add_child(new_panel)

	# Sword Button
	var new_button := TextureButton.new()
	container.add_child(new_button)
	new_button.texture_normal = load("res://images/Regular_sword.webp")
	new_button.ignore_texture_size = true
	new_button.stretch_mode = TextureButton.STRETCH_SCALE
	new_button.size = Vector2(120, 120)  
	new_button.position = Spawner.global_position

	# Rarity Label
	var new_label := Label.new()
	new_label.text = "£10"
	new_label.add_theme_font_size_override("font_size", 16)
	new_label.add_theme_color_override("font_color", Color.WHITE)
	new_label.size_flags_horizontal = Control.SIZE_FILL  
	new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER  
	new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER  
	new_label.size = Vector2(130, 30)  
	new_label.position = new_button.position + Vector2(0, 115)  
	container.add_child(new_label)
	
	var sword_cost: int = 10
	new_panel.set_meta("value", 10)

	# Connect button click
	new_button.pressed.connect(_on_new_button_pressed.bind(container, new_button, new_label, new_panel))

	is_sword_moving = false

func _on_new_button_pressed(node: Node, button: TextureButton, label: Label, panel: Panel) -> void:
	if is_sword_moving:
		print("moving sword")
		return 

	is_sword_moving = true  

	var current_station = get_sword_station(button.position)
	print(current_station)

	var station_order = ["Molder", "Polisher", "Classifier", "Upgrader", "Enchanter", "Appraiser", "SellArea"]
	var station_locks = {
		"Molder": molder_locked,
		"Polisher": polisher_locked,
		"Classifier": classifier_locked,
		"Upgrader": upgrader_locked,
		"Enchanter": enchanter_locked,
		"Appraiser": appraiser_locked,
		"SellArea": false
	}

	var start_index = station_order.find(current_station)
	if start_index == -1:
		start_index = -1 

	var next_station := ""
	for i in range(start_index + 1, station_order.size()):
		var station = station_order[i]
		if not station_locks[station] and not occupied_stations[station]:
			next_station = station
			break

	if next_station == "":
		print("No available station found.")
		is_sword_moving = false
		return

	var current_station_container : Node = get_station_container(current_station)
	var raritity_label : Label = null
	
	if current_station_container:
		for child in current_station_container.get_children():
			if child is Label and child.name == "Raritiy":
				raritity_label = child
				break
	
	if raritity_label:
		raritity_label.text = ""

	var new_position = stations[next_station].global_position
	var tween := create_tween()
	tween.tween_property(button, "position", new_position, 0.5)
	tween.parallel().tween_property(label, "position", new_position + Vector2(0, 115), 0.5)  
	tween.parallel().tween_property(panel, "position", new_position, 0.5)  
	tween.finished.connect(func(): _on_sword_moved(node, button, label, panel, current_station, next_station))


func get_station_container(station_name: String) -> Node:
	if station_name == "Molder":
		return MolderContainer
	elif station_name == "Polisher":
		return PolisherContainer
	elif station_name == "Classifier":
		return ClassifierContainer
	elif station_name == "Upgrader":
		return UpgraderContainer
	elif station_name == "Enchanter":
		return EnchanterContainer
	elif station_name == "Appraiser":
		return AppraiserContainer
	elif station_name == "SellArea":
		return SellAreaContainer
	return null
	

func _on_sword_moved(node: Node, button: TextureButton, label: Label, panel: Panel, old_station: String, new_station: String) -> void:
	if old_station != "":
		occupied_stations[old_station] = false
	var raritie = ""

	if new_station == "Molder":
		occupied_stations[new_station] = true 
		
		raritie = rarities_instance.get_rarity(rarities_instance.molderRarities)
		print("This sword was worth: ", panel.get_meta("value"))
		var new_value = panel.get_meta("value") * rarities_instance.molderRarities[raritie]["value_multiplier"]
		panel.set_meta("value", new_value)
		label.text = "£" + str(panel.get_meta("value"))
		panel.set_meta("molderRarities", raritie)
		print("This sword is now worth: ", panel.get_meta("value"))
		
		var raritity_label : Label = null
		for child in MolderContainer.get_children():
			if child is Label and child.name == "Raritiy":
				raritity_label = child
				break
		if raritity_label:
			raritity_label.text = raritie + " [RNG: 1/" + str(rarities_instance.molderRarities[raritie]["value_multiplier"]) + "]"
		else:
			print("no find")
			
		node.get_parent().remove_child(node)
		MolderContainer.add_child(node)
		
	elif new_station == "Polisher":
		occupied_stations[new_station] = true
		
		raritie = rarities_instance.get_rarity(rarities_instance.polisherRarities)
		print("This sword was worth: ", panel.get_meta("value"))
		var new_value = panel.get_meta("value") * rarities_instance.polisherRarities[raritie]["value_multiplier"]
		panel.set_meta("value", new_value)
		label.text = "£" + str(panel.get_meta("value"))
		panel.set_meta("polisherRarities", raritie)
		print("This sword is now worth: ", panel.get_meta("value"))
		
		var raritity_label : Label = null
		for child in PolisherContainer.get_children():
			if child is Label and child.name == "Raritiy":
				raritity_label = child
				break
		if raritity_label:
			raritity_label.text = raritie + " [RNG: 1/" + str(rarities_instance.polisherRarities[raritie]["value_multiplier"]) + "]"
		else:
			print("no find")
		
		node.get_parent().remove_child(node)
		PolisherContainer.add_child(node)
		
	elif new_station == "Classifier":
		occupied_stations[new_station] = true
		node.get_parent().remove_child(node)
		ClassifierContainer.add_child(node)
		
	elif new_station == "Upgrader":
		occupied_stations[new_station] = true
		node.get_parent().remove_child(node)
		UpgraderContainer.add_child(node)
		
	elif new_station == "Enchanter":
		occupied_stations[new_station] = true
		node.get_parent().remove_child(node)
		EnchanterContainer.add_child(node)
		
	elif new_station == "Appraiser":
		occupied_stations[new_station] = true
		node.get_parent().remove_child(node)
		AppraiserContainer.add_child(node)
		
	elif new_station == "SellArea":
		occupied_stations[new_station] = true
		node.get_parent().remove_child(node)
		SellAreaContainer.add_child(node)
		
	else:
		push_warning("No correct station found!")

	is_sword_moving = false  

func get_sword_station(position: Vector2) -> String:
	print("Checking sword for position:", position)

	for name in stations.keys():
		var station = stations[name]
		
		if station == null:
			push_warning("Error: Station", name, "is NULL! Check your scene setup.")
			continue  # Skip this iteration if station is null

		print("Comparing with station:", name, "at position", station.global_position)

		if station.global_position.distance_to(position) < 10:
			print("Matched station:", name)
			return name
		else:
			print("1", name)

	print("No station matched!")
	return ""

func get_next_available_station(current_station: String) -> String:
	print("Checking next station for:", current_station)
	if current_station == "Spawner" and not occupied_stations["Molder"]:
		print("Next station: Molder")
		return "Molder"
	if current_station == "Molder" and not occupied_stations["Polisher"]:
		print("Next station: Polisher")
		return "Polisher"
	if current_station == "Polisher" and not occupied_stations["Classifier"]:
		print("Next station: Classifier")
		return "Classifier"
	if current_station == "Classifier" and not occupied_stations["Upgrader"]:
		print("Next station: Upgrader")
		return "Upgrader"
	if current_station == "Upgrader" and not occupied_stations["Enchanter"]:
		print("Next station: Enchanter")
		return "Enchanter"
	if current_station == "Enchanter" and not occupied_stations["Appraiser"]:
		print("Next station: Appraiser")
		return "Appraiser"
	if current_station == "Appraiser" and not occupied_stations["SellArea"]:
		print("Next station: SellArea")
		return "SellArea"
	
	push_error("No available station found!")
	return ""

# Function connected to the sell button press
func _on_sell_button_pressed() -> void:
	var swords = []
	for child in SellAreaContainer.get_children():
		var sword_data = {"node": child, "children": child.get_children()}
		swords.append(sword_data)

# Check if there are swords to sell
	if swords.size() > 0:
		for sword in swords:
			var node = sword["node"]
			var children = sword["children"]

			var button = null
			var label = null
			var panel = null

		# Find the button, label, and panel inside the sword
			for child in children:
				if child is TextureButton:
					button = child
				elif child is Label:
					label = child
				elif child is Panel:
					panel = child

		# Sell the sword if all components exist
			if button and label and panel:
				var rarity = label.text
				var sell_price = panel.get_meta("value")
				button.queue_free()  # Remove sword button
				label.queue_free()   # Remove label
				panel.queue_free()   # Remove background panel
				node.queue_free()    # Remove the sword container itself
				
				occupied_stations["SellArea"] = false  # Mark station as free
				create_cash(sell_price)  # Add the price to the cash
				print("Sold a ", rarity, " sword for $", sell_price, "!")

	else:
		print("No sword to sell!")

func _on_create_sword_button_pressed() -> void:
	create_sword()
	
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

func serialize_node_to_dict(panel: Panel) -> Dictionary:
	var data = {}
	for meta_key in panel.get_meta_list():
		data[meta_key] = panel.get_meta(meta_key)
	return data

func _on_bank_button_pressed() -> void:
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

	var slot = check_banked_items()
	if slot:
		print(slot)
		var new_banked = save_manager.get_value("banked_items")
		var data = serialize_node_to_dict(panel)
		if data:
			new_banked[slot] = data
		else:
			new_banked[slot] = null
		save_manager.set_value("banked_items", new_banked)
		
		save_manager.set_value("ascender", null)
		
		partner_node.queue_free()
	else:
		print(slot)

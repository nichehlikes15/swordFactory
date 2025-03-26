class_name Clicker
extends Control

var cash : int = 0
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

var rarities := {
	"Common": {"chance": 50, "price": 50},
	"Rare": {"chance": 30, "price": 100},
	"Gold": {"chance": 20, "price": 170},
	"Epic": {"chance": 15, "price": 250},
	"Diamond": {"chance": 5, "price": 500}
}

var stations := {}
var occupied_stations := {}

func _ready() -> void:
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

func update_cash_value_label() -> void:
	cash_label.text = "Cash : %s" % cash

func create_cash(amount: int = 1) -> void:
	cash += amount
	update_cash_value_label()

func _on_dev_button_pressed() -> void:
	create_cash(10000000)

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
	new_label.text = "Unknown"
	new_label.add_theme_font_size_override("font_size", 16)
	new_label.add_theme_color_override("font_color", Color.WHITE)
	new_label.size_flags_horizontal = Control.SIZE_FILL  
	new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER  
	new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER  
	new_label.size = Vector2(130, 30)  
	new_label.position = new_button.position + Vector2(0, 115)  
	container.add_child(new_label)

	# Connect button click
	new_button.pressed.connect(_on_new_button_pressed.bind(container, new_button, new_label, new_panel))

	is_sword_moving = false

func _on_new_button_pressed(node: Node, button: TextureButton, label: Label, panel: Panel) -> void:
	if is_sword_moving:
		print("moving sword")
		return 

	is_sword_moving = true  

	var current_station = get_sword_station(button.position)
	var next_station = get_next_available_station(current_station)

	if next_station == "":
		print("false thing")
		is_sword_moving = false
		return

	var new_position = stations[next_station].global_position
	var tween := create_tween()
	tween.tween_property(button, "position", new_position, 0.5)
	tween.parallel().tween_property(label, "position", new_position + Vector2(0, 115), 0.5)  
	tween.parallel().tween_property(panel, "position", new_position, 0.5)  
	tween.finished.connect(func(): _on_sword_moved(node, button, label, panel, current_station, next_station))

func _on_sword_moved(node: Node, button: TextureButton, label: Label, panel: Panel, old_station: String, new_station: String) -> void:
	if old_station != "":
		occupied_stations[old_station] = false

	if new_station == "Molder":
		occupied_stations[new_station] = true
		label.text = get_random_rarity()
		node.get_parent().remove_child(node)
		MolderContainer.add_child(node)
		
	elif new_station == "Polisher":
		occupied_stations[new_station] = true
		node.get_parent().remove_child(node)
		SellAreaContainer.add_child(node)
		
	elif new_station == "Classifier":
		occupied_stations[new_station] = true
		node.get_parent().remove_child(node)
		SellAreaContainer.add_child(node)
		
	elif new_station == "Upgrader":
		occupied_stations[new_station] = true
		node.get_parent().remove_child(node)
		SellAreaContainer.add_child(node)
		
	elif new_station == "Enchanter":
		occupied_stations[new_station] = true
		node.get_parent().remove_child(node)
		SellAreaContainer.add_child(node)
		
	elif new_station == "Appraiser":
		occupied_stations[new_station] = true
		node.get_parent().remove_child(node)
		SellAreaContainer.add_child(node)
		
	elif new_station == "SellArea":
		occupied_stations[new_station] = true
		node.get_parent().remove_child(node)
		SellAreaContainer.add_child(node)
		
	else:
		print("t")

	is_sword_moving = false  

func get_random_rarity() -> String:
	var roll = randi() % 100  
	var cumulative = 0
	for rarity in rarities.keys():
		cumulative += rarities[rarity]["chance"]
		if roll < cumulative:
			return rarity
	return "Common"  

func get_sword_station(position: Vector2) -> String:
	print("Checking sword for position:", position)

	for name in stations.keys():
		var station = stations[name]
		
		if station == null:
			print("Error: Station", name, "is NULL! Check your scene setup.")
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
	
	print("No available station found!")
	return ""

# Function to sell the sword when the button is pressed
func sell_sword(button: TextureButton, label: Label, panel: Panel) -> void:
	var rarity = label.text
	var sell_price = rarities[rarity]["price"]
	button.queue_free()  # Remove sword button
	label.queue_free()   # Remove label
	panel.queue_free()   # Remove background panel
	occupied_stations["SellArea"] = false  # Mark station as free
	create_cash(sell_price)  # Add the price to the cash
	print("Sold a ", rarity, "sword for $", sell_price, "!")

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
				var sell_price = rarities[rarity]["price"]
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

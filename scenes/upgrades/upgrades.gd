extends Control

var save_manager = preload("uid://cyeqeyfigsnwc").new()

@export var cash_label : Label

@export var MolderContainer : Node
@export var PolisherContainer : Node
@export var ClassifierContainer : Node
@export var UpgraderContainer : Node
@export var EnchanterContainer : Node
@export var AppraiserContainer : Node

func _ready() -> void:
	var unlocked_stations = save_manager.get_value("unlocked_stations")
	
	var molder_locked = unlocked_stations.get("Molder")
	var polisher_locked = unlocked_stations.get("Polisher",)
	var classifier_locked = unlocked_stations.get("Classifier")
	var upgrader_locked = unlocked_stations.get("Upgrader")
	var enchanter_locked = unlocked_stations.get("Enchanter")
	var appraiser_locked = unlocked_stations.get("Appraiser")

	if molder_locked:
		var button : Button = null
		for child in MolderContainer.get_children():
			if child is Button:
				button = child
				break
		if button:
			button.visible = false

	if polisher_locked:
		var button : Button = null
		for child in PolisherContainer.get_children():
			if child is Button:
				button = child
				break
		if button:
			button.visible = false

	if classifier_locked:
		var button : Button = null
		for child in ClassifierContainer.get_children():
			if child is Button:
				button = child
				break
		if button:
			button.visible = false

	if upgrader_locked:
		var button : Button = null
		for child in UpgraderContainer.get_children():
			if child is Button:
				button = child
				break
		if button:
			button.visible = false

	if enchanter_locked:
		var button : Button = null
		for child in EnchanterContainer.get_children():
			if child is Button:
				button = child
				break
		if button:
			button.visible = false

	if appraiser_locked:
		var button : Button = null
		for child in AppraiserContainer.get_children():
			if child is Button:
				button = child
				break
		if button:
			button.visible = false
			
	update_cash_value_label()

func update_cash_value_label() -> void:
	cash_label.text = "Cash : £%s" % save_manager.get_value("cash")

func create_cash(amount: int = 1) -> void:
	save_manager.set_value("cash", save_manager.get_value("cash") + amount)
	update_cash_value_label()

func _on_unlock_button_pressed() -> void:
	if save_manager.get_value("cash") >= 50:
		var button = get_viewport().gui_get_focus_owner()
		create_cash(button.get_meta("price"))
		
		print(save_manager.get_value("unlocked_stations"))
		var new_unlock = save_manager.get_value("unlocked_stations")
		new_unlock[button.get_parent().name] = true
		save_manager.set_value("unlocked_stations", new_unlock)
		print(save_manager.get_value("unlocked_stations"))
		
		button.visible = false
	else:
		print("POOR!")

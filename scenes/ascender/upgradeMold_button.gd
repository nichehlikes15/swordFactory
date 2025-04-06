extends Control

static var current_ascender_value = ""

const rarities = preload("uid://b4sjsweht8pq1")
var rarities_instance = rarities.new()

@export var SwordHolder: Panel

func node_to_find():
	var new_node = $Ascender.get_child($Ascender.get_child_count() - 1)
	print("Last child:", new_node)

func _onn_upgradeMold_button_pressed() -> void:
	current_ascender_value = "molder"
	while current_ascender_value == "molder":
		
		var rarity = rarities_instance.get_rarity(rarities_instance.molderRarities)
		var sword_node = node_to_find()
		
		var sword_value = sword_node.get_meta("molderRarities")
		print("Sword Value:", sword_value)

		# Compare with rarity multiplier
		if rarities_instance.molderRarities[rarity]["value_multiplier"] > rarities_instance.molderRarities[sword_value]["value_multiplier"]:
			print("Upgrading sword to: ", rarity, " From: ", sword_value)

		await get_tree().create_timer(1.0).timeout

func _onn_upgradePolish_button_pressed() -> void:
	current_ascender_value = "polisher"
	while current_ascender_value == "polisher":
		# Get the rarity
		var rarity = rarities_instance.get_rarity(rarities_instance.polisherRarities)
		
		# Get the sword (assuming it's the first child of SwordHolder)
		var sword_node = []
		print(SwordHolder)
		for child in SwordHolder.get_children():
			if child is Node:
				var sword_data = {"node": child}
				sword_node.append(sword_data)
		
		if sword_node.size() == 1:
			var sword_value = sword_node.get_meta("value")  # Get the stored value
			print("Sword Value:", sword_value)

			# Compare with rarity multiplier
			if rarities_instance.polisherRarities[rarity]["value_multiplier"] > sword_value:
				print("Upgrading sword...")
		else:
			print("Error No Sword or To Many Swords Found In The Ascender! ", sword_node.size())
			current_ascender_value = ""

		await get_tree().create_timer(1.0).timeout

extends Node

static var molderRarities = {
	"Common" : { "weight": 50000000, "value_multiplier": 1.25 },
	"Bronze" : { "weight": 10000000, "value_multiplier": 2.5 },
	"Silver" : { "weight": 1000000, "value_multiplier": 6 },
	"Gold" : { "weight": 100000, "value_multiplier": 15 },
	"Sapphire" : { "weight": 10000, "value_multiplier": 35 },
	"Emerald" : { "weight": 1000, "value_multiplier": 60 },
	"Ruby" : { "weight": 100, "value_multiplier": 100 },
	"Amethyst" : { "weight": 10, "value_multiplier": 145 },
	"Diamond" : { "weight": 1, "value_multiplier": 190 }
}

static var polisherRarities = {
	"Broken" : { "weight": 387420489, "value_multiplier": 1.15 },
	"Rough" : { "weight": 129140163, "value_multiplier": 1.25 },
	"Bad" : { "weight": 43046721, "value_multiplier": 1.5 },
	"Okay" : { "weight": 14348907, "value_multiplier": 2 },
	"Fine" : { "weight": 4782969, "value_multiplier": 3 },
	"Good" : { "weight": 531441, "value_multiplier": 4.5 },
	"Awesome" : { "weight": 177147, "value_multiplier": 9 },
	"Excellent" : { "weight": 59049, "value_multiplier": 12.5 },
	"Perfect" : { "weight": 19683, "value_multiplier": 18 },
	"Best" : { "weight": 6561, "value_multiplier": 27.5 },
	"Incredible" : { "weight": 2187, "value_multiplier": 40 },
	"Tremendous" : { "weight": 729, "value_multiplier": 55 },
	"Fantastic" : { "weight": 243, "value_multiplier": 70 },
	"Absurd" : { "weight": 81, "value_multiplier": 90 },
	"Exquisite" : { "weight": 27, "value_multiplier": 125 },
	"Remarkable" : { "weight": 9, "value_multiplier": 145 },
	"Extravagant" : { "weight": 3, "value_multiplier": 175 },
	"Phenomenal" : { "weight": 1, "value_multiplier": 210 }
}

var rng = RandomNumberGenerator.new()

func get_rarity(rarity_dict : Dictionary):
	rng.randomize()
	
	var weighted_sum = 0
	
	for rarity in rarity_dict:
		weighted_sum += rarity_dict[rarity].weight
	
	var item = rng.randi_range(0, weighted_sum)
	
	for rarity in rarity_dict:
		if item <= rarity_dict[rarity].weight:
			print("RAREITY: ", rarity)
			return rarity
		item -= rarity_dict[rarity].weight

func get_rarity_loop():
	var rarity_count = {}

	for rarity in molderRarities.keys():
		rarity_count[rarity] = 0
	
	for x in range(1000000):
		rng.randomize()
		
		var weighted_sum = 0
		
		for rarity in molderRarities.keys():
			weighted_sum += molderRarities[rarity].weight
		
		var item = rng.randi_range(0, weighted_sum)
		
		for rarity in molderRarities.keys():
			if item <= molderRarities[rarity].weight:
				rarity_count[rarity] += 1
				break 
			item -= molderRarities[rarity].weight
	
	print("\nRarity Count Table:")
	print("──────────────────────────")
	for rarity in molderRarities.keys():
		print(rarity + ": " + str(rarity_count[rarity]))
	print("──────────────────────────")

	return "Common"

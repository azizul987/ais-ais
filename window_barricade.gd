extends Barricade
class_name WindowBarricade

## Implementasi spesifik untuk Jendela Barikade (US-03)
## Mewarisi seluruh logika ketahanan dari Barricade.gd

func _init() -> void:
	barricade_name = "Jendela"
	if broken_texture == null:
		broken_texture = preload("res://PostApocalypse_AssetPack_v1.1.2/Objects/Windows/Window_1_broken_wood.png")
	if repaired_texture == null:
		repaired_texture = preload("res://PostApocalypse_AssetPack_v1.1.2/Objects/Windows/Window_6_Boarded-up_wood.png")

extends StaticBody2D
class_name WindowBarricade

## Kriteria Selesai (DoD) US-03:
## 1. Jendela memiliki variabel Barricade HP (standar 50, maksimum 100).
## 2. Pemain menekan tombol interaksi E di dekat jendela dengan membawa kayu: 1 kayu terpakai dan Barricade HP bertambah 50.
## 3. Bar ketahanan muncul saat pemain berada di dekat jendela.

@export var max_hp: int = 100
@export var barricade_hp: int = 50:
	set(value):
		barricade_hp = clamp(value, 0, max_hp)
		_update_display()

@export var broken_texture: Texture2D = preload("res://PostApocalypse_AssetPack_v1.1.2/Objects/Windows/Window_1_broken_wood.png")
@export var repaired_texture: Texture2D = preload("res://PostApocalypse_AssetPack_v1.1.2/Objects/Windows/Window_6_Boarded-up_wood.png")

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var prompt_label: Label = $UI/PromptLabel

var player_in_range: CharacterBody2D = null

func _ready() -> void:
	# Kriteria 3: Bar ketahanan & info HANYA muncul saat pemain di dekat jendela
	$UI.visible = false
	
	health_bar.min_value = 0
	health_bar.max_value = max_hp
	health_bar.value = barricade_hp
	
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	
	_update_display()

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range == null:
		return
		
	# Deteksi tombol interaksi 'E'
	var is_interact: bool = false
	if InputMap.has_action("interact") and Input.is_action_just_pressed("interact"):
		is_interact = true
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E:
		is_interact = true
		
	if is_interact:
		repair_barricade()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and "wood" in body:
		player_in_range = body
		$UI.visible = true
		_update_display()

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
		$UI.visible = false

func repair_barricade() -> void:
	if player_in_range == null:
		return
		
	# Cek jika barikade sudah full
	if barricade_hp >= max_hp:
		if is_instance_valid(prompt_label):
			prompt_label.text = "Barikade Penuh (100 HP)"
		return
		
	# Kriteria 2: Cek apakah pemain membawa kayu
	if player_in_range.wood > 0:
		player_in_range.wood -= 1
		barricade_hp += 50
		print("[Barikade] Jendela diperbaiki! HP sekarang: %d, Sisa kayu player: %d" % [barricade_hp, player_in_range.wood])
	else:
		if is_instance_valid(prompt_label):
			prompt_label.text = "Butuh Kayu!"

func _update_display() -> void:
	if is_instance_valid(health_bar):
		health_bar.value = barricade_hp
		
	# Ganti sprite sesuai kondisi (50 HP = retak/rusak, 100 HP = dipaku kayu)
	if is_instance_valid(sprite_2d):
		if barricade_hp >= max_hp and repaired_texture:
			sprite_2d.texture = repaired_texture
		elif broken_texture:
			sprite_2d.texture = broken_texture

	# Update teks interaksi
	if is_instance_valid(prompt_label) and player_in_range != null:
		if barricade_hp >= max_hp:
			prompt_label.text = "Barikade Maksimal (%d/%d)" % [barricade_hp, max_hp]
		elif player_in_range.wood > 0:
			prompt_label.text = "[E] Perbaiki (+50 HP) [Kayu: %d]" % player_in_range.wood
		else:
			prompt_label.text = "[E] Butuh Kayu! [Kayu: 0]"

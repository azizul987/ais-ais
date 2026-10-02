extends StaticBody2D
class_name Barricade

## Sistem Ketahanan Pertahanan Markas (Universal: Jendela, Pagar, Tembok)
## Memenuhi DoD US-03:
## 1. Memiliki variabel Barricade HP (standar 50, maksimum 100).
## 2. Pemain menekan E di dekat objek dengan membawa kayu: 1 kayu terpakai dan Barricade HP bertambah 50.
## 3. Bar ketahanan muncul saat pemain berada di dekat objek.
## 4. Mendukung fungsi take_damage() untuk serangan musuh/zombie nantinya.

@export var barricade_name: String = "Barikade"
@export var max_hp: int = 100
@export var barricade_hp: int = 50:
	set(value):
		barricade_hp = clamp(value, 0, max_hp)
		_update_display()

@export var wood_cost: int = 1
@export var repair_amount: int = 50

@export var broken_texture: Texture2D
@export var repaired_texture: Texture2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var prompt_label: Label = $UI/PromptLabel

var player_in_range: CharacterBody2D = null

func _ready() -> void:
	# Bar ketahanan & petunjuk hanya muncul saat pemain mendekat
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
		
	if barricade_hp >= max_hp:
		if is_instance_valid(prompt_label):
			prompt_label.text = "%s Sudah Maksimal (%d HP)" % [barricade_name, max_hp]
		return
		
	# Cek apakah pemain membawa material kayu
	if player_in_range.wood >= wood_cost:
		player_in_range.wood -= wood_cost
		barricade_hp += repair_amount
		if collision_shape:
			collision_shape.set_deferred("disabled", false)
		print("[%s] Berhasil diperbaiki! HP sekarang: %d/%d, Sisa kayu: %d" % [barricade_name, barricade_hp, max_hp, player_in_range.wood])
	else:
		if is_instance_valid(prompt_label):
			prompt_label.text = "Butuh %d Kayu!" % wood_cost

func take_damage(amount: int) -> void:
	barricade_hp -= amount
	print("[%s] Terkena serangan! HP: %d/%d" % [barricade_name, barricade_hp, max_hp])
	if barricade_hp <= 0:
		on_destroyed()

func on_destroyed() -> void:
	print("[%s] JEBOL / RUSAK TOTAL!" % barricade_name)
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	_update_display()

func _update_display() -> void:
	if is_instance_valid(health_bar):
		health_bar.value = barricade_hp
		
	# Ganti visual sprite sesuai kondisi HP
	if is_instance_valid(sprite_2d):
		if barricade_hp >= max_hp and repaired_texture:
			sprite_2d.texture = repaired_texture
		elif broken_texture:
			sprite_2d.texture = broken_texture

	# Update teks interaksi
	if is_instance_valid(prompt_label) and player_in_range != null:
		if barricade_hp >= max_hp:
			prompt_label.text = "%s Penuh (%d/%d)" % [barricade_name, barricade_hp, max_hp]
		elif player_in_range.wood >= wood_cost:
			prompt_label.text = "[E] Perbaiki %s (+%d HP) [Kayu: %d]" % [barricade_name, repair_amount, player_in_range.wood]
		else:
			prompt_label.text = "[E] Butuh %d Kayu! [Kayu: 0]" % wood_cost

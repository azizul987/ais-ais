extends Area2D


@export var max_hp: int = 100
@export var hp: int = 50

@onready var bangunan: TileMapLayer = $".."
# Fleksibel: mendeteksi otomatis apakah namanya "Health_Of_shelter" atau "ProgressBar"
@onready var health_of_shelter: ProgressBar = $"../Health_Of_shelter" if has_node("../Health_Of_shelter") else $"../ProgressBar"

var player: CharacterBody2D = null

func _ready() -> void:
	# Hubungkan deteksi player masuk / keluar area
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Setting awal bar ketahanan
	if health_of_shelter:
		health_of_shelter.max_value = max_hp
		health_of_shelter.value = hp
		health_of_shelter.visible = false # Sembunyi saat awal

func _process(delta: float) -> void:
	if player != null and Input.is_action_just_pressed("interact"):
		repair()

func _unhandled_input(event: InputEvent) -> void:
	# Cadangan jika action "interact" belum di-load di InputMap
	if player != null and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E:
		repair()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player = body
		if health_of_shelter:
			health_of_shelter.visible = true # Bar muncul saat player dekat
		print("Pemain mendekati shelter. HP Shelter: ", hp)

func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		if health_of_shelter:
			health_of_shelter.visible = false # Bar sembunyi saat player menjauh
		print("Pemain menjauh dari shelter.")

# Fungsi perbaiki shelter pakai kayu (DoD US-03)
func repair() -> void:
	if hp >= max_hp:
		print("Shelter sudah maksimal (%d HP)!" % max_hp)
		return
		
	# Cek apakah player membawa material kayu
	if "wood" in player and player.wood > 0:
		player.wood -= 1
		hp = clamp(hp + 50, 0, max_hp)
		if health_of_shelter:
			health_of_shelter.value = hp
		print("Shelter diperbaiki! HP: %d/%d | Sisa kayu player: %d" % [hp, max_hp, player.wood])
	else:
		print("Kayu tidak cukup! Butuh 1 kayu untuk memperbaiki.")

# Fungsi hitung apakah hancur atau tidak
func take_damage(amount: int) -> void:
	hp = clamp(hp - amount, 0, max_hp)
	if health_of_shelter:
		health_of_shelter.value = hp
		
	if hp <= 0:
		print("PERINGATAN: SHELTER HANCUR! (HP = 0)")
	else:
		print("Shelter terkena damage, sisa HP: ", hp)

func is_destroyed() -> bool:
	return hp <= 0

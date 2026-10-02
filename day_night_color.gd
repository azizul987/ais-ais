extends CanvasModulate

const DURATION_DAY: float = 5   # 2 Menit
const DURATION_DUSK: float = 5    # 30 Detik
const DURATION_NIGHT: float = 90.0   # 1.5 Menit
@onready var senter: PointLight2D = $"../player/Senter"

const COLOR_DAY: Color = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_DUSK: Color = Color(0.85, 0.55, 0.35, 1.0)
const COLOR_NIGHT: Color = Color(0.22, 0.306, 0.29, 0.957)

enum Phase { DAY, DUSK, NIGHT }
var current_phase: Phase = Phase.DAY

var time_elapsed: float = 0.0
var current_day: int = 1

@onready var time_label: Label = $"../CanvasLayer/TimeLabel"
@onready var siren_player: AudioStreamPlayer = $"../SirenPlayer"

func _ready() -> void:
	color = COLOR_DAY
	update_hud()

func _process(delta: float) -> void:
	time_elapsed += delta
	match current_phase:
		Phase.DAY:
			if time_elapsed >= DURATION_DAY:
				transition_to_phase(Phase.DUSK)
				senter.energy=0.2
		Phase.DUSK:
			if time_elapsed >= DURATION_DUSK:
				transition_to_phase(Phase.NIGHT)
				senter.energy=1
		Phase.NIGHT:
			if time_elapsed >= DURATION_NIGHT:
				# Malam selesai: Masuk ke subuh hari berikutnya
				current_day += 1
				transition_to_phase(Phase.DAY)
				senter.energy=0
	update_hud()

func transition_to_phase(new_phase: Phase) -> void:
	current_phase = new_phase
	time_elapsed = 0.0
	
	var target_color: Color = COLOR_DAY
	var transition_duration: float = 3.0 # Transisi warna halus selama 3 detik
	
	match new_phase:
		Phase.DAY:
			target_color = COLOR_DAY
			print("Fase: Siang Hari dimulai. Hari ke-", current_day)
		Phase.DUSK:
			target_color = COLOR_DUSK
			print("Fase: Sore Hari tiba! Sirene berbunyi.")
			play_siren()
		Phase.NIGHT:
			target_color = COLOR_NIGHT
			print("Fase: Malam Hari! Zombi mulai agresif.")
	
	# Transisi warna layar secara halus menggunakan Tween bawaan Godot 4
	var tween: Tween = create_tween()
	tween.tween_property(self, "color", target_color, transition_duration)

func play_siren() -> void:
	if siren_player and siren_player.stream:
		siren_player.play()
	else:
		print("BUNYI SIRENE: WUUUU WUUUU! (Audio placeholder)")

func update_hud() -> void:
	if not time_label:
		return
	
	var phase_name: String = ""
	var remaining_time: float = 0.0
	
	match current_phase:
		Phase.DAY:
			phase_name = "Siang"
			remaining_time = DURATION_DAY - time_elapsed
		Phase.DUSK:
			phase_name = "Sore (Bahaya!)"
			remaining_time = DURATION_DUSK - time_elapsed
		Phase.NIGHT:
			phase_name = "Malam"
			remaining_time = DURATION_NIGHT - time_elapsed
			
	time_label.text = "Hari: %d | Fase: %s | Sisa Waktu: %d detik" % [current_day, phase_name, int(remaining_time)]

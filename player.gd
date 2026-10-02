extends CharacterBody2D

@export var walk_speed=200
@export var run_speed=600


var current_stamina
@export var max_stamina=100
@export var stamina_drain_per_second=25 
@export var stamina_regen_per_second=25 
var can_sprint = true  
@onready var animasi: AnimatedSprite2D = $animasi
var input_direction:Vector2
var is_moving:bool
var is_running:bool
var last_direction: String = "Down"  
func _ready() -> void:
	current_stamina=max_stamina

func _physics_process(delta: float) -> void:
	input_direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	is_moving = input_direction !=Vector2.ZERO
	is_running = Input.is_action_pressed("run") and is_moving and can_sprint
	
	var currect_speed=walk_speed
	
	if is_running:
		currect_speed=run_speed
		
		current_stamina-=stamina_drain_per_second*delta
		
		if current_stamina<=0:
			current_stamina=0
			can_sprint = false  
	else:
		if current_stamina < max_stamina and Input.is_action_pressed("run")==false:
			current_stamina+=stamina_regen_per_second*delta
			if current_stamina > max_stamina:
				current_stamina=max_stamina
		if not can_sprint and current_stamina >= 20.0:                          
			can_sprint = true   
	velocity=input_direction*currect_speed
	move_and_slide()
	update_animation()

func update_animation() :
	if is_moving:                                                             
		if abs(input_direction.x) > abs(input_direction.y):
			if input_direction.x > 0:                                               
				last_direction = "Right"                                                
			else:                                                                   
				last_direction = "Left"                                                 
		else:                                                                   
			if input_direction.y > 0:                                               
				last_direction = "Down"                                                 
			else:                                                                   
				last_direction = "Up"                                                                                                          
		animasi.play(last_direction + "_Run")                                   
	else:      
		animasi.play(last_direction + "_Idle") 

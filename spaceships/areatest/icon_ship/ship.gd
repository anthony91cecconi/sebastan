extends CharacterBody2D

@export var speed: float = 20.0 

@onready var menu: Control = $Control
@onready var navigate_button: Button = $Control/Navigate
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var target_position: Vector2 = Vector2.ZERO
var is_waiting_for_click: bool = false # Diventa true quando premiamo "Navigate"

# Variabile per ricordarsi l'ultimo quadrante stampato ed evitare di intasare la console
var ultimo_quadrante_rilevato: Vector2i = Vector2i(-999, -999)

func _ready() -> void:
	menu.visible = false # Il menu parte nascosto
	target_position = global_position # All'inizio la destinazione è dove si trova già
	
	# Colleghiamo il pulsante "Navigate" al suo codice
	navigate_button.pressed.connect(_on_navigate_pressed)

func _process(_delta: float) -> void:
	# 1. TRACCIAMENTO PASSIVO DEL QUADRANTE
	# La nave si muove liberamente, ma calcola in che "zona" da 100x100px sta passando
	var quadrante_attuale = Vector2i(
		floor(global_position.x / 100.0),
		floor(global_position.y / 100.0)
	)
	
	# Stampa in console SOLO se la nave è appena entrata in un quadrante diverso
	if quadrante_attuale != ultimo_quadrante_rilevato:
		ultimo_quadrante_rilevato = quadrante_attuale
		print("L'astronave si trova nel quadrante: ", quadrante_attuale)

	# 2. GESTIONE MOVIMENTO (Preciso al pixel)
	# Se siamo arrivati al punto esatto cliccato, ci fermiamo
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
		
	# Calcoliamo la direzione verso il prossimo punto preciso del percorso
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * speed
	
	# Muoviamo il CharacterBody2D
	velocity = new_velocity
	move_and_slide()

# Intercettiamo i click globali sulla mappa per impostare la destinazione
func _unhandled_input(event: InputEvent) -> void:
	if is_waiting_for_click and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Prendiamo la coordinata in pixel ESATTA di dove ha cliccato il mouse
			target_position = get_global_mouse_position()
			
			# Diciamo alla navigazione di andare in quel punto millimetrico
			nav_agent.target_position = target_position
			
			# Resettiamo lo stato
			is_waiting_for_click = false
			menu.visible = false

func _on_navigate_pressed() -> void:
	is_waiting_for_click = true
	menu.visible = false


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Mostriamo il menu di comando
			menu.visible = true

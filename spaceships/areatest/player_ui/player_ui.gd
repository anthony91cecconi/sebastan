extends Camera2D

@export_category("Spostamento")
@export var drag_speed: float = 1.0

@export_category("Zoom")
@export var zoom_speed: float = 0.05
@export var min_zoom: float = 0.5   # Più lontano (mappa rimpicciolita)
@export var max_zoom: float = 2.0   # Più vicino (mappa ingrandita)

# Variabili di tracciamento
var is_dragging: bool = false
var touch_points: Dictionary = {}  # Memorizza le posizioni delle dita per il mobile
var start_zoom_dist: float = 0.0
var start_zoom: Vector2 = Vector2.ONE

func _unhandled_input(event: InputEvent) -> void:
	
	# ==========================================
	# 1. GESTIONE SPOSTAMENTO (Mouse Destro / Dito Singolo)
	# ==========================================
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_dragging = event.pressed
			
	elif event is InputEventScreenTouch:
		if event.pressed:
			touch_points[event.index] = event.position
		else:
			touch_points.erase(event.index)
		
		# Trasciniamo solo se c'è un solo dito sullo schermo
		is_dragging = touch_points.size() == 1

	if event is InputEventMouseMotion:
		# Se stiamo usando il mobile, aggiorniamo la posizione del dito registrato
		if event is InputEventScreenDrag:
			touch_points[event.index] = event.position
			
		if is_dragging:
			# Dividiamo per lo zoom attuale per mantenere lo spostamento coerente 
			# sia quando siamo vicini che quando siamo lontani
			position -= event.relative * drag_speed / zoom.x

	# ==========================================
	# 2. GESTIONE ZOOM MOUSE (Rotellina)
	# ==========================================
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_cambia_zoom(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_cambia_zoom(-zoom_speed)

	# ==========================================
	# 3. GESTIONE ZOOM MOBILE (Pinch / Due Dita)
	# ==========================================
	if event is InputEventScreenDrag and touch_points.size() == 2:
		# Calcoliamo la distanza attuale tra le due dita
		var dita = touch_points.values()
		var dist_attuale = dita[0].distance_to(dita[1])
		
		# Se l'evento è appena iniziato (la distanza iniziale non è ancora settata)
		if start_zoom_dist == 0.0:
			start_zoom_dist = dist_attuale
			start_zoom = zoom
		else:
			# Calcoliamo il fattore di zoom in base a quanto si sono allontanate/avvicinate le dita
			var fattore = dist_attuale / start_zoom_dist
			var nuovo_zoom_target = start_zoom * fattore
			
			# Applichiamo i limiti di zoom impostati
			zoom.x = clamp(nuovo_zoom_target.x, min_zoom, max_zoom)
			zoom.y = clamp(nuovo_zoom_target.y, min_zoom, max_zoom)
			
	# Resettiamo il tracciamento del pinch quando le dita si alzano
	if event is InputEventScreenTouch and touch_points.size() < 2:
		start_zoom_dist = 0.0

# Funzione di supporto per applicare lo zoom con i limiti (clamp)
func _cambia_zoom(quantita: float) -> void:
	var nuovo_zoom = zoom.x + quantita
	nuovo_zoom = clamp(nuovo_zoom, min_zoom, max_zoom)
	zoom = Vector2(nuovo_zoom, nuovo_zoom)

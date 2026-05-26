extends TileMapLayer

# Se vuoi nascondere i numeri in gioco, basta mettere questo su 'false'
@export var mostra_coordinate: bool = true

func _ready() -> void:
	# Forza il ridisegno della mappa all'avvio
	queue_redraw()

func _draw() -> void:
	if not mostra_coordinate:
		return
		
	# Al posto di ThemeDB, prendiamo il font di sistema predefinito direttamente da Control
	var font = Control.new().get_theme_font("font")
	var dimensione_font = 14
	
	# Prendiamo la lista di tutte le celle che hai effettivamente disegnato nella griglia
	var celle_usate = get_used_cells()
	
	for cella in celle_usate:
		# Convertiamo le coordinate della griglia in pixel per sapere dove scrivere
		var posizione_pixel = map_to_local(cella)
		
		# Creiamo il testo da mostrare (es: "0,0" oppure "X:2 Y:3")
		var testo = str(cella.x) + "," + str(cella.y)
		
		# Centriamo leggermente il testo all'interno del tile da 100x100
		# (Spostiamo l'origine in alto a sinistra rispetto al centro del tile)
		var offset_testo = posizione_pixel + Vector2(-20, 5)
		
		# Disegniamo il testo a schermo (Colore Bianco, con un leggero contrasto)
		draw_string(font, offset_testo, testo, HORIZONTAL_ALIGNMENT_CENTER, -1, dimensione_font, Color(1.0, 1.0, 1.0, 0.5))

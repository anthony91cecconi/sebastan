extends TextureButton
class_name ServerUI

@onready var labelName: Label = $LabelName
@onready var labelAddress: Label = $LabelAddress
@onready var labelPlayers: Label = $LabelPlayers
var currentPlayers : int 
var maxPlayers : int


var color : Color
	

# Questa funzione riceve i dati e aggiorna la grafica in modo sicuro
func setup(server_data: Dictionary) -> void:
	# Se i nodi @onready non sono ancora pronti, aspettiamo che la scena entri nel "tree"
	if not is_inside_tree():
		await ready
	maxPlayers = server_data["maxPlayers"]
	currentPlayers = server_data["currentPlayers"]
	set_color()
	labelName.text = server_data["name"]
	labelAddress.text = server_data["ip"] + ":" + str(server_data["port"])
	labelPlayers.text = str(currentPlayers) + "/" + str(maxPlayers)
	labelPlayers.add_theme_color_override("font_color",color)

func set_color() -> void:
	if currentPlayers < maxPlayers: 
		color = Color.GREEN
	else:
		color = Color.RED
		disabled = true

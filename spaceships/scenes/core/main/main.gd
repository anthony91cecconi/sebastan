extends CanvasLayer

const CURRENT_VERSION = "0.0.7"
const VERSION_CHECK_URL = "http://93.38.52.145:8090/servers/version"

@onready var http_request = $HTTPRequest
@onready var progress_bar = $ProgressBar
@onready var info_label = $Label

var download_url = ""
var is_downloading = false

func _ready():
	progress_bar.visible = false
	info_label.text = "Verifica aggiornamenti in corso... al gateway 93.38.52.145"
	
	http_request.request_completed.connect(_on_request_completed)
	
	var error = http_request.request(VERSION_CHECK_URL)
	if error != OK:
		info_label.text = "Errore di connessione. server irraggiungibile."
		await get_tree().create_timer(1.0).timeout
		_start_normal_game()

func _process(_delta):
	if is_downloading:
		var body_size = http_request.get_body_size()
		var downloaded_bytes = http_request.get_downloaded_bytes()
		
		if body_size > 0:
			# Calcolo della percentuale per la ProgressBar grafica
			var percentage = (float(downloaded_bytes) / float(body_size)) * 100
			progress_bar.value = percentage
			
			# Conversione dei byte in Megabyte (MB) con 2 cifre decimali
			var downloaded_mb = float(downloaded_bytes) / 1024.0 / 1024.0
			var total_mb = float(body_size) / 1024.0 / 1024.0
			
			# Stringa formattata (es. "Aggiornamento in corso: 1.25 MB / 3.50 MB")
			info_label.text = "Aggiornamento obbligatorio in corso: %.2f MB / %.2f MB" % [downloaded_mb, total_mb]

func _on_request_completed(_result, response_code, _headers, body):
	if not is_downloading:
		info_label.text = "Tentativo di download avviato..."
		await get_tree().create_timer(1.0).timeout
		info_label.text = "response_code = " + str(response_code)
		await get_tree().create_timer(1.0).timeout
		
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response = json.get_data()
			
			var latest_version = response["latest_version"]
			download_url = response["download_url"]
			
			if has_node("/root/D"):
				get_node("/root/D").call("focus", str(latest_version))
				get_node("/root/D").call("focus", str(CURRENT_VERSION))
			
			if latest_version != CURRENT_VERSION:
				_start_automatic_download()
			else:
				info_label.text = "Gioco aggiornato! Avvio in corso..."
				_start_normal_game()
		else:
			info_label.text = "Errore di rete. Impossibile verificare gli aggiornamenti."
	else:
		is_downloading = false
		if response_code == 200:
			info_label.text = "Download completato! Apertura installatore..."
			
			if OS.get_name() == "Android":
				var download_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
				var save_path = download_dir + "/spaceships_update.apk"
				var native_path = ProjectSettings.globalize_path(save_path)
				
				# Forzatura dell'Intent nativo Android tramite riga di comando di sistema
				var args = ["-a", "android.intent.action.VIEW", "-d", "file://" + native_path, "-t", "application/vnd.android.package-archive"]
				var output = []
				var exit_code = OS.execute("am", args, output, true)
				if exit_code != 0:
					info_label.text = "Aggiornamento pronto! Apri l'app 'File' o 'Download' del telefono e clicca su spaceships_update.apk per installarlo."
					OS.shell_open("content://com.android.externalstorage.documents/document/primary%3ADownload")
				#if exit_code != 0:
					#info_label.text = "Installazione automatica bloccata (Codice: " + str(exit_code) + "). Apri l'APK manualmente dalla cartella Download."
			else:
				# Fallback per i test su PC
				var download_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
				var save_path = download_dir + "/spaceships_update.apk"
				OS.shell_open(ProjectSettings.globalize_path(save_path))
		else:
			info_label.text = "Errore durante il download dell'aggiornamento. Riprova più tardi."
			progress_bar.visible = false

func _start_automatic_download():
	progress_bar.visible = true
	progress_bar.value = 0
	info_label.text = "Nuova versione trovata. Download dell'aggiornamento..."
	
	# Salviamo nella cartella Download del sistema, fondamentale per far leggere il file ad Android
	var download_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	var save_path = download_dir + "/spaceships_update.apk"
	
	http_request.set_download_file(save_path)
	
	is_downloading = true
	var error = http_request.request(download_url)
	if error != OK:
		info_label.text = "Errore nell'avviare il download automatico."
		is_downloading = false

func _start_normal_game():
	get_tree().change_scene_to_file("res://scenes/core/home/home.tscn")

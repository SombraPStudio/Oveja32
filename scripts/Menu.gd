extends Node2D

const CONFIG_PATH = "user://config.json"

var config_data = {
	"audio": {
		"master_volume": 1.0,
		"music_volume": 0.8,
		"sfx_volume": 1.0,
		"mute_all": false
	},
	"language": {
		"current_language": "Esp",
		"available_languages": ["Esp", "Eng"]
	},
	"video": {
		"fullscreen": false,
		"vsync": true,
		"window_width": 1280,
		"window_height": 720
	}
}

func _ready():
	cargar_configuracion()
	aplicar_configuracion()

func cargar_configuracion():
	var archivo = File.new()
	if not archivo.file_exists(CONFIG_PATH):
		guardar_configuracion()
		return

	archivo.open(CONFIG_PATH, File.READ)
	var texto = archivo.get_as_text()
	archivo.close()

	var parse = JSON.parse(texto)
	if parse.error == OK and parse.result is Dictionary:
		config_data = parse.result

func guardar_configuracion():
	var archivo = File.new()
	archivo.open(CONFIG_PATH, File.WRITE)
	archivo.store_string(JSON.print(config_data, "\t"))
	archivo.close()

func aplicar_configuracion():
	OS.window_fullscreen = config_data["video"]["fullscreen"]
	OS.vsync_enabled = config_data["video"]["vsync"]

extends Node

const SAVE_PATH = "user://wazobia_save.json"

func save_player(data):
    var file = File.new()
    if file.open(SAVE_PATH, File.WRITE) == OK:
        file.store_string(to_json(data))
        file.close()

func load_player():
    var file = File.new()
    if not file.file_exists(SAVE_PATH): return {}
    if file.open(SAVE_PATH, File.READ) != OK: return {}
    var data = parse_json(file.get_as_text())
    file.close()
    return data if typeof(data) == TYPE_DICTIONARY else {}

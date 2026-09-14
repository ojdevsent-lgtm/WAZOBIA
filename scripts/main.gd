extends Node

# WAZOBIA - Godot 3.x Android-first open-world foundation.
# This file owns the boot flow, lobby, character creation, asset-integrated
# prototype city, HUD, local continuation, room UI foundation and gameplay loop.

var player
var camera
var world_root
var hud
var status_label
var mission_label
var selected_city = "Lagos"
var player_name = "Player"
var player_gender = "Male"
var money = 50000
var wanted = 0
var mission_state = "available"
var mission_reward = 25000
var mission_marker
var current_vehicle = null
var police_units = []
var boot_progress = 0.0
var boot_message = "Preparing WAZOBIA..."
var city_data = {
    "Lagos": {"ground": Color(0.16, 0.34, 0.20), "district": "Mainland", "spawn": Vector3(0, 1, 24)},
    "Warri": {"ground": Color(0.20, 0.34, 0.18), "district": "Effurun Road", "spawn": Vector3(0, 1, 24)},
    "Benin City": {"ground": Color(0.34, 0.22, 0.12), "district": "Ring Road", "spawn": Vector3(0, 1, 24)},
    "Port Harcourt": {"ground": Color(0.12, 0.32, 0.28), "district": "GRA", "spawn": Vector3(0, 1, 24)},
    "Abuja": {"ground": Color(0.32, 0.30, 0.25), "district": "Central Area", "spawn": Vector3(0, 1, 24)}
}
var building_assets = [
    "res://Assets/building-a.glb", "res://Assets/building-b.glb", "res://Assets/building-c.glb",
    "res://Assets/building-d.glb", "res://Assets/building-e.glb", "res://Assets/building-f.glb",
    "res://Assets/building-g.glb", "res://Assets/building-h.glb", "res://Assets/building-i.glb",
    "res://Assets/building-j.glb", "res://Assets/building-k.glb", "res://Assets/building-l.glb",
    "res://Assets/building-m.glb", "res://Assets/building-n.glb",
    "res://Assets/building-skyscraper-a.glb", "res://Assets/building-skyscraper-b.glb"
]
var room_name = "Warri Boys"
var room_city = "Warri"
var room_type = "Open World"
var room_players = 8
var room_private = true

func _ready():
    randomize()
    setup_input()
    show_loading_screen()

func setup_input():
    _add_key_action("move_forward", KEY_W)
    _add_key_action("move_backward", KEY_S)
    _add_key_action("move_left", KEY_A)
    _add_key_action("move_right", KEY_D)

func _add_key_action(action, key):
    if InputMap.has_action(action): return
    InputMap.add_action(action)
    var ev = InputEventKey.new()
    ev.scancode = key
    InputMap.action_add_event(action, ev)

func clear_screen():
    for child in get_children():
        if child != self: child.queue_free()

func label(text, size):
    var l = Label.new()
    l.text = text
    l.add_font_size_override("font_size", size)
    return l

func style_panel(color, radius = 14):
    var s = StyleBoxFlat.new()
    s.bg_color = color
    s.corner_radius_top_left = radius
    s.corner_radius_top_right = radius
    s.corner_radius_bottom_left = radius
    s.corner_radius_bottom_right = radius
    s.border_width_left = 1
    s.border_width_right = 1
    s.border_width_top = 1
    s.border_width_bottom = 1
    s.border_color = Color(1, 1, 1, 0.10)
    s.content_margin_left = 18
    s.content_margin_right = 18
    s.content_margin_top = 12
    s.content_margin_bottom = 12
    return s

func make_button(parent, text, pos, size, callback, font_size = 18):
    var b = Button.new()
    b.text = text
    b.rect_position = pos
    b.rect_size = size
    b.add_font_size_override("font_size", font_size)
    b.add_stylebox_override("normal", style_panel(Color(0.06, 0.08, 0.12, 0.96), 10))
    b.add_stylebox_override("hover", style_panel(Color(0.08, 0.15, 0.22, 0.98), 10))
    b.add_stylebox_override("pressed", style_panel(Color(0.04, 0.06, 0.09, 1), 10))
    b.connect("pressed", self, callback)
    parent.add_child(b)
    return b

func show_loading_screen():
    clear_screen()
    boot_progress = 0.0
    boot_message = "Preparing WAZOBIA..."
    var layer = CanvasLayer.new()
    add_child(layer)
    var bg = ColorRect.new()
    bg.color = Color(0.018, 0.025, 0.04, 1)
    bg.set_anchors_and_margins_preset(Control.PRESET_FULL_RECT)
    layer.add_child(bg)
    var city_art = ColorRect.new()
    city_art.color = Color(0.035, 0.075, 0.10, 1)
    city_art.rect_size = Vector2(1280, 460)
    bg.add_child(city_art)
    var horizon = ColorRect.new()
    horizon.color = Color(0.05, 0.18, 0.16, 0.8)
    horizon.rect_position = Vector2(0, 360)
    horizon.rect_size = Vector2(1280, 100)
    city_art.add_child(horizon)
    var title = label("WAZOBIA", 76)
    title.rect_position = Vector2(72, 78)
    bg.add_child(title)
    var sub = label("NIGERIAN OPEN WORLD", 21)
    sub.rect_position = Vector2(78, 162)
    bg.add_child(sub)
    var tip = label("EXPLORE • BUILD • RISE", 18)
    tip.rect_position = Vector2(78, 196)
    bg.add_child(tip)
    var progress_bg = ColorRect.new()
    progress_bg.color = Color(0.10, 0.12, 0.16, 1)
    progress_bg.rect_position = Vector2(78, 570)
    progress_bg.rect_size = Vector2(650, 12)
    bg.add_child(progress_bg)
    var progress = ColorRect.new()
    progress.color = Color(0.78, 0.60, 0.12, 1)
    progress.rect_size = Vector2(10, 12)
    progress_bg.add_child(progress)
    var message = label(boot_message, 16)
    message.rect_position = Vector2(78, 592)
    bg.add_child(message)
    var version = label("ANDROID FIRST  •  GODOT 3  •  ONLINE READY ARCHITECTURE", 13)
    version.rect_position = Vector2(78, 660)
    bg.add_child(version)
    var timer = Timer.new()
    timer.wait_time = 0.12
    timer.autostart = true
    timer.connect("timeout", self, "_loading_tick", [progress, message])
    layer.add_child(timer)

func _loading_tick(progress, message):
    boot_progress += 0.055
    if boot_progress < 0.25: boot_message = "Loading city systems..."
    elif boot_progress < 0.50: boot_message = "Preparing Nigerian environment..."
    elif boot_progress < 0.75: boot_message = "Preparing player systems..."
    else: boot_message = "Starting WAZOBIA..."
    progress.rect_size.x = 650.0 * min(boot_progress, 1.0)
    message.text = boot_message
    if boot_progress >= 1.0:
        show_lobby()

func show_lobby():
    clear_screen()
    var layer = CanvasLayer.new()
    add_child(layer)
    var bg = ColorRect.new()
    bg.color = Color(0.018, 0.025, 0.04, 1)
    bg.set_anchors_and_margins_preset(Control.PRESET_FULL_RECT)
    layer.add_child(bg)
    var header = ColorRect.new()
    header.color = Color(0.035, 0.055, 0.08, 1)
    header.rect_size = Vector2(1280, 120)
    bg.add_child(header)
    var title = label("WAZOBIA", 54)
    title.rect_position = Vector2(54, 28)
    header.add_child(title)
    var online = label("ONLINE WORLD  •  ANDROID", 14)
    online.rect_position = Vector2(58, 82)
    header.add_child(online)
    var profile = label("GUEST PLAYER", 16)
    profile.rect_position = Vector2(1040, 36)
    bg.add_child(profile)
    var state = label("LOCAL PROFILE", 12)
    state.rect_position = Vector2(1040, 62)
    bg.add_child(state)
    var card = Panel.new()
    card.rect_position = Vector2(54, 155)
    card.rect_size = Vector2(720, 430)
    card.add_stylebox_override("panel", style_panel(Color(0.035, 0.045, 0.065, 0.98), 18))
    bg.add_child(card)
    var welcome = label("WELCOME TO WAZOBIA", 30)
    welcome.rect_position = Vector2(32, 28)
    card.add_child(welcome)
    var copy = label("A Nigerian open-world built for exploration, missions,\nvehicles, businesses and multiplayer sessions.", 17)
    copy.rect_position = Vector2(34, 82)
    card.add_child(copy)
    make_button(card, "CONTINUE", Vector2(34, 160), Vector2(300, 58), "_continue_game", 20)
    make_button(card, "NEW GAME", Vector2(354, 160), Vector2(300, 58), "show_creation_screen", 20)
    make_button(card, "CREATE ROOM", Vector2(34, 232), Vector2(300, 58), "show_create_room", 18)
    make_button(card, "JOIN ROOM", Vector2(354, 232), Vector2(300, 58), "show_join_room", 18)
    make_button(card, "FRIENDS", Vector2(34, 304), Vector2(300, 58), "show_friends", 18)
    make_button(card, "PROFILE", Vector2(354, 304), Vector2(300, 58), "show_profile", 18)
    make_button(card, "SETTINGS", Vector2(34, 376), Vector2(300, 42), "show_settings", 15)
    make_button(card, "STORE", Vector2(354, 376), Vector2(300, 42), "show_store", 15)
    var right = Panel.new()
    right.rect_position = Vector2(810, 155)
    right.rect_size = Vector2(415, 430)
    right.add_stylebox_override("panel", style_panel(Color(0.03, 0.07, 0.075, 0.98), 18))
    bg.add_child(right)
    var city = label("NIGERIA", 20)
    city.rect_position = Vector2(28, 26)
    right.add_child(city)
    var cities = label("LAGOS\nWARRI\nBENIN CITY\nPORT HARCOURT\nABUJA", 23)
    cities.rect_position = Vector2(28, 70)
    right.add_child(cities)
    var note = label("Choose your starting city when you begin.\nMore cities can be added without changing\nyour account structure.", 15)
    note.rect_position = Vector2(28, 260)
    right.add_child(note)
    var footer = label("WAZOBIA • BUILD 0.2 FOUNDATION", 12)
    footer.rect_position = Vector2(54, 650)
    bg.add_child(footer)

func show_creation_screen():
    clear_screen()
    var layer = CanvasLayer.new()
    add_child(layer)
    var bg = ColorRect.new()
    bg.color = Color(0.018, 0.025, 0.04, 1)
    bg.set_anchors_and_margins_preset(Control.PRESET_FULL_RECT)
    layer.add_child(bg)
    var title = label("CREATE YOUR CHARACTER", 42)
    title.rect_position = Vector2(70, 52)
    bg.add_child(title)
    var sub = label("Choose who you are and where your story begins.", 17)
    sub.rect_position = Vector2(74, 105)
    bg.add_child(sub)
    var n = label("CHARACTER NAME", 16)
    n.rect_position = Vector2(90, 185)
    bg.add_child(n)
    var name_edit = LineEdit.new()
    name_edit.placeholder_text = "Enter your name"
    name_edit.rect_position = Vector2(90, 215)
    name_edit.rect_size = Vector2(430, 52)
    bg.add_child(name_edit)
    var g = label("GENDER", 16)
    g.rect_position = Vector2(90, 300)
    bg.add_child(g)
    var gender = OptionButton.new()
    gender.add_item("Male")
    gender.add_item("Female")
    gender.rect_position = Vector2(90, 330)
    gender.rect_size = Vector2(240, 48)
    bg.add_child(gender)
    var c = label("STARTING CITY", 16)
    c.rect_position = Vector2(620, 185)
    bg.add_child(c)
    var cities = OptionButton.new()
    for city_name in city_data.keys(): cities.add_item(city_name)
    cities.rect_position = Vector2(620, 215)
    cities.rect_size = Vector2(420, 52)
    bg.add_child(cities)
    var hint = label("You spawn directly into the selected Nigerian city.", 15)
    hint.rect_position = Vector2(620, 290)
    bg.add_child(hint)
    var enter = make_button(bg, "ENTER WAZOBIA", Vector2(620, 335), Vector2(420, 64), "_start_game", 20)
    enter.disconnect("pressed", self, "_start_game")
    enter.connect("pressed", self, "_start_game", [name_edit, gender, cities])
    make_button(bg, "BACK TO LOBBY", Vector2(90, 470), Vector2(250, 52), "show_lobby", 16)
    var info = label("Controls: WASD / keyboard • SHIFT sprint • E interact • SPACE fire\nAndroid: touch controls • PC users can play through Android emulators.", 14)
    info.rect_position = Vector2(90, 570)
    bg.add_child(info)

func _start_game(name_edit, gender, cities):
    player_name = name_edit.text.strip_edges()
    if player_name == "": player_name = "Player"
    player_gender = gender.get_item_text(gender.selected)
    selected_city = cities.get_item_text(cities.selected)
    money = 50000
    spawn_city()

func _continue_game():
    var file = File.new()
    if file.file_exists("user://wazobia_save.json") and file.open("user://wazobia_save.json", File.READ) == OK:
        var parsed = parse_json(file.get_as_text())
        file.close()
        if typeof(parsed) == TYPE_DICTIONARY:
            player_name = str(parsed.get("name", "Player"))
            player_gender = str(parsed.get("gender", "Male"))
            selected_city = str(parsed.get("city", "Lagos"))
            money = int(parsed.get("money", 50000))
            if not city_data.has(selected_city): selected_city = "Lagos"
            spawn_city()
            return
    show_creation_screen()

func show_create_room():
    clear_screen()
    var layer = CanvasLayer.new()
    add_child(layer)
    var bg = ColorRect.new()
    bg.color = Color(0.018, 0.025, 0.04, 1)
    bg.set_anchors_and_margins_preset(Control.PRESET_FULL_RECT)
    layer.add_child(bg)
    var title = label("CREATE ROOM", 40)
    title.rect_position = Vector2(70, 50)
    bg.add_child(title)
    var note = label("Room/session foundation — multiplayer transport will connect here.", 15)
    note.rect_position = Vector2(74, 105)
    bg.add_child(note)
    var name = LineEdit.new()
    name.text = room_name
    name.rect_position = Vector2(100, 175)
    name.rect_size = Vector2(420, 52)
    bg.add_child(name)
    var city = OptionButton.new()
    for c in city_data.keys(): city.add_item(c)
    city.select(max(0, city_data.keys().find(room_city)))
    city.rect_position = Vector2(100, 265)
    city.rect_size = Vector2(420, 52)
    bg.add_child(city)
    var mode = OptionButton.new()
    mode.add_item("Open World")
    mode.add_item("Mission Co-op")
    mode.add_item("Race")
    mode.rect_position = Vector2(100, 355)
    mode.rect_size = Vector2(420, 52)
    bg.add_child(mode)
    var players = OptionButton.new()
    players.add_item("2 Players")
    players.add_item("4 Players")
    players.add_item("8 Players")
    players.select(2)
    players.rect_position = Vector2(100, 445)
    players.rect_size = Vector2(420, 52)
    bg.add_child(players)
    var private_box = CheckButton.new()
    private_box.text = "Friends only"
    private_box.pressed = true
    private_box.rect_position = Vector2(600, 265)
    bg.add_child(private_box)
    make_button(bg, "CREATE ROOM", Vector2(600, 345), Vector2(350, 62), "_create_room", 19)
    make_button(bg, "BACK", Vector2(600, 430), Vector2(350, 52), "show_lobby", 16)

func _create_room():
    show_room_waiting("Room created", "You are the host. Invite friends and start when the server is connected.")

func show_join_room():
    clear_screen()
    var layer = CanvasLayer.new()
    add_child(layer)
    var bg = ColorRect.new()
    bg.color = Color(0.018, 0.025, 0.04, 1)
    bg.set_anchors_and_margins_preset(Control.PRESET_FULL_RECT)
    layer.add_child(bg)
    var title = label("JOIN ROOM", 40)
    title.rect_position = Vector2(70, 55)
    bg.add_child(title)
    var code = LineEdit.new()
    code.placeholder_text = "ROOM CODE"
    code.rect_position = Vector2(100, 190)
    code.rect_size = Vector2(500, 58)
    bg.add_child(code)
    make_button(bg, "JOIN", Vector2(100, 280), Vector2(500, 60), "_join_room", 20)
    make_button(bg, "BACK", Vector2(100, 365), Vector2(500, 52), "show_lobby", 16)
    var info = label("Friends and room discovery will use the online account service when connected.", 15)
    info.rect_position = Vector2(100, 465)
    bg.add_child(info)

func _join_room():
    show_room_waiting("Join request", "Room transport is not connected in this prototype build yet.")

func show_room_waiting(head, body_text):
    clear_screen()
    var layer = CanvasLayer.new()
    add_child(layer)
    var bg = ColorRect.new()
    bg.color = Color(0.018, 0.025, 0.04, 1)
    bg.set_anchors_and_margins_preset(Control.PRESET_FULL_RECT)
    layer.add_child(bg)
    var panel = Panel.new()
    panel.rect_position = Vector2(290, 150)
    panel.rect_size = Vector2(700, 420)
    panel.add_stylebox_override("panel", style_panel(Color(0.035, 0.055, 0.08, 1), 20))
    bg.add_child(panel)
    var h = label(head, 32)
    h.rect_position = Vector2(40, 38)
    panel.add_child(h)
    var body = label(body_text, 17)
    body.rect_position = Vector2(42, 100)
    panel.add_child(body)
    var players = label("PLAYERS\nYou\n+ Invite Friend\n+ Invite Friend\n+ Invite Friend", 18)
    players.rect_position = Vector2(42, 190)
    panel.add_child(players)
    make_button(panel, "START GAME", Vector2(365, 280), Vector2(280, 58), "_room_start", 18)
    make_button(panel, "BACK TO LOBBY", Vector2(42, 350), Vector2(280, 50), "show_lobby", 15)

func _room_start():
    selected_city = room_city
    spawn_city()

func show_friends():
    show_simple_panel("FRIENDS", "Your WAZOBIA friends list will live on the account service.\n\nONLINE\nNo connected friends yet.\n\nINVITE FRIEND\nShare a room code from the multiplayer lobby.")

func show_profile():
    show_simple_panel("PROFILE", "PLAYER\n%s\n\nSTARTING CITY\n%s\n\nBALANCE\n₦%d\n\nACCOUNT\nLocal foundation — cloud account integration is the next backend layer." % [player_name, selected_city, money])

func show_settings():
    show_simple_panel("SETTINGS", "GRAPHICS\nAndroid-first performance mode\n\nCONTROLS\nTouch + keyboard/mouse friendly\n\nAUDIO\nMusic / effects controls will be added with the production audio layer.")

func show_store():
    show_simple_panel("STORE", "WAZOBIA STORE\n\nCoins\nCharacter cosmetics\nVehicles\nProperties\nVehicle customization\nSeason content\n\nDESIGN RULE\nPurchases should not create pay-to-win advantages.\n\nGoogle Play Billing will handle Android digital purchases in the production online build.")

func show_simple_panel(title_text, body_text):
    clear_screen()
    var layer = CanvasLayer.new()
    add_child(layer)
    var bg = ColorRect.new()
    bg.color = Color(0.018, 0.025, 0.04, 1)
    bg.set_anchors_and_margins_preset(Control.PRESET_FULL_RECT)
    layer.add_child(bg)
    var panel = Panel.new()
    panel.rect_position = Vector2(240, 110)
    panel.rect_size = Vector2(800, 500)
    panel.add_stylebox_override("panel", style_panel(Color(0.035, 0.055, 0.08, 1), 20))
    bg.add_child(panel)
    var h = label(title_text, 36)
    h.rect_position = Vector2(38, 30)
    panel.add_child(h)
    var body = label(body_text, 18)
    body.rect_position = Vector2(42, 95)
    panel.add_child(body)
    make_button(panel, "BACK TO LOBBY", Vector2(42, 405), Vector2(280, 54), "show_lobby", 16)

func spawn_city():
    clear_screen()
    mission_state = "available"
    wanted = 0
    police_units.clear()
    current_vehicle = null
    world_root = Spatial.new()
    world_root.name = selected_city.replace(" ", "_")
    add_child(world_root)
    setup_environment()
    create_ground()
    create_roads()
    create_buildings()
    create_npcs()
    create_vehicles()
    create_player()
    create_mission()
    create_hud()
    save_game()

func setup_environment():
    var we = WorldEnvironment.new()
    var env = Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.38, 0.58, 0.75)
    env.ambient_light_color = Color(0.8, 0.8, 0.8)
    env.ambient_light_energy = 1.1
    we.environment = env
    world_root.add_child(we)
    var sun = DirectionalLight.new()
    sun.rotation_degrees = Vector3(-55, -25, 0)
    sun.light_energy = 1.2
    world_root.add_child(sun)

func create_ground():
    var body = StaticBody.new()
    world_root.add_child(body)
    var mesh = MeshInstance.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(180, 180)
    mesh.mesh = plane
    var mat = SpatialMaterial.new()
    mat.albedo_color = city_data[selected_city]["ground"]
    mesh.material_override = mat
    body.add_child(mesh)
    var collision = CollisionShape.new()
    var shape = BoxShape.new()
    shape.extents = Vector3(90, 0.1, 90)
    collision.shape = shape
    collision.translation.y = -0.15
    body.add_child(collision)

func create_roads():
    create_road(Vector3(0, 0.02, 0), Vector2(180, 12), Color(0.055, 0.055, 0.06))
    create_road(Vector3(0, 0.03, 42), Vector2(180, 10), Color(0.06, 0.06, 0.065))
    create_road(Vector3(0, 0.04, -42), Vector2(180, 10), Color(0.06, 0.06, 0.065))
    create_road(Vector3(0, 0.05, 0), Vector2(12, 180), Color(0.055, 0.055, 0.06))

func create_road(pos, size, color):
    var mesh = MeshInstance.new()
    var cube = CubeMesh.new()
    cube.size = Vector3(size.x, 0.08, size.y)
    mesh.mesh = cube
    mesh.translation = pos
    var mat = SpatialMaterial.new()
    mat.albedo_color = color
    mesh.material_override = mat
    world_root.add_child(mesh)

func create_buildings():
    var index = 0
    for x in range(-70, 71, 14):
        if abs(x) < 10: continue
        create_asset_building(Vector3(x, 0, -22), index)
        index += 1
        create_asset_building(Vector3(x, 0, 22), index)
        index += 1
    for z in range(-65, 66, 14):
        if abs(z) < 8: continue
        create_asset_building(Vector3(-28, 0, z), index)
        index += 1
        create_asset_building(Vector3(28, 0, z), index)
        index += 1

func create_asset_building(pos, index):
    var path = building_assets[index % building_assets.size()]
    var packed = load(path)
    if packed != null and packed is PackedScene:
        var instance = packed.instance()
        instance.translation = pos
        var scale_factor = 1.0
        if index % 13 == 0: scale_factor = 1.35
        instance.scale = Vector3.ONE * scale_factor
        world_root.add_child(instance)
        var body = StaticBody.new()
        body.translation = pos
        world_root.add_child(body)
        var col = CollisionShape.new()
        var shape = BoxShape.new()
        shape.extents = Vector3(5.0 * scale_factor, 5.0 * scale_factor, 5.0 * scale_factor)
        col.shape = shape
        col.translation.y = 5.0 * scale_factor
        body.add_child(col)
    else:
        create_building_fallback(pos, Vector3(10, rand_range(6, 14), 12))

func create_building_fallback(pos, size):
    var body = StaticBody.new()
    world_root.add_child(body)
    var mesh = MeshInstance.new()
    var cube = CubeMesh.new()
    cube.size = size
    mesh.mesh = cube
    mesh.translation = pos + Vector3(0, size.y / 2.0, 0)
    var mat = SpatialMaterial.new()
    mat.albedo_color = Color(rand_range(0.35, 0.75), rand_range(0.32, 0.68), rand_range(0.28, 0.62))
    mesh.material_override = mat
    body.add_child(mesh)
    var col = CollisionShape.new()
    var shape = BoxShape.new()
    shape.extents = size / 2.0
    col.shape = shape
    col.translation = mesh.translation
    body.add_child(col)

func create_player():
    player = KinematicBody.new()
    player.name = "Player"
    player.translation = city_data[selected_city]["spawn"]
    player.set_script(load("res://scripts/player.gd"))
    world_root.add_child(player)
    var mesh = MeshInstance.new()
    var capsule = CapsuleMesh.new()
    capsule.radius = 0.45
    capsule.height = 1.8
    mesh.mesh = capsule
    mesh.translation.y = 0.9
    var mat = SpatialMaterial.new()
    mat.albedo_color = Color(0.12, 0.12, 0.16) if player_gender == "Male" else Color(0.55, 0.12, 0.18)
    mesh.material_override = mat
    player.add_child(mesh)
    var col = CollisionShape.new()
    var shape = CapsuleShape.new()
    shape.radius = 0.45
    shape.height = 1.8
    col.shape = shape
    col.translation.y = 0.9
    player.add_child(col)
    camera = Camera.new()
    camera.translation = Vector3(0, 4.0, 7.5)
    camera.rotation_degrees = Vector3(-12, 180, 0)
    player.add_child(camera)
    camera.current = true

func create_npcs():
    for i in range(18):
        var npc = KinematicBody.new()
        npc.set_script(load("res://scripts/npc.gd"))
        npc.translation = Vector3(rand_range(-65, 65), 1, rand_range(-65, 65))
        world_root.add_child(npc)
        var mesh = MeshInstance.new()
        var capsule = CapsuleMesh.new()
        capsule.radius = 0.35
        capsule.height = 1.6
        mesh.mesh = capsule
        mesh.translation.y = 0.8
        var mat = SpatialMaterial.new()
        mat.albedo_color = Color(rand_range(0.1, 0.8), rand_range(0.1, 0.7), rand_range(0.1, 0.7))
        mesh.material_override = mat
        npc.add_child(mesh)
        var col = CollisionShape.new()
        var shape = CapsuleShape.new()
        shape.radius = 0.35
        shape.height = 1.6
        col.shape = shape
        col.translation.y = 0.8
        npc.add_child(col)
        npc.setup(npc.translation)

func create_vehicles():
    for p in [Vector3(-18, 0.8, 0), Vector3(18, 0.8, 0), Vector3(0, 0.8, -28), Vector3(45, 0.8, 42)]:
        create_vehicle(p)

func create_vehicle(pos):
    var car = KinematicBody.new()
    car.set_script(load("res://scripts/vehicle.gd"))
    car.translation = pos
    world_root.add_child(car)
    var mesh = MeshInstance.new()
    var box = CubeMesh.new()
    box.size = Vector3(2.2, 1.0, 4.2)
    mesh.mesh = box
    var mat = SpatialMaterial.new()
    mat.albedo_color = Color(rand_range(0.05, 0.8), rand_range(0.05, 0.8), rand_range(0.05, 0.8))
    mesh.material_override = mat
    car.add_child(mesh)
    var col = CollisionShape.new()
    var shape = BoxShape.new()
    shape.extents = Vector3(1.1, 0.5, 2.1)
    col.shape = shape
    car.add_child(col)

func create_mission():
    mission_marker = MeshInstance.new()
    var cyl = CylinderMesh.new()
    cyl.top_radius = 1.5
    cyl.bottom_radius = 1.5
    cyl.height = 0.15
    mission_marker.mesh = cyl
    mission_marker.translation = Vector3(0, 0.2, -28)
    var mat = SpatialMaterial.new()
    mat.albedo_color = Color(1, 0.72, 0.05)
    mat.emission_enabled = true
    mat.emission = Color(1, 0.35, 0.02)
    mission_marker.material_override = mat
    world_root.add_child(mission_marker)

func create_hud():
    hud = CanvasLayer.new()
    world_root.add_child(hud)
    var top = ColorRect.new()
    top.color = Color(0, 0, 0, 0.62)
    top.rect_position = Vector2(18, 18)
    top.rect_size = Vector2(500, 155)
    hud.add_child(top)
    status_label = label("", 17)
    status_label.rect_position = Vector2(16, 12)
    top.add_child(status_label)
    mission_label = label("", 17)
    mission_label.rect_position = Vector2(20, 180)
    hud.add_child(mission_label)
    create_touch_controls()

func create_touch_controls():
    var names = [["◀", Vector2(35, 570), "left"], ["▶", Vector2(175, 570), "right"], ["▲", Vector2(105, 505), "forward"], ["▼", Vector2(105, 635), "backward"]]
    for item in names:
        var b = Button.new()
        b.text = item[0]
        b.rect_position = item[1]
        b.rect_size = Vector2(70, 60)
        b.modulate.a = 0.65
        b.connect("button_down", self, "_touch", [item[2], true])
        b.connect("button_up", self, "_touch", [item[2], false])
        hud.add_child(b)
    var interact = Button.new()
    interact.text = "E\nUSE"
    interact.rect_position = Vector2(1120, 535)
    interact.rect_size = Vector2(100, 70)
    interact.modulate.a = 0.7
    interact.connect("pressed", self, "interact")
    hud.add_child(interact)
    var shoot_button = Button.new()
    shoot_button.text = "FIRE"
    shoot_button.rect_position = Vector2(1120, 620)
    shoot_button.rect_size = Vector2(100, 70)
    shoot_button.modulate.a = 0.7
    shoot_button.connect("pressed", self, "shoot")
    hud.add_child(shoot_button)

func _touch(kind, value):
    if player == null: return
    if kind == "left": player.touch_left = value
    elif kind == "right": player.touch_right = value
    elif kind == "forward": player.touch_forward = value
    elif kind == "backward": player.touch_backward = value

func _process(delta):
    if player == null: return
    if Input.is_key_pressed(KEY_E): interact()
    if Input.is_key_pressed(KEY_SPACE): shoot()
    var stars = ""
    for i in range(wanted): stars += "★"
    if status_label:
        status_label.text = "WAZOBIA\n%s  |  %s\n%s — %s\nMONEY: ₦%d   HEALTH: %d   WANTED: %s" % [player_name, player_gender, selected_city, city_data[selected_city]["district"], money, player.health, stars]
    if mission_label:
        if mission_state == "available": mission_label.text = "MISSION: Meet the contact at the yellow marker. Press E.\nReward: ₦%d" % mission_reward
        elif mission_state == "active": mission_label.text = "MISSION: Steal a vehicle and bring it to the yellow marker.\nPress E near a vehicle to enter."
        else: mission_label.text = "MISSION COMPLETE • ₦%d earned" % mission_reward
    if mission_state == "active" and current_vehicle != null and current_vehicle.global_transform.origin.distance_to(mission_marker.global_transform.origin) < 7:
        complete_mission()
    if wanted > 0 and police_units.size() < wanted:
        spawn_police()

func interact():
    if player == null: return
    if mission_state == "available" and player.global_transform.origin.distance_to(mission_marker.global_transform.origin) < 8:
        mission_state = "active"
        wanted = 1
        return
    if mission_state == "active" and current_vehicle == null:
        var nearest = nearest_vehicle()
        if nearest != null and nearest.global_transform.origin.distance_to(player.global_transform.origin) < 5:
            enter_vehicle(nearest)

func nearest_vehicle():
    var best = null
    var dist = 9999.0
    for child in world_root.get_children():
        if child.get_script() == load("res://scripts/vehicle.gd"):
            var d = child.global_transform.origin.distance_to(player.global_transform.origin)
            if d < dist:
                dist = d
                best = child
    return best

func enter_vehicle(vehicle):
    current_vehicle = vehicle
    vehicle.occupied = true
    vehicle.driver = player
    player.current_vehicle = vehicle

func shoot():
    if player == null or current_vehicle != null: return
    wanted = min(5, wanted + 1)
    var from = camera.global_transform.origin
    var to = from + -camera.global_transform.basis.z * 45
    var hit = world_root.get_world().direct_space_state.intersect_ray(from, to, [player])
    if hit and hit.collider.has_method("take_damage"):
        hit.collider.take_damage(25)

func spawn_police():
    var cop = KinematicBody.new()
    cop.set_script(load("res://scripts/police.gd"))
    cop.translation = player.global_transform.origin + Vector3(rand_range(-25,25), 1, rand_range(-25,25))
    world_root.add_child(cop)
    var mesh = MeshInstance.new()
    var capsule = CapsuleMesh.new()
    capsule.radius = 0.4
    capsule.height = 1.8
    mesh.mesh = capsule
    mesh.translation.y = 0.9
    var mat = SpatialMaterial.new()
    mat.albedo_color = Color(0.04, 0.08, 0.22)
    mesh.material_override = mat
    cop.add_child(mesh)
    var col = CollisionShape.new()
    var shape = CapsuleShape.new()
    shape.radius = 0.4
    shape.height = 1.8
    col.shape = shape
    col.translation.y = 0.9
    cop.add_child(col)
    cop.setup(player)
    police_units.append(cop)

func complete_mission():
    mission_state = "complete"
    money += mission_reward
    wanted = 0
    for cop in police_units:
        if is_instance_valid(cop): cop.queue_free()
    police_units.clear()
    save_game()

func save_game():
    if player == null: return
    var data = {"name": player_name, "gender": player_gender, "city": selected_city, "money": money}
    var file = File.new()
    if file.open("user://wazobia_save.json", File.WRITE) == OK:
        file.store_string(to_json(data))
        file.close()

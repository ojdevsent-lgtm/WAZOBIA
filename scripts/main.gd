extends Node

# WAZOBIA V1 - Nigerian open-world vertical slice.
# Systems: character creation, city spawn, third-person movement, vehicles,
# civilians, police/wanted level, mission, money, shooting, saving, mobile HUD.

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
var city_data = {
    "Lagos": {"ground": Color(0.16, 0.34, 0.20), "district": "Mainland", "spawn": Vector3(0, 1, 24)},
    "Warri": {"ground": Color(0.20, 0.34, 0.18), "district": "Effurun Road", "spawn": Vector3(0, 1, 24)},
    "Benin City": {"ground": Color(0.34, 0.22, 0.12), "district": "Ring Road", "spawn": Vector3(0, 1, 24)},
    "Port Harcourt": {"ground": Color(0.12, 0.32, 0.28), "district": "GRA", "spawn": Vector3(0, 1, 24)},
    "Abuja": {"ground": Color(0.32, 0.30, 0.25), "district": "Central Area", "spawn": Vector3(0, 1, 24)}
}

func _ready():
    randomize()
    setup_input()
    show_creation_screen()

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

func show_creation_screen():
    clear_screen()
    var layer = CanvasLayer.new()
    add_child(layer)
    var bg = ColorRect.new()
    bg.color = Color(0.025, 0.035, 0.05, 1)
    bg.set_anchors_and_margins_preset(Control.PRESET_FULL_RECT)
    layer.add_child(bg)

    var title = label("WAZOBIA", 58)
    title.rect_position = Vector2(90, 55)
    bg.add_child(title)
    var sub = label("NIGERIAN OPEN-WORLD • VERSION 1", 20)
    sub.rect_position = Vector2(94, 120)
    bg.add_child(sub)

    var n = label("CHARACTER NAME", 18)
    n.rect_position = Vector2(110, 190)
    bg.add_child(n)
    var name_edit = LineEdit.new()
    name_edit.placeholder_text = "Enter your name"
    name_edit.rect_position = Vector2(110, 225)
    name_edit.rect_size = Vector2(420, 52)
    bg.add_child(name_edit)

    var g = label("GENDER", 18)
    g.rect_position = Vector2(110, 305)
    bg.add_child(g)
    var gender = OptionButton.new()
    gender.add_item("Male")
    gender.add_item("Female")
    gender.rect_position = Vector2(110, 340)
    gender.rect_size = Vector2(240, 48)
    bg.add_child(gender)

    var c = label("STARTING CITY", 18)
    c.rect_position = Vector2(610, 190)
    bg.add_child(c)
    var cities = OptionButton.new()
    for city in city_data.keys(): cities.add_item(city)
    cities.rect_position = Vector2(610, 225)
    cities.rect_size = Vector2(400, 52)
    bg.add_child(cities)

    var hint = label("Your character will spawn in the Nigerian city you select.", 16)
    hint.rect_position = Vector2(610, 295)
    bg.add_child(hint)
    var start = Button.new()
    start.text = "CREATE CHARACTER & ENTER CITY"
    start.rect_position = Vector2(610, 345)
    start.rect_size = Vector2(400, 65)
    start.add_font_size_override("font_size", 20)
    start.connect("pressed", self, "_start_game", [name_edit, gender, cities])
    bg.add_child(start)

    var info = label("PC: WASD move • SHIFT sprint • E interact/enter vehicle • F exit vehicle • SPACE shoot\nAndroid: use the on-screen controls", 15)
    info.rect_position = Vector2(110, 560)
    bg.add_child(info)
    var footer = label("WAZOBIA — original Nigerian open-world game universe", 14)
    footer.rect_position = Vector2(110, 665)
    bg.add_child(footer)

func _start_game(name_edit, gender, cities):
    player_name = name_edit.text.strip_edges()
    if player_name == "": player_name = "Player"
    player_gender = gender.get_item_text(gender.selected)
    selected_city = cities.get_item_text(cities.selected)
    spawn_city()

func spawn_city():
    clear_screen()
    mission_state = "available"
    wanted = 0
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
    for x in range(-70, 71, 14):
        if abs(x) < 10: continue
        create_building(Vector3(x, rand_range(3, 7), -22), Vector3(10, rand_range(6, 14), 12))
        create_building(Vector3(x, rand_range(3, 6), 22), Vector3(10, rand_range(6, 12), 12))
    for z in range(-65, 66, 14):
        if abs(z) < 8: continue
        create_building(Vector3(-28, rand_range(3, 6), z), Vector3(12, rand_range(6, 12), 10))
        create_building(Vector3(28, rand_range(3, 8), z), Vector3(12, rand_range(6, 16), 10))

func create_building(pos, size):
    var body = StaticBody.new()
    world_root.add_child(body)
    var mesh = MeshInstance.new()
    var cube = CubeMesh.new()
    cube.size = size
    mesh.mesh = cube
    mesh.translation = pos
    var mat = SpatialMaterial.new()
    mat.albedo_color = Color(rand_range(0.35, 0.75), rand_range(0.32, 0.68), rand_range(0.28, 0.62))
    mesh.material_override = mat
    body.add_child(mesh)
    var col = CollisionShape.new()
    var shape = BoxShape.new()
    shape.extents = size / 2.0
    col.shape = shape
    col.translation = pos
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
    top.rect_size = Vector2(470, 155)
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
    var shoot = Button.new()
    shoot.text = "FIRE"
    shoot.rect_position = Vector2(1120, 620)
    shoot.rect_size = Vector2(100, 70)
    shoot.modulate.a = 0.7
    shoot.connect("pressed", self, "shoot")
    hud.add_child(shoot)

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
    if status_label:
        status_label.text = "WAZOBIA\n%s  |  %s\n%s — %s\nMONEY: ₦%d   HEALTH: %d   WANTED: %s" % [player_name, player_gender, selected_city, city_data[selected_city]["district"], money, player.health, "★".repeat(wanted)]
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
    # V1 uses a short forward ray for lightweight combat.
    var from = camera.global_transform.origin
    var to = from + -camera.global_transform.basis.z * 45
    var hit = get_world().direct_space_state.intersect_ray(from, to, [player])
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

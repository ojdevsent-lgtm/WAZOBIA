extends Node

# WAZOBIA Version 1
# Character creation -> city selection -> selected-city spawn.

var player_name := ""
var player_gender := "Male"
var selected_city := "Lagos"
var world_root: Node
var player: KinematicBody
var camera: Camera
var status_label: Label
var city_data = {
    "Lagos": {"color": Color(0.05, 0.30, 0.55), "spawn": Vector3(0, 1, 0), "district": "Mainland"},
    "Warri": {"color": Color(0.18, 0.38, 0.16), "spawn": Vector3(0, 1, 0), "district": "Effurun Road"},
    "Benin City": {"color": Color(0.45, 0.20, 0.08), "spawn": Vector3(0, 1, 0), "district": "Ring Road"},
    "Port Harcourt": {"color": Color(0.10, 0.35, 0.30), "spawn": Vector3(0, 1, 0), "district": "GRA"},
    "Abuja": {"color": Color(0.35, 0.35, 0.32), "spawn": Vector3(0, 1, 0), "district": "Central Area"}
}

func _ready():
    show_creation_screen()

func clear_screen():
    for child in get_children():
        if child != self:
            child.queue_free()

func make_label(text: String, size: int = 24) -> Label:
    var label = Label.new()
    label.text = text
    label.add_font_size_override("font_size", size)
    return label

func show_creation_screen():
    clear_screen()
    var layer = CanvasLayer.new()
    add_child(layer)

    var panel = ColorRect.new()
    panel.color = Color(0.025, 0.035, 0.05, 0.98)
    panel.set_anchors_and_margins_preset(Control.PRESET_FULL_RECT)
    layer.add_child(panel)

    var title = make_label("WAZOBIA", 54)
    title.rect_position = Vector2(90, 55)
    panel.add_child(title)

    var subtitle = make_label("NIGERIAN OPEN-WORLD — VERSION 1", 18)
    subtitle.rect_position = Vector2(94, 120)
    panel.add_child(subtitle)

    var name_label = make_label("CHARACTER NAME", 20)
    name_label.rect_position = Vector2(110, 190)
    panel.add_child(name_label)

    var name_edit = LineEdit.new()
    name_edit.name = "NameInput"
    name_edit.placeholder_text = "Enter your name"
    name_edit.rect_position = Vector2(110, 225)
    name_edit.rect_size = Vector2(430, 50)
    panel.add_child(name_edit)

    var gender_label = make_label("GENDER", 20)
    gender_label.rect_position = Vector2(110, 305)
    panel.add_child(gender_label)

    var gender = OptionButton.new()
    gender.name = "GenderInput"
    gender.add_item("Male")
    gender.add_item("Female")
    gender.rect_position = Vector2(110, 340)
    gender.rect_size = Vector2(250, 48)
    panel.add_child(gender)

    var city_label = make_label("STARTING CITY", 20)
    city_label.rect_position = Vector2(600, 190)
    panel.add_child(city_label)

    var cities = OptionButton.new()
    cities.name = "CityInput"
    for city in city_data.keys():
        cities.add_item(city)
    cities.rect_position = Vector2(600, 225)
    cities.rect_size = Vector2(400, 50)
    panel.add_child(cities)

    var city_hint = make_label("Your character will spawn in the city you choose.", 16)
    city_hint.rect_position = Vector2(600, 290)
    panel.add_child(city_hint)

    var start = Button.new()
    start.text = "ENTER THE CITY"
    start.rect_position = Vector2(600, 360)
    start.rect_size = Vector2(400, 65)
    start.add_font_size_override("font_size", 24)
    start.connect("pressed", self, "_on_start_pressed", [name_edit, gender, cities])
    panel.add_child(start)

    var footer = make_label("WAZOBIA presents an original Nigerian open-world experience.", 15)
    footer.rect_position = Vector2(110, 650)
    panel.add_child(footer)

func _on_start_pressed(name_edit: LineEdit, gender: OptionButton, cities: OptionButton):
    player_name = name_edit.text.strip_edges()
    if player_name == "":
        player_name = "Player"
    player_gender = gender.get_item_text(gender.selected)
    selected_city = cities.get_item_text(cities.selected)
    spawn_selected_city()

func spawn_selected_city():
    clear_screen()

    world_root = Spatial.new()
    world_root.name = selected_city.replace(" ", "_")
    add_child(world_root)

    var environment = WorldEnvironment.new()
    var env = Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.32, 0.48, 0.62)
    env.ambient_light_color = Color(0.75, 0.78, 0.82)
    env.ambient_light_energy = 1.0
    environment.environment = env
    world_root.add_child(environment)

    var sun = DirectionalLight.new()
    sun.rotation_degrees = Vector3(-55, -25, 0)
    sun.light_energy = 1.0
    world_root.add_child(sun)

    create_ground()
    create_city_blocks()
    create_player()
    create_ui()

func create_ground():
    var body = StaticBody.new()
    body.name = "Ground"
    world_root.add_child(body)

    var mesh_instance = MeshInstance.new()
    var mesh = PlaneMesh.new()
    mesh.size = Vector2(120, 120)
    mesh_instance.mesh = mesh
    mesh_instance.material_override = SpatialMaterial.new()
    mesh_instance.material_override.albedo_color = city_data[selected_city]["color"]
    body.add_child(mesh_instance)

    var collision = CollisionShape.new()
    var shape = BoxShape.new()
    shape.extents = Vector3(60, 0.1, 60)
    collision.shape = shape
    collision.translation.y = -0.1
    body.add_child(collision)

func create_city_blocks():
    for i in range(-4, 5):
        create_building(Vector3(i * 10, 2.5, -18), Vector3(7, 5, 7))
        create_building(Vector3(i * 10, 4, 18), Vector3(7, 8, 7))
    for z in range(-1, 2):
        create_building(Vector3(-35, 3, z * 14), Vector3(8, 6, 8))
        create_building(Vector3(35, 4, z * 14), Vector3(8, 8, 8))

func create_building(pos: Vector3, size: Vector3):
    var mesh_instance = MeshInstance.new()
    var mesh = CubeMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    mesh_instance.translation = pos
    mesh_instance.material_override = SpatialMaterial.new()
    mesh_instance.material_override.albedo_color = Color(0.55, 0.55, 0.58)
    world_root.add_child(mesh_instance)

func create_player():
    player = KinematicBody.new()
    player.name = "Player"
    player.translation = city_data[selected_city]["spawn"]
    player.set_script(load("res://scripts/player.gd"))
    world_root.add_child(player)

    var mesh_instance = MeshInstance.new()
    var mesh = CapsuleMesh.new()
    mesh.radius = 0.45
    mesh.height = 1.8
    mesh_instance.mesh = mesh
    mesh_instance.translation.y = 0.9
    player.add_child(mesh_instance)

    var collision = CollisionShape.new()
    var shape = CapsuleShape.new()
    shape.radius = 0.45
    shape.height = 1.8
    collision.shape = shape
    collision.translation.y = 0.9
    player.add_child(collision)

    camera = Camera.new()
    camera.translation = Vector3(0, 3.5, 6.5)
    camera.rotation_degrees = Vector3(-12, 180, 0)
    player.add_child(camera)
    camera.current = true

func create_ui():
    var layer = CanvasLayer.new()
    world_root.add_child(layer)

    var info = ColorRect.new()
    info.color = Color(0, 0, 0, 0.55)
    info.rect_position = Vector2(20, 20)
    info.rect_size = Vector2(430, 120)
    layer.add_child(info)

    status_label = make_label("", 18)
    status_label.rect_position = Vector2(35, 32)
    info.add_child(status_label)
    status_label.text = "WAZOBIA\n" + player_name + "  |  " + player_gender + "\n" + selected_city + " — " + city_data[selected_city]["district"] + "\nWASD to move"

    var city_title = make_label(selected_city.to_upper(), 34)
    city_title.rect_position = Vector2(20, 655)
    layer.add_child(city_title)

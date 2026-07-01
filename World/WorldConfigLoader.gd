extends Resource
class_name WorldConfigLoader

"""
Se entrega una estructura de JSON para fowmar el mundo	
"""

func load_world(path: String, world_entry: Dictionary) -> WorldConfig:
	print("CARGANDO MUNDO JSON")
	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		push_error("JSON inválido en " + path)
		return null

	'''Metadata del mundo'''
	var world := WorldConfig.new()
	world.id_world = data.get("id_world", 0)
	world.name_world = data.get("name_world", "???")
	world.story_id = data.get("story_id", -1)
	world.grid_main_ancho = config.MAIN_ANCHO
	world.grid_main_largo = config.MAIN_LARGO
	world.grid_inventory_ancho = config.INV_ANCHO
	world.grid_inventory_largo = config.INV_LARGO
	
	# Crear la tienda
	world.store_lsg = Store.new()
	world.store_lsg.list_store = []

	for store_dict in data.get("store", []):
		var s_item := StoreItem.new()
		s_item.id = store_dict.get("id", "")
		s_item.dimension_id = store_dict.get("dimension_id", 0)
		s_item.cost = store_dict.get("cost", 0)
		s_item.modifiable_mechanic_videogame_id = store_dict.get("modifiable_mechanic_videogame_id", -1)
		world.store_lsg.list_store.append(s_item)

	# Texturas principales
	world.texture_world = load_texture_from(world_entry["other"], data.get("texture_world", ""))
	world.texture_slot = load_texture_from(world_entry["other"], data.get("texture_slot", ""))
	world.texture_slot_inv = load_texture_from(world_entry["other"], data.get("texture_slot_inv", ""))
	world.bloqueo_parcial = load_texture_from(world_entry["other"], data.get("bloqueo_parcial", ""))
	world.bloqueo_completo = load_texture_from(world_entry["other"], data.get("bloqueo_completo", ""))
	world.texture_main_world = load_texture_from(world_entry["background"], data.get("texture_main_world", ""))
	world.texture_board_world = load_texture_from(world_entry["background"], data.get("texture_board_world", ""))

	'''lista de items que tiene el mundo junto con sus caracteristicas'''
	# Items
	world.item_db = []
	for item_dict in data.get("items", []):
		var item = _create_item(item_dict, world_entry["items"])
		world.item_db.append(item)

	'''lista de personajes'''
	# Characters
	world.list_characters = []
	for char_dict in data.get("characters", []):
		var char := CharacterData.new()
		char.character_id = char_dict.get("character_id", "")
		char.name = char_dict.get("name", "")
		char.rarity = char_dict.get("rarity", 1)
		char.portrait = load_texture_from(world_entry["characters"], char_dict.get("portrait", ""))

	'''lista de objetos animados'''
	var objs_data = data.get("animated_objects", [])
	world.animated_objects = _parse_animated_objects(objs_data)


	'''lista de recompensas que se dan mientras se avanza en la historia'''
	# RewardConfig
	world.reward_config = RewardConfig.new()
	world.reward_config.rewards = []
	for reward_dict in data.get("reward_config", {}).get("rewards", []):
		var reward := RewardConfigItem.new()
		reward.chapter = reward_dict.get("chapter", 0)
		reward.scene = reward_dict.get("scene", 0)
		# Convertir a Array[String]
		var ids: Array[String] = []
		for id in reward_dict.get("rewards_id", []):
			ids.append(str(id))
		reward.rewards_id = ids
		reward.exp = reward_dict.get("exp", 0)
		reward.coins_required = reward_dict.get("coins_required", 0)
		world.reward_config.rewards.append(reward)

	'''lista de fusiones posibles dentro del mundo'''
	# FusionConfig
	world.fusion_config = FusionConfig.new()
	world.fusion_config.fusion_items = []
	for fusion_dict in data.get("fusion_config", {}).get("fusion_items", []):
		var fusion := FusionItem.new()
		fusion.combination = fusion_dict.get("combination", "")
		# aquí puedes mapear el resultado a un ItemBase ya cargado
		var result_id = fusion_dict.get("result", "")
		fusion.result = world.get_item_by_id(result_id)
		world.fusion_config.fusion_items.append(fusion)

	'''obtiene las configuraciones del array inicial'''
	# Grid layouts
	world.grid_main_layout = GridConfig.new()
	world.grid_main_layout.grid_config = []
	for slot_dict in data.get("grid_main_layout", {}).get("grid_config", []):
		var slot := GridSlotConfig.new()
		slot.slot = slot_dict.get("slot", 0)
		slot.id = slot_dict.get("id", "")
		slot.bloqueado = slot_dict.get("bloqueado", false)
		slot.bloqueado_completo = slot_dict.get("bloqueado_completo", false)
		world.grid_main_layout.grid_config.append(slot)

	world.grid_inventory_layout = GridConfig.new()
	world.grid_inventory_layout.grid_config = []
	for slot_dict in data.get("grid_inventory_layout", {}).get("grid_config", []):
		var slot := GridSlotConfig.new()
		slot.slot = slot_dict.get("slot", 0)
		slot.id = slot_dict.get("id", "")
		slot.bloqueado = slot_dict.get("bloqueado", false)
		slot.bloqueado_completo = slot_dict.get("bloqueado_completo", false)
		world.grid_inventory_layout.grid_config.append(slot)

	return world

func load_texture_from(base_dir: String, rel_path: String) -> Texture2D:
	if rel_path == "" or rel_path == null:
		return null
	var full_path = base_dir + rel_path
	if ResourceLoader.exists(full_path):
		return load(full_path)
	else:
		push_warning("No se encontró recurso en: " + full_path)
		return null


func _create_item(item_dict: Dictionary, base_items_icon : String) -> ItemBase:
	var tipo = item_dict.get("item_tipo", "")
	var item: ItemBase = null
	
	match tipo:
		"duplicator":
			item = ItemDuplicator.new()
			item.target_type = item_dict.get("target_type", "item")
			item.num_copies = item_dict.get("num_copies", 2)
		"divider":
			item = ItemDivider.new()
			item.target_type = item_dict.get("target_type", "item")
			item.divide_factor = item_dict.get("divide_factor", 3)
		"evolver":
			item = ItemEvolver.new()
			item.target_type = item_dict.get("target_type", "item")
			item.levels_up = item_dict.get("levels_up", 1)
		"cooldown_reducer":
			item = ItemCooldownReducer.new()
			item.target_type = item_dict.get("target_type", "generator")
			item.reduction = item_dict.get("reduction_time", 30)
		"generator":
			item = ItemGenerator.new()
		"limited_generator":
			item = LimitedGenerator.new()
		_:
			item = ItemBase.new()
			
	# Asignar propiedades comunes
	item.item_id = item_dict.get("item_id", "")
	item.nombre = item_dict.get("nombre", "")
	item.tipo = item_dict.get("tipo", "")
	item.nivel = item_dict.get("nivel", 1)
	item.descripcion = item_dict.get("descripcion", "")
	item.precio = item_dict.get("precio", 0)
	item.is_fusion = item_dict.get("is_fusion", false)
	item.bloqueado = item_dict.get("bloqueado", false)
	item.bloqueado_completo = item_dict.get("bloqueado_completo", false)
	item.slot_index = item_dict.get("slot_index", -1)
	
	# Icono
	item.icono = load_texture_from(base_items_icon, item_dict.get("icono", ""))
	
	# Datos especiales para generadores
	if item is ItemGenerator:
		var gen_data = item_dict.get("generator_data", {})
		item.uses_max = gen_data.get("uses_max", 0)
		item.cooldown_max = gen_data.get("cooldown_max", 0.0)
		item.category_chain = gen_data.get("category_chain", [])
		item.items = _parse_generator_items(gen_data.get("items", []))

	elif item is LimitedGenerator:
		var gen_data = item_dict.get("generator_data", {})
		item.uses_max = gen_data.get("uses_max", 0)
		item.category_chain = gen_data.get("category_chain", [])
		item.items = _parse_generator_items(gen_data.get("items", []))
	
	return item

func _parse_generator_items(raw_items: Array) -> Array[GeneratorProb]:
	var probs: Array[GeneratorProb] = []
	for prob_dict in raw_items:
		var gp := GeneratorProb.new()
		gp.id = prob_dict.get("id", "")
		gp.prob = prob_dict.get("prob", 0.0)
		probs.append(gp)
	return probs
	
func _parse_animated_objects(data: Array) -> Array[AnimatedObjectConfig]:
	var result: Array[AnimatedObjectConfig] = []
	for obj in data:
		var cfg = AnimatedObjectConfig.new()
		cfg.id = obj.get("id", "")
		cfg.src = obj.get("src", "")
		cfg.position = Vector2(obj.get("position", [0,0])[0], obj.get("position", [0,0])[1])
		cfg.scale = Vector2(obj.get("scale", [1,1])[0], obj.get("scale", [1,1])[1])
		cfg.z_index = obj.get("z_index", 0)
		result.append(cfg)
	return result

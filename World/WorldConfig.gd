extends Resource
class_name WorldConfig

'''
Configuración inicial del mundo, incluyendo que items habrá en la grilla y su posición
Nota: se podría cambiar aquí también configuraciones como que narrativa usar o los items
arreglados en el aspecto visual :v
'''
# MAIN
@export var item_db: Array[ItemBase] = [] 
@export var grid_main_layout: GridConfig
@export var grid_inventory_layout: GridConfig
@export var fusion_config: FusionConfig

# dimensiones
@export var grid_main_ancho: int = 7
@export var grid_main_largo: int = 9
@export var grid_inventory_ancho: int = 5 
@export var grid_inventory_largo: int = 4

# Metadata del world
@export var id_world : int = 1
@export var texture_world : Texture2D
@export var name_world : String

# Textures de grid
@export var texture_slot : Texture2D
@export var texture_slot_inv : Texture2D
@export var bloqueo_parcial : Texture2D
@export var bloqueo_completo : Texture2D

# Personajes para pedir pedidos y de la historia
@export var list_characters : Array[CharacterData]

# Metadata de la historia
@export var story_id : int
@export var reward_config : RewardConfig

# Tienda LSG asociada
@export var store_lsg : Store

# Imagen que sale en el menu de tareas del mundo
@export var texture_main_world : Texture2D
@export var texture_board_world : Texture2D

# Objetos animados para la pantalla de tarea
@export var animated_objects: Array[AnimatedObjectConfig] = []

func get_all_items():
	return item_db

'''Método para traer un item'''
func get_item_by_id(id: String) -> ItemBase:
	for item in item_db:
		if item.item_id == id:
			return item
	return null

'''Método para traer la regla de fusión'''
func get_fusion_rules() -> Dictionary:
	var rules := {}
	for fusion_item in fusion_config.fusion_items:
		rules[fusion_item.combination] = fusion_item.result
	return rules

func get_character_by_id(id: String) -> CharacterData:
	for c in list_characters:
		if c.character_id == id:
			return c
	return null

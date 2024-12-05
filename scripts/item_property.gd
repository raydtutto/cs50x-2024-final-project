extends Node
class_name ItemProp

# Item colors
enum ItemTypes { UNKNOWN, BLUE, GREEN, RED, VIOLET, YELLOW };

# Movement directions
enum Touch { TAP, UP, DOWN, LEFT, RIGHT };

# Init color types
@export var color: ItemProp.ItemTypes;

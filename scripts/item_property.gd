extends Node
class_name ItemProp

enum ItemTypes { UNKNOWN, BLUE, GREEN, RED, VIOLET, YELLOW };
enum Touch { TAP, UP, DOWN, LEFT, RIGHT };

# Init color types
@export var color: ItemProp.ItemTypes;

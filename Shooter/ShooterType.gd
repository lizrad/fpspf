extends Resource
class_name ShooterType

export var cooldown: float
export var damage: float
enum BulletType{Hitscan}
export(BulletType) var bullet_type
export var bullet_speed: float
export var bullet_range: float

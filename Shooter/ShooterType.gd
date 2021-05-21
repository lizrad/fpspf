extends Resource
class_name ShooterType

export var cooldown: float
export var damage: float
enum BulletType{Hitscan}
export(BulletType) var bullet_type
export(PackedScene) var attack;

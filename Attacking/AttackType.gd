class_name AttackType
extends Resource

export var ammunition: int
export var burst_amount: int
export var burst_delay: float
export var attack_range: float
export var attack_time: float
export var recoil: float
export var continuously_damaging: bool
export var damage_invincibility_time: float
export var cooldown: float
export var damage: float
export var bounce_strength: float
export (AudioStreamSample) var sound
export (StreamTexture) var img_bullet
export (PackedScene) var attack
export (PackedScene) var player_accessory

# ATTACKS
enum AttackTypeType {NORMAL, RESET}

export (AttackTypeType) var attack_type_type

export var charge_time: float
export var charge_object: PackedScene
export var move_while_charging: bool
export var rotate_while_charging: bool

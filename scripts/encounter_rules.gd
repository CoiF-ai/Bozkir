extends RefCounted
const BASE := [
	{"hp":80.0,"speed":60.0,"damage":12.0,"attack_rate":0.8,"xp":4,"gold":2},
	{"hp":150.0,"speed":75.0,"damage":22.0,"attack_rate":1.0,"xp":10,"gold":5},
	{"hp":400.0,"speed":150.0,"damage":40.0,"attack_rate":1.3,"xp":35,"gold":15},
	{"hp":6000.0,"speed":120.0,"damage":50.0,"attack_rate":1.0,"xp":250,"gold":120},
	{"hp":240.0,"speed":120.0,"damage":28.0,"attack_rate":1.2,"xp":18,"gold":8},
	{"hp":180.0,"speed":140.0,"damage":22.0,"attack_rate":1.1,"xp":14,"gold":6},
	{"hp":160.0,"speed":170.0,"damage":20.0,"attack_rate":1.1,"xp":12,"gold":6},
	{"hp":2200.0,"speed":42.0,"damage":65.0,"attack_rate":0.7,"xp":90,"gold":40}
]
const BOSS_RATINGS := [[80,95,100],[95,100,120],[120,100,90]]
const BOSS_HP := [6000.0,14000.0,28000.0]
const STOCK := [0.5,0.75,1.0]
static func stats(floor_index: int,kind: int,variant: int,level: int,wave: int,madness := false) -> Dictionary:
	var result: Dictionary=BASE[kind].duplicate()
	if kind==3:
		result.hp=BOSS_HP[floor_index]
		result.damage *= BOSS_RATINGS[floor_index][0]/100.0
		result.attack_rate *= BOSS_RATINGS[floor_index][1]/100.0
		result.speed *= BOSS_RATINGS[floor_index][2]/100.0
		return result
	var growth := maxf(0,level-1)*0.035+maxf(0,wave-1)*0.055
	var stock: float=STOCK[floor_index]
	var wolf: float = [0.5,0.7,1.0][clampi(variant,0,2)] if kind==2 else 1.0
	result.hp *= stock*wolf*(1+growth)*(2.4 if kind==2 and variant==2 else 1.0)
	result.damage *= stock*wolf*(1+growth*0.48)
	# Health/damage use stock tiers; locomotion stays responsive even on floor one.
	result.speed *= 1.35*lerpf(0.7,1.0,stock)*lerpf(0.8,1.0,wolf)*minf(2.0,1+growth*0.25)
	result.attack_rate *= stock*minf(2.0,1+growth*0.2)
	if madness and kind in [4,5,7]:
		result.speed *= 2.0
		result.damage *= 1.5
		result.attack_rate *= 1.4
	result.xp=ceili(result.xp*(1+floor_index*0.8)*(2 if kind==2 and variant==2 else 1))
	return result


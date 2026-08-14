extends Node

const ABILITY := {
	"bff-rcv-x1": {},
	"ctr-shd-r1": {},
	"dbf-def-d1": {},
	"ins-pen-s1": {},
	"ins-gat-s3": {},
	"mle-fst-b1": {},
	"mle-psh-h1": {},
	"mle-swd-s1": {},
	"mle-swd-s2": {},
	"mle-swd-w3": {},
	"pro-bmg-o1": {},
	"pro-flm-s3": {},
	"pro-rkt-l1": "res://abilities/_database/pro-rkt-l1.tres",
	"stg-cap-s1": {},
	"stg-brk-d1": {},
	"stg-rep-a0": {},
	"smn-cub-r1": "res://abilities/_database/smn-cub-r1.tres",
	"smn-tbm-r1": {},
	"thw-cnb-b1": "res://abilities/_database/thw-cnb-b1.tres",
	"thw-grn-s1": {},
	"trp-lmn-r1": {},
	"trp-ber-r1": {},
}


var PUSH = load("res://abilities/melee/push/abilities_melee_push.tscn").instantiate()

var ability_list := [
	#load().instantiate(),
	load("res://abilities/stage-effects/capture-tile/abilities_stage-effects_capture-tile.tscn").instantiate(),
	load("res://abilities/summons/rock-cube/abilities_summons_rock-cube.tscn").instantiate(),
	load("res://abilities/thrown/cannon-ball/abilities_thrown_cannon-ball.tscn").instantiate(),
	load("res://abilities/instantiated-shot/rocket/abilities_instantiated-shot_rocket.tscn").instantiate(),
	load("res://abilities/melee/punch/abilties_melee_punch.tscn").instantiate(),
	load("res://abilities/instant-shot/cannon/abilities_instant-shot_cannon.tscn").instantiate(),
	load("res://abilities/debuffs/def-down/abilities_debuffs_def-down.tscn").instantiate(),
	load("res://abilities/counters/reflect/abilities_counters_reflect.tscn").instantiate(),
	load("res://abilities/buffs/heal-10/abilities_buffs_heal-10.tscn").instantiate(),
	load("res://abilities/traps/landmine/abilities_traps_landmine.tscn").instantiate(),
]

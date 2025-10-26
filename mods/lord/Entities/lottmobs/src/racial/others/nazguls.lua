local api = require('fear_height.api')

-- TODO: workaround of LG-2023: не возможно переопределить текстуру после регистрации мобов
--- Проверяет, находится ли текущая дата в хэллоуинском периоде
--- @return boolean true если текущая дата в периоде с 24 октября по 7 ноября, иначе false
local function is_halloween_season()
	local now = os.date('*t')
	local month, day = now.month, now.day

	return (month == 10 and day >= 24) or (month == 11 and day <= 14)
end

mobs:register_mob("lottmobs:nazgul", {
	type = "monster",
	hp_min = 90,
	hp_max = 110,
	collisionbox = {-0.3,-1.0,-0.3, 0.3,0.8,0.3},
	visual = "mesh",
	mesh = "ringwraith_model.x",
	-- TODO: Workaround of LG-2023: не возможно переопределить текстуру после регистрации мобов
	textures = is_halloween_season()
		and { {"halloween_nazgul.png"} }
		or  { {"lottmobs_nazgul.png"} },
	visual_size = {x=2, y=2},
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 1,
	run_velocity = 3,
	damage = 10,
	drops = {
		{ name = "lottores:mithril_ingot",    chance = 1, min = 2, max = 5, }, -- tmp reduced min = 5, max = 15, },
		{ name = "lottarmor:chestplate_gold", chance = 3, min = 1, max = 11, },
		{ name = "lottarmor:leggings_gold",   chance = 3, min = 1, max = 1, },
		{ name = "lottarmor:helmet_gold",     chance = 3, min = 1, max = 1, },
		{ name = "lottarmor:boots_gold",      chance = 3, min = 1, max = 1, },
		{ name = "lottweapons:gold_spear",    chance = 3, min = 1, max = 1, },
		{ name = "lottores:goldsword",        chance = 3, min = 1, max = 1, },
	},
	drawtype = "front",
	armor = 100,
	water_damage = 10,
	lava_damage = 0,
	light_damage = 0,
	on_rightclick = nil,
	attack_type = "shoot",
	arrow = "lord_projectiles:dark_ball",
	shoot_interval = 4,
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 1,
		stand_end = 1,
		walk_start = 20,
		walk_end = 60,
		punch_start = 70,
		punch_end = 110,
	},
	jump = true,
	sounds = {
		war_cry  = "mobs_nazgul_attack_war_cry",
		death    = "mobs_nazgul_dying",
		attack   = "default_punch2",
		random   = "mobs_nazgul_scream_1",
		distance = 48,
	},
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,
	do_custom = function (self)
		api.set_fear_height_by_state(self)
	end
})

mobs:register_mob("lottmobs:witch_king", {
	type = "monster",
	hp_min = 250,
	hp_max = 350,
	collisionbox = {-0.3,-1.0,-0.3, 0.3,0.8,0.3},
	visual = "mesh",
	mesh = "human_model.x",
	-- TODO: Workaround of LG-2023: не возможно переопределить текстуру после регистрации мобов
	textures = is_halloween_season()
		and { {"halloween_witch_king.png"} }
		or  { {"lottmobs_witch_king.png"} },
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 1,
	armor = 100,
	run_velocity = 3,
	damage = 12,
	drops = {
		{ name = "lottores:mithril_ingot",       chance = 1, min = 4,  max = 10, }, -- temporary reduced
		{ name = "lottarmor:chestplate_mithril", chance = 3, min = 1,  max = 11, },
		{ name = "lottarmor:leggings_mithril",   chance = 3, min = 1,  max = 1, },
		{ name = "lottarmor:helmet_mithril",     chance = 3, min = 1,  max = 1, },
		{ name = "lottarmor:boots_mithril",      chance = 3, min = 1,  max = 1, },
		{ name = "lottweapons:mithril_spear",    chance = 3, min = 1,  max = 1, },
		{ name = "lottores:mithrilsword",        chance = 3, min = 1,  max = 1, },
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 0,
	light_damage = 0,
	on_rightclick = nil,
	attack_type = "shoot",
	arrow = "lord_projectiles:dark_ball",
	shoot_interval = 2,
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		punch_start = 189,
		punch_end = 198,
	},
	jump = true,
	sounds = {
		war_cry  = "mobs_nazgul_attack_war_cry",
		death    = "mobs_nazgul_dying",
		attack   = "default_punch2",
		random   = "mobs_nazgul_scream_2",
		distance = 48,
	},
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,
	do_custom = function (self)
		api.set_fear_height_by_state(self)
	end
})

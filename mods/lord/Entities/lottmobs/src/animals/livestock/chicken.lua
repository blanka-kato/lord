local S = minetest.get_mod_translator()


mobs:register_mob("lottmobs:chicken", {
	type = "animal",
	hp_min = 5,
	hp_max = 10,
	collisionbox = {-0.3,0,-0.3, 0.3,0.8,0.3},
	textures = {
		{"lottmobs_chicken.png"},
	},
	sounds = {
		random = "mobs_chicken",
	},
	visual = "mesh",
	mesh = "chicken_model.x",
	visual_size = {x=1.5, y=1.5, z=1.5,},
	makes_footstep_sound = true,
	walk_velocity = 1,
	armor = 300,
	drops = {
		{ name = "lottmobs:chicken_raw", chance = 1, min = 1, max = 1, },
		{ name = "mobs:chicken_feather", chance = 1, min = 0, max = 2  },
		{ name = "lottmobs:egg",         chance = 1, min = 0, max = 1, },
	},
	light_resistant = true,
	drawtype = "front",
	water_damage = 1,
	lava_damage = 10,
	light_damage = 0,
	animation = {
		speed_normal = 10,
		speed_run = 15,
		stand_start = 0,
		stand_end = 0,
		sit_start = 1,
		sit_end = 9,
		walk_start = 10,
		walk_end = 50,
	},
	follow = {"farming:seed_wheat", "lottother:beast_ring"},
	view_range = 5,
	jump = true,
	step=1,
	passive = true,

	on_rightclick = function(self, clicker)
		local inv = clicker:get_inventory()
		if inv:contains_item("main", "farming:seed_wheat") then
			-- Удаляем одно семя пшеницы из инвентаря игрока
			inv:remove_item("main", "farming:seed_wheat 1")
			-- Шанс дропа 25%
			local chance = math.random(1, 4)
			if chance == 1 then
				-- Возвращаем яйцо
				minetest.add_item(self.object:get_pos(), "lottmobs:egg")
				minetest.chat_send_player(clicker:get_player_name(), "Курица снесла яйцо!")
			else
				minetest.chat_send_player(clicker:get_player_name(), "Курица не снесла яйцо.")
			end
		else
			minetest.chat_send_player(clicker:get_player_name(), "У вас нет семян пшеницы!")
		end
	end,
})

-- Chicken Farming: feeding, egg drop and hatching
minetest.register_node("lottmobs:egg", {
    description = S("Chicken Egg"),
    tiles = {"lottmobs_egg.png"},
    inventory_image  = "lottmobs_egg.png",
    visual_scale = 0.7,
    drawtype = "plantlike",
    wield_image = "lottmobs_egg.png",
    paramtype = "light",
    walkable = false,
    selection_box = {
		type = "fixed",
		fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 4.5 / 16, 4 / 16},
	},
    groups = {snappy = 2, dig_immediate = 3},
    on_place = function(itemstack, placer, pointed_thing)
        -- Проверяем, что игрок кликает по блоку (не по объекту)
        if pointed_thing.type == "node" then
            local under_pos = pointed_thing.under
            local above_pos = pointed_thing.above
            local node_under = minetest.get_node(under_pos)

            if node_under.name == "farming:straw" then
                -- Ограничиваем размещение, если над соломой уже стоит не воздух
                local node_above = minetest.get_node_or_nil(above_pos)
                if node_above and node_above.name ~= "air" and placer then
                    minetest.chat_send_player(placer:get_player_name(), S(
						"Egg can only be placed on top of an empty block above straw."))

                    return itemstack
                end

                -- Удаляем яйцо из инвентаря
                itemstack:take_item()

                -- Размещаем яйцо над соломой
                minetest.set_node(above_pos, {name = "lottmobs:egg"})

                -- Таймер на 10 секунд (5 минут) для превращения яйца в цыплёнка
                local owner_name = placer and placer:get_player_name() or ""
                minetest.after(10, function()
                    local cur_node = minetest.get_node(above_pos)
                    if cur_node and cur_node.name == "lottmobs:egg" then
                        minetest.add_entity(above_pos, "lottmobs:chicken")
                        -- Удаляем ноду яйца после спавна моба
                        minetest.remove_node(above_pos)
                    end
                end)

                return itemstack
            else
                -- Если блок под курсором не является "farming:straw", ничего не делаем
                minetest.chat_send_player(placer:get_player_name(), S(
					"Egg can only be placed on a straw block."))

                return itemstack
            end
        end

        -- Если не удалось корректно определить узел, возвращаем обычное размещение
        return minetest.item_place(itemstack, placer, pointed_thing)
    end,
})
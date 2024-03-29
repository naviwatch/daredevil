-- Nest boss logic: Intro Spiral shit
mod:hook(BTEnterHooks, "on_skaven_warlord_intro_enter", function(func, self, unit, blackboard, t)
    if level_key == "skaven_stronghold" then
        return func(self, unit, blackboard, t)
    else
		mod:chat_broadcast("Skarrik brave-strong! Man-things not! Cut-crush!")
    end
end)

-- Make event horde only spawn when its into the nest, lengths the time skarikk uses dual blades
mod:hook(Breeds.skaven_storm_vermin_warlord, "run_on_update", function(func, unit, blackboard, t, dt)
    local side = Managers.state.side.side_by_unit[unit]
    local enemy_player_and_bot_units = side.ENEMY_PLAYER_AND_BOT_UNITS
    local enemy_player_and_bot_positions = side.ENEMY_PLAYER_AND_BOT_POSITIONS
    local self_pos = POSITION_LOOKUP[unit]
    local range = BreedActions.skaven_storm_vermin_champion.special_attack_spin.radius
    local num = 0
    local level_key = Managers.state.game_mode:level_key()
    for i, position in ipairs(enemy_player_and_bot_positions) do
        local player_unit = enemy_player_and_bot_units[i]
        if Vector3.distance(self_pos, position) < range and not ScriptUnit.extension(player_unit, "status_system"):is_disabled() and not ScriptUnit.extension(player_unit, "status_system"):is_invisible() then num = num + 1 end
    end

    blackboard.surrounding_players = num
    if blackboard.surrounding_players > 0 then blackboard.surrounding_players_last = t end
    if not blackboard.spawned_at_t then blackboard.spawned_at_t = t end
    if not blackboard.has_spawned_initial_wave and blackboard.spawned_at_t + 4 < t then
        local conflict_director = Managers.state.conflict
        local strictly_not_close_to_players = true
        local silent = false
        local composition_type = "event_medium"
        local limit_spawners, terror_event_id = nil
        local side_id = side.side_id
		if level_key == "skaven_stronghold" then
            conflict_director.horde_spawner:execute_event_horde(t, terror_event_id, side_id, composition_type, limit_spawners, silent, nil, strictly_not_close_to_players)
            blackboard.has_spawned_initial_wave = true
        end
    end

    if blackboard.trickle_timer and blackboard.trickle_timer < t and not blackboard.defensive_mode_duration then
        local conflict_director = Managers.state.conflict
        if conflict_director:count_units_by_breed("skaven_slave") < 10 and level_key == "skaven_stronghold"  then
            local strictly_not_close_to_players = true
            local silent = true
            local composition_type = "stronghold_boss_trickle"
            local limit_spawners, terror_event_id = nil
            local side_id = side.side_id
            conflict_director.horde_spawner:execute_event_horde(t, terror_event_id, side_id, composition_type, limit_spawners, silent, nil, strictly_not_close_to_players)
            blackboard.trickle_timer = t + 500
        else
            blackboard.trickle_timer = t + 500
        end
    end

    local breed = blackboard.breed
    if blackboard.dual_wield_mode then
        local hp = ScriptUnit.extension(blackboard.unit, "health_system"):current_health_percent()
        if blackboard.current_phase == 1 and hp < 0.95 then
            blackboard.current_phase = 2
            blackboard.dual_wield_timer = t + 2
            blackboard.dual_wield_mode = false
        end

        if (blackboard.dual_wield_timer < t and not blackboard.active_node) or blackboard.defensive_mode_duration then
            blackboard.dual_wield_timer = t + 2
            blackboard.dual_wield_mode = true
        end
    else
        local hp = ScriptUnit.extension(blackboard.unit, "health_system"):current_health_percent()
        if blackboard.current_phase == 2 and hp < 0.15 then
            blackboard.current_phase = 3
            local new_run_speed = breed.angry_run_speed
            blackboard.run_speed = new_run_speed
            if not blackboard.run_speed_overridden then blackboard.navigation_extension:set_max_speed(new_run_speed) end
        elseif blackboard.current_phase == 1 and hp < 0.95 then
            blackboard.current_phase = 2
        end

        if blackboard.defensive_mode_duration then
            if not blackboard.defensive_mode_duration_at_t then blackboard.defensive_mode_duration_at_t = t + blackboard.defensive_mode_duration - 10 end
            if blackboard.defensive_mode_duration_at_t <= t then
                blackboard.defensive_mode_duration = nil
                blackboard.defensive_mode_duration_at_t = nil
            else
                blackboard.defensive_mode_duration = t - blackboard.defensive_mode_duration_at_t
                blackboard.dual_wield_mode = false
            end
        elseif blackboard.dual_wield_timer < t and not blackboard.active_node then
            blackboard.dual_wield_mode = true
            blackboard.dual_wield_timer = 2
        end
    end

    if blackboard.displaced_units then AiUtils.push_intersecting_players(unit, unit, blackboard.displaced_units, breed.displace_players_data, t, dt) end
end)

	-- Gas duration
	BreedActions.skaven_poison_wind_globadier.throw_poison_globe.duration = 6.5 --8
	-- Gas throw cooldown so you dont get barraged by gas artillery
	BreedActions.skaven_poison_wind_globadier.throw_poison_globe.time_between_throws = { 12, 4 } -- 12,2 what the fuck fatshark
	-- Vortex timer
	BreedActions.chaos_vortex_sorcerer.skulk_approach.vortex_spawn_timer = 20 --25

	-- White SV
	--[[
	Breeds.skaven_storm_vermin.bloodlust_health = BreedTweaks.bloodlust_health.beastmen_elite
	Breeds.skaven_storm_vermin.primary_armor_category = 6
	Breeds.skaven_storm_vermin.size_variation_range = { 1.26, 1.28 }
	Breeds.skaven_storm_vermin.max_health = BreedTweaks.max_health.bestigor
	Breeds.skaven_storm_vermin.hit_mass_counts = BreedTweaks.hit_mass_counts.bestigor
	UnitVariationSettings.skaven_storm_vermin.material_variations.cloth_tint.min = 30
	UnitVariationSettings.skaven_storm_vermin.material_variations.cloth_tint.max = 31
	UnitVariationSettings.skaven_storm_vermin.material_variations.skin_tint.min = 1
	UnitVariationSettings.skaven_storm_vermin.material_variations.skin_tint.max = 1
	]]

	--Non-event settings and compositions
	RecycleSettings.max_grunts = 200                         		    	-- Dutch values at 165
	RecycleSettings.push_horde_if_num_alive_grunts_above = 300     	    	
	
	-- Ambient density multiplied by 125%, pseudo-dutch 
	mod:hook(SpawnZoneBaker, "spawn_amount_rats", function(func, self, spawns, pack_sizes, pack_rotations, pack_members, zone_data_list, nodes, num_wanted_rats, ...)
		--local difficulty_settings = Managers.state.difficulty:get_difficulty_settings()
		--local base_difficulty_name = difficulty_settings.display_name
		
		num_wanted_rats = math.round(num_wanted_rats * 125/100) -- Normal C3

		return func(self, spawns, pack_sizes, pack_rotations, pack_members, zone_data_list, nodes, num_wanted_rats, ...)
	end)

	-- Take some breed and change into elite, 0.10% and reduces ambience CW by 80% or so idk, adds more randomness because why not
	mod:hook(ConflictDirector, "spawn_queued_unit", function(func, self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, ...)
	-- 70% to replace ambient CWs just in case
		local nocw
		if breed.name == "chaos_warrior" then
			nocw = {Breeds["chaos_raider"], Breeds["chaos_berzerker"], Breeds["chaos_marauder"]} -- To not piss people off and to cope with hordes
		end

		if nocw then
			if math.random() <= 0.75 then
				breed = nocw[math.random(1, #nocw)]
			end
		end

		return func(self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, ...)
	end)

	-- Change intensity, modified from VernonKun
	mod:hook_safe(Pacing, "update", function(self, t, dt, alive_player_units) 

		local num_alive_player_units = #alive_player_units

		if num_alive_player_units == 0 then
			return
		end

		for k = 1, num_alive_player_units, 1 do
			self.player_intensity[k] = self.player_intensity[k] * 0.7
		end

		self.total_intensity = self.total_intensity * 0.7
	end)

-- Tweaked from Dense
local mean = 1.1
local range = 0.01	

	PackDistributions = {
		periodical = {
			max_low_density = mean,
			min_low_density = mean - range,
			min_hi_density = mean,
			max_hi_density = mean + range,
			random_distribution = false,
			zero_density_below = 0,
			max_hi_dist = 3,
			min_hi_dist = 2,
			max_low_dist = 10,
			min_low_dist = 7,
			zero_clamp_max_dist = 5
		},
		random = {}
	}

	PackSpawningDistribution = {
		standard = {
			goal_density = mean,
			clamp_main_path_zone_area = 100,
			length_density_coefficient = 0,
			spawn_cycle_length = 350,
			clamp_outer_zones_used = 1,
			distribution_method = "periodical",
			calculate_nearby_islands = false
		}
	}

	-- Dense's breedpacks 
	mod:dofile("scripts/mods/Daredevil/breed_pack")

local co = 0.135 -- Ons+ uses 0.11~

	PackSpawningSettings.default.area_density_coefficient = co
	PackSpawningSettings.default_light.area_density_coefficient = co
	PackSpawningSettings.skaven.area_density_coefficient = co
	PackSpawningSettings.skaven_light.area_density_coefficient = co
	PackSpawningSettings.chaos.area_density_coefficient = co
	PackSpawningSettings.chaos_light.area_density_coefficient = co
	PackSpawningSettings.beastmen.area_density_coefficient = co
	PackSpawningSettings.beastmen_light.area_density_coefficient = co
	PackSpawningSettings.skaven_beastmen.area_density_coefficient = co
	PackSpawningSettings.chaos_beastmen.area_density_coefficient = co
	PackSpawningSettings.default.roaming_set = {
		breed_packs = "dense_standard",
		breed_packs_peeks_overide_chance = { -- Reduce chances of trash overriding elites
			0.2,
			0.3
		},
		breed_packs_override = {
			{
				"skaven",
				2,
				0.035
			},
			{
				"plague_monks",
				2,
				0.035
			},
			{
				"marauders",
				2,
				0.03
			},
			{
				"marauders_elites",
				2,
				0.03
			}
		}
	}

	PackSpawningSettings.skaven.roaming_set = {
		breed_packs = "dense_skaven",
		breed_packs_peeks_overide_chance = {
			0.2,
			0.3
		},
		breed_packs_override = {
			{
				"skaven",
				2,
				0.035
			},
			{
				"shield_rats",
				2,
				0.035
			},
			{
				"plague_monks",
				2,
				0.035
			}
		}
	}

	PackSpawningSettings.chaos.roaming_set = {
		breed_packs = "dense_chaos",
		breed_packs_peeks_overide_chance = {
			0.2,
			0.3
		},
		breed_packs_override = {
			{
				"marauders_and_warriors",
				2,
				0.03
			},
			{
				"marauders_shields",
				2,
				0.03
			},
			{
				"marauders_elites",
				2,
				0.03
			},
			{
				"marauders_berzerkers",
				2,
				0.03
			}
		}
	}

	-- Make light variations disappear
	PackSpawningSettings.default_light = PackSpawningSettings.default
	PackSpawningSettings.skaven_light = PackSpawningSettings.skaven
	PackSpawningSettings.chaos_light = PackSpawningSettings.chaos
	PackSpawningSettings.beastmen_light = PackSpawningSettings.beastmen

	PackSpawningSettings.default.difficulty_overrides = nil
	PackSpawningSettings.skaven.difficulty_overrides = nil
	PackSpawningSettings.skaven_light.difficulty_overrides = nil
	PackSpawningSettings.chaos.difficulty_overrides = nil
	PackSpawningSettings.beastmen.difficulty_overrides = nil
	PackSpawningSettings.skaven_beastmen.difficulty_overrides = nil
	PackSpawningSettings.chaos_beastmen.difficulty_overrides = nil

	-- PACING
	PacingSettings.default.peak_fade_threshold = 110                      
	PacingSettings.default.peak_intensity_threshold = 120				  
	PacingSettings.default.sustain_peak_duration = { 5, 10 }			  	
	PacingSettings.default.relax_duration = { 10, 13 }                    
	PacingSettings.default.horde_frequency = { 30, 45 }                   
	PacingSettings.default.multiple_horde_frequency = { 7, 9 }           
	PacingSettings.default.max_delay_until_next_horde = { 70, 75 } -- Increased to cope with beefier hordes
	PacingSettings.default.horde_startup_time = { 12, 20 }                
	PacingSettings.default.multiple_hordes = 3							  -- Came from Dense 

	PacingSettings.default.mini_patrol.only_spawn_above_intensity = 0
	PacingSettings.default.mini_patrol.only_spawn_below_intensity = 900   
	PacingSettings.default.mini_patrol.frequency = { 9, 10 }              

	PacingSettings.default.difficulty_overrides = nil
	PacingSettings.default.delay_specials_threat_value = nil

	PacingSettings.chaos.peak_fade_threshold = 110                        
	PacingSettings.chaos.peak_intensity_threshold = 120                   
	PacingSettings.chaos.sustain_peak_duration = { 5, 10 }                
	PacingSettings.chaos.relax_duration = { 13, 15 }					  
	PacingSettings.chaos.horde_frequency = { 30, 45 } 					  -- Base 30/45
	PacingSettings.chaos.multiple_horde_frequency = { 7, 10 } 			  -- Base 7/10
	PacingSettings.chaos.max_delay_until_next_horde = { 74, 78 }		  -- Increased to cope with beefier hordes
	PacingSettings.chaos.horde_startup_time = { 15, 20 }				  
	PacingSettings.chaos.multiple_hordes = 3							  

	PacingSettings.chaos.mini_patrol.only_spawn_above_intensity = 0      
	PacingSettings.chaos.mini_patrol.only_spawn_below_intensity = 900    
	PacingSettings.chaos.mini_patrol.frequency = { 9, 10 }               

	PacingSettings.chaos.difficulty_overrides = nil
	PacingSettings.chaos.delay_specials_threat_value = nil

	PacingSettings.beastmen.peak_fade_threshold = 110					  -- I'm not touching beastmen they suck
	PacingSettings.beastmen.peak_intensity_threshold = 120				 
	PacingSettings.beastmen.sustain_peak_duration = { 5, 10 }			  
	PacingSettings.beastmen.relax_duration = { 10, 13 } 				  
	PacingSettings.beastmen.horde_frequency = { 35, 50 } 				  
	PacingSettings.beastmen.multiple_horde_frequency = { 6, 9 } 		  
	PacingSettings.beastmen.max_delay_until_next_horde = { 75, 95 }       
	PacingSettings.beastmen.horde_startup_time = { 10, 20 }               

	PacingSettings.beastmen.mini_patrol.only_spawn_above_intensity = 0
	PacingSettings.beastmen.mini_patrol.only_spawn_below_intensity = 900
	PacingSettings.beastmen.mini_patrol.frequency = { 8, 10 }

	PacingSettings.beastmen.difficulty_overrides = nil
	PacingSettings.beastmen.delay_specials_threat_value = nil
	
	-- INTENSITY
	IntensitySettings.default.intensity_added_per_percent_damage_taken = 0 -- No more feel nothing zealot invalidating everything
	IntensitySettings.default.decay_delay = 1
	IntensitySettings.default.decay_per_second = 6
	IntensitySettings.default.intensity_added_knockdown = 50
	IntensitySettings.default.intensity_added_pounced_down = 25
	IntensitySettings.default.max_intensity = 100
	IntensitySettings.default.intensity_added_nearby_kill = 2 -- Killing increases intensity

	IntensitySettings.default.difficulty_overrides = nil

	-- Manual no beastmen
	DefaultConflictDirectorSet = {
	"skaven",
	"chaos",
	"default"
	}	

	-- More rats less rotblood (this doent seem to work xdd)
	DefaultConflictFactionSetWeights = {
		chaos = 10,
		skaven = 40,
		beastmen = 0
	}

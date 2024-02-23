  -- Maximum amount of specials (NOT SPECIALS PER MINUTE)
  local ssms = 8 
	SpecialsSettings.default.max_specials = ssms
	SpecialsSettings.default_light.max_specials = ssms
	SpecialsSettings.skaven.max_specials = ssms
	SpecialsSettings.skaven_light.max_specials = ssms
	SpecialsSettings.chaos.max_specials = ssms
	SpecialsSettings.chaos_light.max_specials = ssms
	SpecialsSettings.beastmen.max_specials = ssms
	SpecialsSettings.skaven_beastmen.max_specials = ssms
	SpecialsSettings.chaos_beastmen.max_specials = ssms

  -- Game will never delay specials
	PacingSettings.default.delay_specials_threat_value = nil
	PacingSettings.chaos.delay_specials_threat_value = nil
	PacingSettings.beastmen.delay_specials_threat_value = nil

  -- Change threat value so they don't cobble up with ambience to delay horde
	Breeds.skaven_warpfire_thrower.threat_value = 2
	Breeds.skaven_gutter_runner.threat_value = 4
--	Breeds.skaven_pack_master.threat_value = 2
	Breeds.skaven_poison_wind_globadier.threat_value = 4
	Breeds.skaven_ratling_gunner.threat_value = 2
	Breeds.chaos_corruptor_sorcerer.threat_value = 2
	Breeds.chaos_vortex_sorcerer.threat_value = 4
	
	Managers.state.conflict:set_threat_value("skaven_warpfire_thrower", 2)
	Managers.state.conflict:set_threat_value("skaven_gutter_runner", 4)
--	Managers.state.conflict:set_threat_value("skaven_pack_master", 2)
	Managers.state.conflict:set_threat_value("skaven_poison_wind_globadier", 4)
	Managers.state.conflict:set_threat_value("skaven_ratling_gunner", 2)
	Managers.state.conflict:set_threat_value("chaos_corruptor_sorcerer", 2)
	Managers.state.conflict:set_threat_value("chaos_vortex_sorcerer", 4)

	SpecialsSettings.default.methods.specials_by_slots = {
		max_of_same = 2,  -- Maximum of same breed                                      
		coordinated_attack_cooldown_multiplier = 0.5, -- Cooldown
		chance_of_coordinated_attack = 0.5, -- Chances of spawning together
		select_next_breed = "get_random_breed",
		after_safe_zone_delay = {
			5, -- Min
			20 -- Max
		},
		spawn_cooldown = {
			15, -- Min
			45 -- Max
		}
	}

	SpecialsSettings.default_light = SpecialsSettings.default
	SpecialsSettings.skaven = SpecialsSettings.default
	SpecialsSettings.skaven_light = SpecialsSettings.default
	SpecialsSettings.chaos = SpecialsSettings.default
	SpecialsSettings.chaos_light = SpecialsSettings.default
	SpecialsSettings.beastmen = SpecialsSettings.default

  -- Reduce chances of blightstormers showing up (they're annoying), also allows for both skaven and chaos specials to spawn regardless of faction (rat equality yay!)
	SpecialsSettings.default.breeds = {
		"skaven_gutter_runner",
		"skaven_gutter_runner",
		"skaven_pack_master",
		"skaven_pack_master",
		"skaven_ratling_gunner",
		"skaven_ratling_gunner",
		"skaven_poison_wind_globadier",
		"skaven_poison_wind_globadier",
		"chaos_vortex_sorcerer",
		"chaos_corruptor_sorcerer",
		"chaos_corruptor_sorcerer",
		"skaven_warpfire_thrower",
		"skaven_warpfire_thrower",
	}

	SpecialsSettings.chaos.breeds = SpecialsSettings.default.breeds

--[[
	SpecialsSettings.chaos.breeds = {
		"skaven_gutter_runner",
		"skaven_pack_master",
		"skaven_ratling_gunner",
		"skaven_ratling_gunner",
		"skaven_poison_wind_globadier",
		"chaos_vortex_sorcerer",
		"chaos_corruptor_sorcerer",
		"chaos_corruptor_sorcerer",
		"skaven_warpfire_thrower",
		"skaven_warpfire_thrower",
	}
]]

-- It didn't work without one of these before and im scared to remove them
mod.add_breeds_from_special_settings = function(special_settings, difficulty, fallback_difficulty, output)
	local breeds = get_with_override(special_settings, "breeds", difficulty, fallback_difficulty)

	for i = 1, #breeds do
		local breed_name = breeds[i]
		output[breed_name] = true
	end

	local rush_intervention = get_with_override(special_settings, "rush_intervention", difficulty, fallback_difficulty)
	local rush_intervention_breeds = rush_intervention.breeds

	for i = 1, #rush_intervention_breeds do
		local breed_name = rush_intervention_breeds[i]
		output[breed_name] = true
	end

	local speed_running_intervention = get_with_override(special_settings, "speed_running_intervention", difficulty, fallback_difficulty) or SpecialsSettings.default.speed_running_intervention
	local speed_running_intervention_breeds = speed_running_intervention.breeds

	for i = 1, #speed_running_intervention_breeds do
		local breed_name = speed_running_intervention_breeds[i]
		output[breed_name] = true
	end

	local speed_running_intervention_vector_horde_breeds = speed_running_intervention.vector_horde_breeds

	for i = 1, #speed_running_intervention_vector_horde_breeds do
		local breed_name = speed_running_intervention_vector_horde_breeds[i]
		output[breed_name] = true
	end
end

mod.ConflictUtils_find_conflict_director_breeds = function (conflict_director, difficulty, output)
	local fallback_difficulty = DifficultySettings[difficulty].fallback_difficulty
	if not conflict_director.specials.disabled then
		mod.add_breeds_from_special_settings(conflict_director.specials, difficulty, fallback_difficulty, output)
	end
	return output
end

	SpecialsSettings.default.difficulty_overrides.hard = nil
	SpecialsSettings.default.difficulty_overrides.harder = nil
	SpecialsSettings.default.difficulty_overrides.hardest = nil
	SpecialsSettings.default.difficulty_overrides.cataclysm = nil
	SpecialsSettings.default.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.default.difficulty_overrides.cataclysm_3 = nil
	SpecialsSettings.default_light.difficulty_overrides.hard = nil
	SpecialsSettings.default_light.difficulty_overrides.harder = nil
	SpecialsSettings.default_light.difficulty_overrides.hardest = nil
	SpecialsSettings.default_light.difficulty_overrides.cataclysm = nil
	SpecialsSettings.default_light.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.default_light.difficulty_overrides.cataclysm_3 = nil
	SpecialsSettings.skaven.difficulty_overrides.hard = nil
	SpecialsSettings.skaven.difficulty_overrides.harder = nil
	SpecialsSettings.skaven.difficulty_overrides.hardest = nil
	SpecialsSettings.skaven.difficulty_overrides.cataclysm = nil
	SpecialsSettings.skaven.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.skaven.difficulty_overrides.cataclysm_3 = nil
	SpecialsSettings.skaven_light.difficulty_overrides.hard = nil
	SpecialsSettings.skaven_light.difficulty_overrides.harder = nil
	SpecialsSettings.skaven_light.difficulty_overrides.hardest = nil
	SpecialsSettings.skaven_light.difficulty_overrides.cataclysm = nil
	SpecialsSettings.skaven_light.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.skaven_light.difficulty_overrides.cataclysm_3 = nil
	SpecialsSettings.chaos.difficulty_overrides.hard = nil
	SpecialsSettings.chaos.difficulty_overrides.harder = nil
	SpecialsSettings.chaos.difficulty_overrides.hardest = nil
	SpecialsSettings.chaos.difficulty_overrides.cataclysm = nil
	SpecialsSettings.chaos.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.chaos.difficulty_overrides.cataclysm_3 = nil
	SpecialsSettings.chaos_light.difficulty_overrides.hard = nil
	SpecialsSettings.chaos_light.difficulty_overrides.harder = nil
	SpecialsSettings.chaos_light.difficulty_overrides.hardest = nil
	SpecialsSettings.chaos_light.difficulty_overrides.cataclysm = nil
	SpecialsSettings.chaos_light.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.chaos_light.difficulty_overrides.cataclysm_3 = nil
	SpecialsSettings.beastmen.difficulty_overrides.hard = nil
	SpecialsSettings.beastmen.difficulty_overrides.harder = nil
	SpecialsSettings.beastmen.difficulty_overrides.hardest = nil
	SpecialsSettings.beastmen.difficulty_overrides.cataclysm = nil
	SpecialsSettings.beastmen.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.beastmen.difficulty_overrides.cataclysm_3 = nil
	SpecialsSettings.skaven_beastmen.difficulty_overrides.hard = nil
	SpecialsSettings.skaven_beastmen.difficulty_overrides.harder = nil
	SpecialsSettings.skaven_beastmen.difficulty_overrides.hardest = nil
	SpecialsSettings.skaven_beastmen.difficulty_overrides.cataclysm = nil
	SpecialsSettings.skaven_beastmen.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.skaven_beastmen.difficulty_overrides.cataclysm_3 = nil
	SpecialsSettings.chaos_beastmen.difficulty_overrides.hard = nil
	SpecialsSettings.chaos_beastmen.difficulty_overrides.harder = nil
	SpecialsSettings.chaos_beastmen.difficulty_overrides.hardest = nil
	SpecialsSettings.chaos_beastmen.difficulty_overrides.cataclysm = nil
	SpecialsSettings.chaos_beastmen.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.chaos_beastmen.difficulty_overrides.cataclysm_3 = nil

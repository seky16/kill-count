---Get kill count informations for given player.
---@param player LuaPlayer @ The player to get the kill count informations for.
local function get_kill_infos(player)
    local kill_counts = {}
    local prototypes = game.get_filtered_entity_prototypes({ { filter = "type", type = "unit" } })
    for k, v in pairs(prototypes) do
        local count = player.force.kill_count_statistics.get_input_count(k)
        if count > 0 then
            kill_counts[k] = { count = count, localised_name = v.localised_name, order = v.order }
        end
    end
    prototypes = game.get_filtered_entity_prototypes({ { filter = "type", type = "unit-spawner" } })
    for k, v in pairs(prototypes) do
        local count = player.force.kill_count_statistics.get_input_count(k)
        if count > 0 then
            kill_counts[k] = { count = count, localised_name = v.localised_name, order = v.order }
        end
    end
    prototypes = game.get_filtered_entity_prototypes({ { filter = "type", type = "turret" } })
    for k, v in pairs(prototypes) do
        local count = player.force.kill_count_statistics.get_input_count(k)
        if count > 0 then
            kill_counts[k] = { count = count, localised_name = v.localised_name, order = v.order }
        end
    end
    table.sort(kill_counts, function(left, right)
        return left.order < right.order
    end)
    return kill_counts
end

---Update player's counter gui.
---@param player LuaPlayer @ The player to update the gui for.
local function update_gui(player)
    local infos = get_kill_infos(player);
    local text = ""
    local total = 0
    local total_points = 0
    local cached_settings = global.settings[player.index]
    local verbose = cached_settings.verbose
    local point_table = cached_settings.point_table
    local objective = cached_settings.objective
    local notify = false

    local goal = player.get_goal_description()
    if goal == "" then
        goal = "Total kills: 0"
        if objective > 0 then goal = goal .. "/" .. objective end
        player.set_goal_description(goal, true)
    end

    for name, info in pairs(infos) do
        if info.count > 0 then
            local points_unit = point_table[name] or 1
            total_points = total_points + points_unit * info.count
            total = total + info.count
            if verbose then
                if text == "" then text = "Kills:" end
                text = { "", text, "\n", info.localised_name, ": ", info.count }
            end
        end
    end

    if total > 0 then
        if text ~= "" then text = { "", text, "\n" } end
        text = { "", text, "Total kills", ": ", total }
        if table_size(point_table) > 0 then
            total = total_points
            text = { "", text, "\n", "Total points", ": ", total_points }
        end
        if objective > 0 then
            text = { "", text, "/", objective }
            notify = cached_settings.notify and total >= objective
        end
        player.set_goal_description(text, not notify) -- todo: fix dink, only once

        if notify and settings.global["kill-count_win-game"].value then
            game.set_game_state({ game_finished=true, player_won=true, can_continue=true, victorious_force=player.force })
        end

        if notify then global.settings[player.index].notify = false end
    end
end

local function parse_point_table()
    local point_table_str = settings.global["kill-count_point-table"].value or ""
    point_table_str = "return {" .. point_table_str .. "}"
    local point_table = load(point_table_str)() -- todo parse manually
    return point_table
end

---Update player's settings
---@param playerIndex uint @ The player index of the player to update the settings for.
local function cache_settings(playerIndex)
    if not global.settings then global.settings = {} end
    global.settings[playerIndex] = {
        refresh_rate = settings.get_player_settings(playerIndex)["kill-count_refresh-rate"].value,
        verbose = settings.get_player_settings(playerIndex)["kill-count_verbose"].value,
        objective = settings.global["kill-count_objective"].value,
        point_table = parse_point_table(),
        notify = true,
    }

    if settings.global["kill-count_win-game"].value then
        game.reset_game_state()
    end
end

script.on_init(function()
    for _, player in pairs(game.players) do
        cache_settings(player.index)
    end
end)

script.on_event(defines.events.on_player_created, function(event)
    cache_settings(event.player_index)
end)

script.on_configuration_changed(function(event)
    for _, player in pairs(game.players) do
        cache_settings(player.index)
    end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function (event)
    if event.player_index then
        cache_settings(event.player_index)
    end
end)

script.on_event(defines.events.on_tick, function(event)
    for _, player in pairs(game.players) do
        if not global.settings[player.index] then
            cache_settings(player.index) -- just in case
        end
        if event.tick % global.settings[player.index].refresh_rate == 0 then
            update_gui(player)
        end
    end
end)

-- todo: make proper gui
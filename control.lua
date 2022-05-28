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

---Gets formatted string of time left to the time objective.
---@param time_left int @ The time left to the time objective (seconds).
local function format_time_left(time_left)
    -- https://mods.factorio.com/mod/playtime by thuejk (MIT)
    local time_left_seconds = math.floor(time_left) % 60
    local time_left_minutes = math.floor(time_left / 60) % 60
    local time_left_hours = math.floor(time_left / 3600)
    if time_left_hours > 0 then
        return string.format("\nTime left: %d:%02d:%02d", time_left_hours, time_left_minutes, time_left_seconds)
    else
        return string.format("\nTime left: %02d:%02d", time_left_minutes, time_left_seconds)
    end
end

---Update player's counter gui.
---@param player LuaPlayer @ The player to update the gui for.
local function update_gui(player)
    local text = ""
    local total = 0
    local total_points = 0
    local cached_settings = global.settings[player.index]
    local verbose = cached_settings.verbose
    local point_table = cached_settings.point_table
    local kill_objective = cached_settings.kill_objective
    local time_objective = cached_settings.time_objective
    local time_left = time_objective - math.floor(game.tick / 60)
    if time_objective > 0 and time_left < 0 then return end
    local time_left_str = time_objective > 0 and format_time_left(time_left) or ""
    local notify = false
    local infos = get_kill_infos(player);

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

    if text ~= "" then text = { "", text, "\n" } end
    text = { "", text, "Total kills", ": ", total }
    if table_size(point_table) > 0 then
        total = total_points
        text = { "", text, "\n", "Total points", ": ", total_points }
    end
    notify = cached_settings.notify and (time_objective > 0 and time_left == 0)
    if kill_objective > 0 then
        text = { "", text, "/", kill_objective }
        notify = cached_settings.notify and (total >= kill_objective or (time_objective > 0 and time_left == 0))
    end
    text = { "", text, time_left_str }
    player.set_goal_description(text, not notify)

    if notify then global.settings[player.index].notify = false end
    if notify and settings.global["kill-count_win-game"].value then
        game.set_game_state({ game_finished=true, player_won=true, can_continue=true, victorious_force=player.force })
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
        kill_objective = settings.global["kill-count_objective"].value,
        time_objective = settings.global["kill-count_time-objective"].value,
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
        update_gui(player)
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

script.on_event(
    defines.events.on_post_entity_died,
    function()
        for _, player in pairs(game.players) do
            if not global.settings[player.index] then
                cache_settings(player.index) -- just in case
            end

            update_gui(player)
        end
    end,
    {
        { filter = "type", type = "unit" },
        { filter = "type", type = "unit-spawner" },
        { filter = "type", type = "turret" }
    }
)

-- todo: make proper gui
data:extend({
    {
        type = "bool-setting",
        name = "kill-count_verbose",
        localised_name = "Verbose GUI",
        localised_description = "Whether to show kill count for each enemy type (checked) or just total kills (unchecked).",
        setting_type = "runtime-per-user",
        default_value = false
    },
    {
        type = "int-setting",
        name = "kill-count_refresh-rate",
        localised_name = "Refresh rate",
        localised_description = "How often (every n ticks) to update the kill count GUI.",
        setting_type = "runtime-per-user",
        default_value = 20,
        minimum_value = 1,
        maximum_value = 60,
    },
    {
        type = "string-setting",
        name = "kill-count_point-table",
        localised_name = "Point table",
        localised_description = "Comma-separated list of [\"internal-name\"]=points pairs. Points are added to the player's score when the entity is killed. Uses 1 for each enemy type if not specified.",
        setting_type = "runtime-global",
        default_value = "",
        allow_blank = true
    },
    {
        type = "int-setting",
        name = "kill-count_objective",
        localised_name = "Kills objective",
        localised_description = "The kill objective to reach. If greater than 0, the player's kill count/score is compared to this value.",
        setting_type = "runtime-global",
        default_value = 0,
        minimum_value = 0
    },
    {
        type = "int-setting",
        name = "kill-count_time-objective",
        localised_name = "Time objective (seconds)",
        localised_description = "The time objective to reach. If greater than 0, kill count stops updating after time runs out.",
        setting_type = "runtime-global",
        default_value = 0,
        minimum_value = 0
    },
    {
        type = "bool-setting",
        name = "kill-count_win-game",
        localised_name = "Win game by reaching the objective",
        localised_description = "Whether reaching the objective should end the game. Does nothing if objective is equal to 0.",
        setting_type = "runtime-global",
        default_value = false
    }
})
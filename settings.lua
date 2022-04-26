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
        minimum_value = 1
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
        localised_name = "Objective",
        localised_description = "The objective to reach. If set, the player's kill count/score is compared to this value.",
        setting_type = "runtime-global",
        default_value = 0,
        minimum_value = 0
    }
})
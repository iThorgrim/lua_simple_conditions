local Helper = require("lua_simple_conditions.helper.simple_conditions_helper")
local Controller = { }

function Controller.CheckCondition(player, entity, condition_type, condition_value)
    return Helper.SOURCE_TYPE[condition_type](player, entity, condition_value)
end

function Controller.EvaluateEntityConditions(player, entity)
    local highest_good_condition_id

    for condition_id, relation_data in pairs(entity.relations) do
        local is_good_condition = true
        local conditions = relation_data.conditions

        for condition_type, condition_value in pairs(conditions) do
            is_good_condition = Controller.CheckCondition(player, entity, condition_type, condition_value)
            if not is_good_condition then break end
        end

        if is_good_condition and (highest_good_condition_id == nil or condition_id > highest_good_condition_id) then
            highest_good_condition_id = condition_id
        end
    end

    return highest_good_condition_id or nil
end

function Controller.CheckConditions(player, entity)
    if ( not entity ) then return end
    local highest_good_condition_id = Controller.EvaluateEntityConditions(player, entity)
    return highest_good_condition_id or nil
end

return Controller
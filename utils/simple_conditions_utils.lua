local Helper = require("lua_simple_conditions.helper.simple_conditions_helper")
local Utils = { }

-- Transform underscores to camelCase
function Utils.ToCamelCase(str)
    return (str:gsub('_(%l)', function (x) return x:upper() end))
end

-- Find string representation of an enum
function Utils.EnumToString(enum, value)
    if ( enum ) then
        for k, v in pairs(enum) do
            if v == value then
                return k
            end
        end
    end
    return nil -- explicit return of nil if not found for clarity
end

-- Initialize global Callbacks table if not exist and add callback
function Utils.InitAndAddCallbackIn(callback, conditions)
    if not _G["Callbacks"] then
        _G["Callbacks"] = { }
    end

    table.insert(_G["Callbacks"], { callback = callback, conditions = conditions })
end

function Player:GetSpecialization()
    return self:HasTankSpec()   and Helper.ENUM.SPECIALIZATION.TANK
            or self:HasHealSpec()   and Helper.ENUM.SPECIALIZATION.HEAL
            or self:HasCasterSpec() and Helper.ENUM.SPECIALIZATION.CASTER
            or self:HasMeleeSpec()  and Helper.ENUM.SPECIALIZATION.MELEE
            or nil
end

return Utils
-- Requirement
local Utils  = require("lua_simple_conditions.utils.simple_conditions_utils")
local Helper = require("lua_simple_conditions.helper.simple_conditions_helper")

local Entity = { }

-- Local global method
local format = string.format

-- Initialize the instance
function Entity:new(database)
    local instance = setmetatable({}, { __index = self })

    instance.fluent_search = { }
    instance.database = database
    instance:createDynamicMethods(Helper.ENUM.METHOD)

    return instance
end

function Entity:createDynamicMethods(methods)
    for _, method in ipairs(methods) do
        local methodName = "GetBy" .. Utils.ToCamelCase(method:sub(1,1):upper() .. method:sub(2))
        self[methodName] = function (self, value)
            if self.last_method == methodName then
                self.fluent_search = { }
            end
            self.fluent_search[method] = value
            self.last_method = methodName
            return self
        end
    end
end

function Entity:load(condition_table, relation_table, collection)
    local conditions = self:loadData(Helper.DATABASE.CONDITION, condition_table)
    self.relations  = self:loadData(Helper.DATABASE.RELATION, relation_table, conditions, collection)
    return self
end

function Entity:loadData(dbInfo, table, conditions, collections)
    local database = self.database

    WorldDBQuery(format(dbInfo.CREATE, database, table))
    local query = WorldDBQuery(format(dbInfo.READ, database, table))

    if dbInfo == Helper.DATABASE.CONDITION then
        return self:getConditionsData(query)
    elseif dbInfo == Helper.DATABASE.RELATION then
        return self:getRelationsData(query, conditions, collections)
    end
end

function Entity:getConditionsData(query)
    local temp = { }
    if query then
        repeat
            local condition_id = query:GetUInt32(0)
            local condition_type = query:GetString(1)
            local condition_value = query:GetUInt32(2)

            temp[condition_id] = temp[condition_id] or { }
            temp[condition_id][condition_type] = condition_value
        until not query:NextRow()
    end
    return temp
end

function Entity:getRelationsData(query, conditions, collections)
    local temp = { }
    if query then
        repeat
            local condition_id = query:GetUInt32(0)
            local collection_id = query:GetUInt32(1)

            if conditions[condition_id] and collections[collection_id] then
                temp[condition_id] = {
                    conditions = conditions[condition_id],
                    collections = collections[collection_id]
                }
            end
        until not query:NextRow()
    end
    return temp
end

function Entity:OrderBy(condition_type, source_table)
    for condition_id, data in pairs(self.relations) do
        for type, value in pairs(data.conditions) do
            if type == condition_type then
                source_table[value] = condition_id
            end
        end
    end
    return self
end

function Entity:GetCollectionByCondition(condition_id)
    self.results = self.relations[condition_id] and self.relations[condition_id].collections or nil
    return self
end

function Entity:checkFluentSearch(relation)
    for condition_type, condition_value in pairs(self.fluent_search) do
        if relation.conditions[condition_type] ~= condition_value then
            return false
        end
    end
    return true
end

function Entity:collectResults()
    local results = { }
    for id, relation in pairs(self.relations) do
        if self:checkFluentSearch(relation) then
            results = relation.collections
        end
    end
    return results
end

function Entity:GetCollection()
    local results = self:collectResults()
    self.results = results
    self.fluent_search = { }
    return self
end

return Entity
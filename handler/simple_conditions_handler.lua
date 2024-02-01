local Controller    = require("lua_simple_conditions.controller.simple_conditions_controller")
local Helper        = require("lua_simple_conditions.helper.simple_conditions_helper")
local Handler       = { }

function Handler.ProcessCallbacks(player, is_reset)
    for _, data in pairs(_G["Callbacks"]) do
        if ( is_reset ) then
            data.callback(player, nil)
        else
            data.callback(player, Controller.CheckConditions(player, data.conditions))
        end
    end
end

function Handler.GroupEvent(event, group)
    local members = group:GetMembers()

    for _, player in pairs(members) do
        Handler.ProcessCallbacks(player)
    end
end

function Handler.CheckEventCondition(event, player, object)
    if event == 5 and not (object:GetEntry() == 63645 or object:GetEntry() == 63644) then
        return false
    end
    return true
end

function Handler.PlayerEvent(event, player, object)
    player:SetData("InCombatWith", nil)
    if ( event == 33 and object) then
        local creature = object:ToCreature()
        if ( creature ) then
            player:SetData("InCombatWith", creature:GetEntry())
        end
    end

    if not Handler.CheckEventCondition(event, player, object) then return end
    Handler.ProcessCallbacks(player)
end

function Handler.PacketEvent( event, packet, player )
    player:SetData("Trigger", nil)
    player:SetData("Target", nil)

    local switch = {
        [0x0B4] = function()
            local size = packet:GetSize()
            if ( not size or size <= 4 ) then return end
            local trigger_id = packet:ReadULong() or 0
            player:SetData("Trigger", trigger_id)

            Handler.ProcessCallbacks(player)
        end,

        [0x13D] = function()
            local function getTarget(eventid, delay, repeats, player)
                local target = player:GetSelection()
                if (target and target:GetTypeId() == 3 and target:IsAlive()) then
                    local entry = target:ToCreature():GetEntry()
                    player:SetData("Target", entry)
                end

                Handler.ProcessCallbacks(player)
            end
            player:RegisterEvent(getTarget, 1, 1)
        end
    }

    switch[packet:GetOpcode()]()
end

function Handler.ServerEvent( event )
    local afterReload = event == 33 and true or false
    local beforeReload = event == 16 and true or false

    for _, player in pairs( GetPlayersInWorld() ) do
        if ( afterReload ) then
            Handler.PlayerEvent(event, player, nil)
        end

        if( beforeReload ) then
            Handler.ProcessCallbacks(player, true)
        end
    end
end

for event_type, events in pairs( Helper.ENUM.EVENTS ) do
    local register_event = _G[string.format("Register%sEvent", event_type)]
    for key, event in pairs(events) do
        local func = Handler[string.format("%sEvent", event_type)]
        if ( event_type == "Packet" ) then
            register_event( event, 5, func)
        else
            register_event( event, func )
        end
    end
end
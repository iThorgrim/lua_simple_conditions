return {
    DATABASE = {
        CONDITION = {
            CREATE = [[
                CREATE TABLE IF NOT EXISTS %s.%s (
                    `id` int(10) NOT NULL,
                    `condition_type` enum('aura','item','item_equipped','map','zone','area','active_event','min_level','race','phase_mask','quest_rewarded','quest_incomplete','min_hp_pct','max_hp_pct','difficulty','max_group_size','min_group_size','min_average_ilvl','max_average_ilvl','trigger','in_combat_with','target') NOT NULL DEFAULT 'map',
                    `condition_value` int(11) NOT NULL DEFAULT 0,
                    PRIMARY KEY (`id`,`condition_type`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            ]],
            READ   = "SELECT * FROM `%s`.`%s`;"
        },

        RELATION = {
            CREATE = [[
                CREATE TABLE IF NOT EXISTS %s.%s (
                    `conditions` int(10) NOT NULL,
                    `collections` int(10) NOT NULL,
                    PRIMARY KEY (`conditions`,`collections`),
                    KEY `id_collections` (`collections`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            ]],
            READ   = "SELECT * FROM %s.%s;"
        }
    },

    ENUM = {
        EVENTS = {
            Player = {
                3, 5, 13, 28, 29, 33, 34, 36, 47, 54
            },

            Group = {
                1, 3, 5, 6
            },

            Packet = {
                0x0B4, 0x13D
            },

            Server = {
                33, 16
            }
        },

        METHOD = {
            "active_event",
            "area",
            "aura",
            "difficulty",
            "loot_item",
            "equipped_item",
            "map",
            "max_hp_pct",
            "min_hp_pct",
            "min_level",
            "phase_mask",
            "quest_incomplete",
            "quest_rewarded",
            "race",
            "zone",
            "class",
            "specialization",
            "min_group_size",
            "max_group_size",
            "min_average_ilvl",
            "max_average_ilvl",
            "trigger",
            "in_combat_with",
            "target"
        },

        SPECIALIZATION = {
            ["ALL"]     = 0,
            ["TANK"]    = 1,
            ["HEAL"]    = 2,
            ["CASTER"]  = 3,
            ["MELEE"]   = 4
        },

        CLASS = {
            ["WARRIOR"]         = 1,
            ["PALADIN"]         = 2,
            ["HUNTER"]          = 3,
            ["ROGUE"]           = 4,
            ["PRIEST"]          = 5,
            ["DEATH KNIGHT"]    = 6,
            ["SHAMAN"]          = 7,
            ["MAGE"]            = 8,
            ["WARLOCK"]         = 9,
            ["DRUID"]           = 11
        }
    },

    SOURCE_TYPE= {
        ["aura"] = function(player, entity, value)
            entity:GetByAura(value)
            return player:HasAura(value)
        end,

        ["item"] = function(player, entity, value)
            entity:GetByItem(value)
            return player:HasItem(value)
        end,

        ["difficulty"] = function(player, entity, value)
            entity:GetByDifficulty(value)
            return player:GetMap():GetDifficulty() == value
        end,

        ["item_equipped"] = function(player, entity, value)
            entity:GetByItemEquipped(value)
            local item = player:GetItemByEntry( value )
            return item and item:IsEquipped() or false
        end,

        ["map"] = function(player, entity, value)
            entity:GetByMap(value)
            return player:GetMap():GetMapId() == value
        end,

        ["zone"] = function(player, entity, value)
            entity:GetByZone(value)
            return player:GetZoneId() == value
        end,

        ["area"] = function(player, entity, value)
            entity:GetByArea(value)
            return player:GetAreaId() == value
        end,

        ["min_level"] = function(player, entity, value)
            entity:GetByMinLevel(value)
            return player:GetLevel() >= value
        end,

        ["race"] = function(player, entity, value)
            entity:GetByRace(value)
            return player:GetRace() == value
        end,

        ["phase_mask"] = function(player, entity, value)
            entity:GetByPhaseMask(value)
            return player:GetPhaseMask() == value
        end,

        ["quest_rewarded"] = function(player, entity, value)
            entity:GetByQuestRewarded(value)
            local questStatus = player:GetQuestStatus( value )
            return questStatus and questStatus == 6 or false
        end,

        ["quest_incomplete"] = function(player, entity, value)
            entity:GetByQuestIncomplete(value)
            local questStatus = player:GetQuestStatus( value )
            return questStatus and questStatus == 3 or false
        end,

        ["min_hp_pct"] = function(player, entity, value)
            entity:GetByMinHpPct(value)
            return player:GetHealthPct() >= value
        end,

        ["max_hp_pct"] = function(player, entity, value)
            entity:GetByMaxHpPct(value)
            return player:GetHealthPct() <= value
        end,

        ["max_group_size"] = function(player, entity, value)
            entity:GetByMaxGroupSize(value)
            return player:GetGroup() and #player:GetGroup():GetMembers() <= value or true
        end,

        ["min_group_size"] = function(player, entity, value)
            entity:GetByMinGroupSize(value)
            return player:GetGroup() and #player:GetGroup():GetMembers() >= value or false
        end,

        ["min_average_ilvl"] = function(player, entity, value)
            entity:GetByMinAverageIlvl(value)
            return player:GetAverageItemLevel() >= value
        end,

        ["max_average_ilvl"] = function(player, entity, value)
            entity:GetByMaxAverageIlvl(value)
            return player:GetAverageItemLevel() <= value
        end,

        ["trigger"] = function(player, entity, value)
            local trigger = player:GetData("Trigger")
            entity:GetByMaxAverageIlvl(value)

            return trigger == value
        end,

        ["in_combat_with"] = function(player, entity, value)
            local creature_entry = player:GetData("InCombatWith")
            entity:GetByInCombatWith(value)
            return creature_entry == value
        end,

        ["target"] = function(player, entity, value)
            local target_entry = player:GetData("Target")
            entity:GetByTarget(value)
            if ( not target_entry ) then
                local target = player:GetSelection()
                if ( not target) then return end

                local creature = target:GetTypeId() == 3 and target:ToCreature() or nil
                if (creature) then
                    target_entry = creature:GetEntry()
                end
            end
            return target_entry == value
        end
    }
}
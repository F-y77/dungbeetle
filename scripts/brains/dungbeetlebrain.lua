-- scripts/brains/dungbeetlebrain.lua
require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/panic"

local MAX_WANDER_DIST = 20
local STOP_RUN_DIST = 10
local SEE_PLAYER_DIST = 5

local DungBeetleBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function DungBeetleBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        RunAway(self.inst, "player", SEE_PLAYER_DIST, STOP_RUN_DIST),
        Wander(self.inst, function() 
            return self.inst:GetPosition()
        end, MAX_WANDER_DIST)
    }, .25)
    self.bt = BT(self.inst, root)
end

return DungBeetleBrain
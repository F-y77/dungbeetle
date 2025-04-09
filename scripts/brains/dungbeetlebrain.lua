-- scripts/brains/dungbeetlebrain.lua

-- 行为
require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"

-- 停止跑动距离
local STOP_RUN_DIST = 10
-- 看见玩家距离
local SEE_PLAYER_DIST = 5
-- 躲避玩家距离
local AVOID_PLAYER_DIST = 3
-- 躲避玩家停止距离
local AVOID_PLAYER_STOP = 6
-- 最大游荡距离
local MAX_WANDER_DIST = 20

-- 屎壳郎大脑
local DungBeetleBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

-- 开始
function DungBeetleBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        RunAway(self.inst, "player", AVOID_PLAYER_DIST, AVOID_PLAYER_STOP),
        RunAway(self.inst, "player", SEE_PLAYER_DIST, STOP_RUN_DIST, nil, false),
        Wander(self.inst, function() 
            return self.inst.components.knownlocations:GetLocation("home") 
        end, MAX_WANDER_DIST)
    }, .25)
    self.bt = BT(self.inst, root)
end

return DungBeetleBrain
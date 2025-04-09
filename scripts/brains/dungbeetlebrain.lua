-- scripts/brains/dungbeetlebrain.lua
require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/panic"
require "behaviours/doaction"

local MAX_WANDER_DIST = 20
local STOP_RUN_DIST = 10
local SEE_PLAYER_DIST = 5
local SEE_FOOD_DIST = 10
local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 30

local DungBeetleBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

-- 寻找粪便的函数
local function FindFoodAction(inst)
    local target = FindEntity(inst, SEE_FOOD_DIST, 
        function(item) 
            return item.prefab == "poop" and item:IsOnValidGround()
        end)
    
    if target then
        return BufferedAction(inst, target, ACTIONS.EAT)
    end
end

function DungBeetleBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        
        -- 当生命值低于50%时，积极寻找粪便
        IfNode(function() return self.inst.components.health and self.inst.components.health:GetPercent() < 0.5 end,
            "Need Food",
            DoAction(self.inst, FindFoodAction)),
        
        -- 对玩家逃跑
        RunAway(self.inst, "player", SEE_PLAYER_DIST, STOP_RUN_DIST),
        
        -- 随机漫步时也寻找粪便吃
        DoAction(self.inst, FindFoodAction),
        
        -- 随机漫步
        Wander(self.inst, function() 
            return self.inst:GetPosition()
        end, MAX_WANDER_DIST)
    }, .25)
    self.bt = BT(self.inst, root)
end

return DungBeetleBrain
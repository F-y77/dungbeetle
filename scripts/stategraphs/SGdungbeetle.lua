-- scripts/stategraphs/SGdungbeetle.lua

-- 屎壳郎状态图
require("stategraphs/commonstates")

-- 动作
local actionhandlers = 
{
}

-- 事件
local events =
{
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    
    EventHandler("bumped", 
        function(inst) 
            if inst:HasTag("hasdung") and not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
                inst.sg:GoToState("bumped")
            end
        end),
}

-- 状态
local states =
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            if inst:HasTag("hasdung") then
                inst.AnimState:PlayAnimation("ball_idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,
    },

    State{
        name = "walk",
        tags = {"moving", "canrotate"},
        
        onenter = function(inst) 
            if inst:HasTag("hasdung") then
                inst.AnimState:PlayAnimation("ball_walk", true)
            else
                inst.AnimState:PlayAnimation("walk", true)
            end
            inst.components.locomotor:WalkForward()
        end,
    },
    
    State{
        name = "run",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst) 
            if inst:HasTag("hasdung") then
                inst.AnimState:PlayAnimation("ball_run", true)
            else
                inst.AnimState:PlayAnimation("run", true)
            end
            inst.components.locomotor:RunForward()
        end,
    },
    
    State{
        name = "bumped",
        tags = {"busy"},
        
        onenter = function(inst) 
            inst.AnimState:PlayAnimation("bump")
            inst:RemoveTag("hasdung")
        end,
        
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            if inst:HasTag("hasdung") then
                inst.AnimState:PlayAnimation("ball_hit")
            else
                inst.AnimState:PlayAnimation("hit")
            end
            inst.Physics:Stop()
        end,
        
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,
    },
}

CommonStates.AddFrozenStates(states)
CommonStates.AddSleepStates(states)

return StateGraph("dungbeetle", states, events, "idle", actionhandlers)
-- scripts/stategraphs/SGdungbeetle.lua
require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.EAT, "eat"),
}

local events =
{
    EventHandler("locomote", 
        function(inst) 
            if not inst.sg:HasStateTag("busy") then
                if not inst.components.locomotor:WantsToMoveForward() then
                    if not inst.sg:HasStateTag("idle") then
                        inst.sg:GoToState("idle")
                    end
                else -- 无论是走还是跑，都使用walk动画
                    if not inst.sg:HasStateTag("walking") then
                        inst.sg:GoToState("walk")
                    end
                end
            end
        end),
    
    EventHandler("attacked", function(inst) 
        if not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("hit") 
        end 
    end),
    
    EventHandler("death", function(inst) 
        inst.sg:GoToState("death") 
    end),
}

local states =
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle", true)
        end,
    },

    State{
        name = "walk",
        tags = {"moving", "walking", "canrotate"},
        
        onenter = function(inst) 
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk", true)
        end,
    },
    
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
        end,
        
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "death",
        tags = {"busy", "dead"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("death")
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,
    },
    
    -- 添加吃东西的状态
    State{
        name = "eat",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            -- 如果有eat动画，使用eat动画，如果没有，可以暂时用idle
            if inst.AnimState:IsCurrentAnimation("idle") or true then
                inst.AnimState:PlayAnimation("eat") -- 如果有eat动画
            else
                inst.AnimState:PlayAnimation("idle") -- 临时替代
            end
        end,
        
        timeline =
        {
            -- 在动画的中间吃东西
            TimeEvent(10*FRAMES, function(inst) 
                inst:PerformBufferedAction() 
            end),
        },
        
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
}

return StateGraph("dungbeetle", states, events, "idle", actionhandlers)
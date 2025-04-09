-- scripts/stategraphs/SGdungbeetle.lua
require("stategraphs/commonstates")

local actionhandlers = 
{
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
}

return StateGraph("dungbeetle", states, events, "idle", actionhandlers)
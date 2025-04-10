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
            inst.SoundEmitter:PlaySound(inst:SoundPath("idle"))
        end,
    },

    State{
        name = "walk",
        tags = {"moving", "walking", "canrotate"},
        
        onenter = function(inst) 
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk", true)
            inst.SoundEmitter:PlaySound(inst.sounds.idle)
        end,
    },
    
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            if inst:HasTag("hasdung") then                
                inst.sg:GoToState("bumped")
            else 
                inst.AnimState:PlayAnimation("hit")
                inst.SoundEmitter:PlaySound(inst:SoundPath("hit"))
                inst.Physics:Stop()    
            end        
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
            inst.SoundEmitter:PlaySound(inst:SoundPath("death"))
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
            inst.AnimState:PlayAnimation("eat")
        end,
        
        timeline =
        {
            -- 在动画的中间执行吃东西的动作
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
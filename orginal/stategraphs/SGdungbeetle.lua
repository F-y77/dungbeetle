require("stategraphs/commonstates")

local WALK_SPEED = 2
local RUN_SPEED = 7

local actionhandlers = 
{
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.GOHOME, "action"),
    ActionHandler(ACTIONS.DIGDUNG, "dig"),
    ActionHandler(ACTIONS.MOUNTDUNG, "jump"),    
}

local function processAnim(inst, anim)
    if inst:HasTag("hasdung") then
        return "ball_"..anim
    else
        return anim
    end
end

local events =
{
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    EventHandler("attacked", 
        function(inst) 
            if inst.components.health:GetPercent() > 0 then 
                if not inst.components.freezable:IsFrozen() then 
                    inst.SoundEmitter:KillSound("dungroll")  
                    inst.sg:GoToState("hit") 
                end 
            end 
        end),
    EventHandler("death", 
        function(inst) 
            inst.SoundEmitter:KillSound("dungroll") 
            if inst:HasTag("hasdung") then
                inst.sg:GoToState("bumped", true)
            else            
                inst.sg:GoToState("death") 
            end
        end),
    EventHandler("bumped", 
        function(inst) 
            inst.SoundEmitter:KillSound("dungroll") 
            inst.sg:GoToState("bumped") 
        end),
    EventHandler("locomote", 
        function(inst) 
            if not inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("moving") then 
                return 
            end
            
            if not inst.components.locomotor:WantsToMoveForward() then
                if not inst.sg:HasStateTag("idle") then
                    if inst.sg:HasStateTag("dungmounting") then
                        -- do nothing at the moment.
                    elseif not inst.sg:HasStateTag("running") then   
                        inst.SoundEmitter:KillSound("dungroll")                     
                        inst.sg:GoToState("idle")
                    else                        
                        inst.sg:GoToState("stop_run")
                    end
                end
            elseif inst.components.locomotor:WantsToRun() then
                if not inst.sg:HasStateTag("running") then
                    inst.sg:GoToState("surprise")
                end
            else
                if not inst.sg:HasStateTag("hopping") then
                    inst.sg:GoToState("hop")
                end
            end
        end),
}

local states =
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation(processAnim(inst,"idle"), true)
            else
                inst.AnimState:PlayAnimation(processAnim(inst,"idle"), true)
            end 
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/dungbeetle/idle")                               
            inst.sg:SetTimeout(1 + math.random()*1)
        end,
    },

    State{
        name = "hop",
        tags = {"moving", "canrotate", "hopping"},
             
        onenter = function(inst) 
            inst.AnimState:PlayAnimation(processAnim(inst,"walk_pre"))                       
            inst.Physics:Stop() 
            if inst:HasTag("hasdung") then
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/dungbeetle/rollingbball_LP","dungroll") 
                inst.SoundEmitter:SetParameter("dungroll", "speed", 0)
            end            
        end,
        
        onupdate = function(inst)
            if not inst.components.locomotor:WantsToMoveForward() then
                inst.sg:GoToState("idle")
            end
        end, 

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("hop_loop") end),
        },  
    },      

    State{
        name = "hop_loop",
        tags = {"moving", "canrotate", "hopping"},
        
        onenter = function(inst) 
            inst.AnimState:PlayAnimation(processAnim(inst,"walk_loop"))            
            inst.components.locomotor:WalkForward()
        end,
        
        onupdate = function(inst)
            if not inst.components.locomotor:WantsToMoveForward() then
                inst.sg:GoToState("idle")
            end
        end,  

        events =
        {
            EventHandler("animover", function(inst) inst.sgloop = true inst.sg:GoToState("hop_loop") end),
        },

        onexit = function(inst)
            if not inst.sgloop then
                inst.SoundEmitter:KillSound("dungroll")
            end
            inst.sgloop = nil
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) 
                if inst:HasTag("hasdung") then 
                    inst.SoundEmitter:PlaySound("dontstarve/movement/run_marsh_small") 
                else
                    PlayFootstep(inst)
                end 
            end),
            TimeEvent(11*FRAMES, function(inst) 
                if inst:HasTag("hasdung") then 
                    inst.SoundEmitter:PlaySound("dontstarve/movement/run_marsh_small") 
                else
                    PlayFootstep(inst)
                end 
            end),
        },        
    },

    State{
        name = "dig",
        
        onenter = function(inst) 
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("dig_pre")
        end,
        
        events =
        {
            EventHandler("animover", function(inst, data) inst.sg:GoToState("dig_loop") end),
        } 
    }, 
        
    State{
        name = "dig_loop",
        tags = {"busy"},
        
        onenter = function(inst) 
            inst.AnimState:PlayAnimation("dig_loop", true)                
            inst.sg:SetTimeout(2*math.random()+.5)
        end,    
        
        ontimeout = function(inst)
            inst.sg:GoToState("dig_pst")
        end,
    },

    State{
        name = "dig_pst",
        
        onenter = function(inst) 
            inst.AnimState:PlayAnimation("dig_pst")
            inst:PerformBufferedAction()
        end,
        
        events =
        {
            EventHandler("animover", function(inst, data) inst.sg:GoToState("idle") end),
        } 
    },     

    State{
        name = "jump",
        tags = {"busy","moving","canrotate","dungmounting"},
        onenter = function(inst) 
            RemovePhysicsColliders(inst)   
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("ball_get_on")
            inst.SoundEmitter:PlaySound("dontstarve/common/craftable/tent_sleep")

            local pos = nil
            if inst.dung_target then
                pos = Point(inst.dung_target.Transform:GetWorldPosition())
            end

            local MAX_JUMPIN_DIST = 3
            local MAX_JUMPIN_DIST_SQ = MAX_JUMPIN_DIST*MAX_JUMPIN_DIST
            local MAX_JUMPIN_SPEED = 6     
            local dist
            if pos ~= nil then
                inst:ForceFacePoint(pos)
                local distsq = inst:GetDistanceSqToPoint(pos)
                if distsq <= 0.25*0.25 then
                    dist = 0
                    inst.sg.statemem.speed = 0
                elseif distsq >= MAX_JUMPIN_DIST_SQ then
                    dist = MAX_JUMPIN_DIST
                    inst.sg.statemem.speed = MAX_JUMPIN_SPEED
                else
                    dist = math.sqrt(distsq)
                    inst.sg.statemem.speed = MAX_JUMPIN_SPEED * dist / MAX_JUMPIN_DIST
                end
            else
                inst.sg.statemem.speed = 0
                dist = 0
            end                   
            inst.Physics:SetMotorVel(inst.sg.statemem.speed * .5, 0, 0)
        end,
        
        onexit = function(inst) 
            ChangeToCharacterPhysics(inst)
        end,

        timeline =
        {
            TimeEvent(1 * FRAMES, function(inst)
                inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
            end),

            TimeEvent(12 * FRAMES, function(inst)
                inst.Physics:Stop()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) 
                inst:PerformBufferedAction()
                inst.sg:GoToState("jump_pst")                 
            end),
        } 
    }, 

    State{
        name = "jump_pst",
        
        onenter = function(inst)            
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("ball_get_on_pst")
        end,
        
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        } 
    },

    State{
        name = "surprise",
        tags = {"busy"},
        
        onenter = function(inst) 
            inst.Physics:Stop()
            inst.SoundEmitter:PlaySound(inst.sounds.scream)
            inst.AnimState:PlayAnimation(processAnim(inst,"emote_surprise"))            
        end, 
        events =
        {
            EventHandler("animover", function(inst)  
                if inst:HasTag("hasdung") then
                    inst.sg:GoToState("run")  
                else
                    inst.sg:GoToState("run_noball")  
                end
            end),
        },         
    }, 

    State{
        name = "run",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst) 
            inst.AnimState:PlayAnimation(processAnim(inst,"run_pre"))
            inst.AnimState:PushAnimation(processAnim(inst,"run_loop"), true)
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/dungbeetle/rollingbball_LP","dungroll") 
            inst.SoundEmitter:SetParameter("dungroll", "speed", 1)
            inst.components.locomotor:RunForward()
        end, 
        
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("run_loop") end),
        } 
    }, 

    State{
        name = "run_loop",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst) 
           inst.AnimState:PushAnimation(processAnim(inst,"run_loop"))           
           inst.components.locomotor:RunForward()
        end,
        
        onupdate = function(inst)
            if not inst.components.locomotor:WantsToMoveForward() then
                inst.sg:GoToState("idle")
            end
        end,  

        events =
        {
            EventHandler("animover", function(inst) inst.sgloop = true inst.sg:GoToState("run_loop") end),
        },

        onexit = function(inst)
            if not inst.sgloop then
                inst.SoundEmitter:KillSound("dungroll")
            end
            inst.sgloop = nil
        end,   
        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(11*FRAMES, function(inst) PlayFootstep(inst) end),
        },        
    },

    State{
        name = "run_noball",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst) 
            inst.AnimState:PlayAnimation("walk_pre")
            inst.components.locomotor:RunForward()
        end, 
        
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("run_noball_loop") end),
        } 
    },     

    State{
        name = "run_noball_loop",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst) 
            inst.AnimState:PushAnimation("walk_loop")            
            inst.components.locomotor:RunForward()
        end, 
        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(11*FRAMES, function(inst) PlayFootstep(inst) end),
        },        
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("run_noball_loop") end),
        }         
    }, 
    
    State{
        name = "stop_run",
        tags = {},
        
        onenter = function(inst) 
            if inst:HasTag("hasdung") then
                inst.AnimState:PlayAnimation(processAnim(inst,"run_pst"))
            else
                inst.AnimState:PlayAnimation(processAnim(inst,"walk_pst"))
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
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.scream)
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)        
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
        end,
    
        timeline =
        {
            TimeEvent(3*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/dungbeetle/death")
            end),
        },
    },

    State{
        name = "bumped",
        tags = {"busy"},
        
        onenter = function(inst, dead) 
            if inst:HasTag("hasdung") then
                inst:RemoveTag("hasdung")
                local ball = SpawnPrefab("dungball")
                ball.Transform:SetPosition(inst.Transform:GetWorldPosition())
                ball.AnimState:PlayAnimation("idle")
            end
            
            inst.Physics:Stop()
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("fall_off_pre")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/dungbeetle/crash")
            inst.components.locomotor.runspeed = -TUNING.DUNG_BEETLE_RUN_SPEED
            inst.components.locomotor:RunForward()
            
            if dead then
                inst.sg:GoToState("death")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("bumped_loop") end),
        },  

        onexit = function(inst)
            inst.components.locomotor.runspeed = TUNING.DUNG_BEETLE_RUN_SPEED
            inst.Physics:Stop()
        end,        
    },

    State{
        name = "bumped_loop",
        tags = {"busy"},
        
        onenter = function(inst) 
            inst.AnimState:PlayAnimation(processAnim(inst,"fall_off_loop"), true)
            inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/dungbeetle/fall_off_LP","fallen")
            inst.sg:SetTimeout(2)
        end,

        ontimeout = function(inst) inst.sg:GoToState("bumped_pst") end,
    },    

    State{
        name = "bumped_pst",
        tags = {"busy"},
        
        onenter = function(inst) 
            inst.AnimState:PlayAnimation(processAnim(inst,"fall_off_pst"))
            inst.SoundEmitter:KillSound("fallen")
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
                inst.sg:GoToState("bumped")
            else 
                inst.SoundEmitter:PlaySound(inst.sounds.hurt)
                inst.SoundEmitter:KillSound("fallen")
                inst.AnimState:PlayAnimation("hit")
                inst.Physics:Stop()    
            end        
        end,
        
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },        
    },
}

CommonStates.AddSleepStates(states,
{
    sleeptimeline = 
    {
        TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/dungbeetle/breath_out") end),
    },
})

CommonStates.AddFrozenStates(states)

return StateGraph("dungbeetle", states, events, "idle", actionhandlers) 
local assets=
{
    Asset("ANIM", "anim/dung_beetle_basic.zip"),
    Asset("ANIM", "anim/dung_beetle_build.zip"),
}

local prefabs =
{
    "dungball",
    "monstermeat",
    "chitin",
}

SetSharedLootTable('dungbeetle',
{
    {'monstermeat',  1},
    {'chitin',    0.5},
})

local beetlesounds = 
{
    scream = "dontstarve_DLC003/creatures/dungbeetle/scream",
    hurt = "dontstarve_DLC003/creatures/dungbeetle/hit",
}

local brain = require "brains/dungbeetlebrain"

local function OnWake(inst)
    -- 唤醒时的行为
end

local function OnSleep(inst)
    -- 睡眠时的行为
end

local function falloffdung(inst)
    inst:PushEvent("bumped")
end

local function OnAttacked(inst, data)
    local freezetask = inst:DoTaskInTime(1, function() 
        if inst:HasTag("hasdung") and not inst.components.freezable:IsFrozen() then
            falloffdung(inst)        
        end
    end)
end

local SHAKE_DIST = 40

local function HitShake(inst)
    local player = FindClosestPlayerInRange(inst:GetPosition(), SHAKE_DIST, true)
    if player and player.components.playercontroller then    
        player.components.playercontroller:ShakeCamera(inst, "VERTICAL", 0.5, 0.03, 2, SHAKE_DIST)
    end    
end

local function oncollide(inst, other)
    if inst.sg:HasStateTag("running") and inst:HasTag("hasdung") then
        if other then
            HitShake(inst)    
            falloffdung(inst)
        end 
    end
end

local function OnPickupDungball(inst, data)
    if data and data.item and data.item:HasTag("dungball") then
        inst:AddTag("hasdung")
        inst.sg:GoToState("idle")
    end
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    
    inst.DynamicShadow:SetSize(2, 1.5)
    
    inst:AddTag("hasdung") 
    inst:AddTag("animal") 
    inst:AddTag("dungbeetle")
    inst:AddTag("scarytoprey")
    
    inst.Transform:SetSixFaced()
    
    MakeCharacterPhysics(inst, 1, 0.5)
    inst.Physics:SetCollisionCallback(oncollide)
    
    inst.AnimState:SetBank("dung_beetle")
    inst.AnimState:SetBuild("dung_beetle_build")
    
    if inst:HasTag("hasdung") then
        inst.AnimState:PlayAnimation("ball_idle")
    else
        inst.AnimState:PlayAnimation("idle")
    end
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:SetStateGraph("SGdungbeetle")
    inst.sg:GoToState("idle")
    
    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.DUNG_BEETLE_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.DUNG_BEETLE_WALK_SPEED
    
    inst:SetBrain(brain)
    
    inst.data = {}  
    
    inst:AddComponent("knownlocations")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body"
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.DUNG_BEETLE_HEALTH)
    inst.components.health.murdersound = "dontstarve/rabbit/scream_short"
    
    MakeSmallBurnableCharacter(inst, "body")
    MakeTinyFreezableCharacter(inst, "body")
    
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('dungbeetle')
    
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst, viewer)
        if not inst:HasTag("hasdung") then
            return "UNDUNGED"
        end
    end
    
    inst:AddComponent("sleeper")
    
    inst.OnEntityWake = OnWake
    inst.OnEntitySleep = OnSleep    
    
    inst.sounds = beetlesounds
    
    inst.OnSave = function(inst, data)
        if not inst:HasTag("hasdung") then
            data.lost_dung = true
        end
    end        
    
    inst.OnLoad = function(inst, data)
        if data and data.lost_dung then
            inst:RemoveTag("hasdung")
        end
    end
    
    inst:ListenForEvent("attacked", OnAttacked)
    
    return inst
end

return Prefab("dungbeetle", fn, assets, prefabs)
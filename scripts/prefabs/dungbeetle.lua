-- scripts/prefabs/dungbeetle.lua
local assets=
{
    Asset("ANIM", "anim/dungbeetle.zip"),
}

local prefabs =
{
}

local brain = require "brains/dungbeetlebrain"

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    
    inst.DynamicShadow:SetSize(2, 1.5)
    
    inst:AddTag("animal") 
    inst:AddTag("dungbeetle")
    inst:AddTag("scarytoprey")
    
    -- 设置朝向，可能需要根据您的动画调整
    inst.Transform:SetFourFaced()
    
    MakeCharacterPhysics(inst, 1, 0.5)
    
    -- 设置动画
    inst.AnimState:SetBank("dungbeetle")
    inst.AnimState:SetBuild("dungbeetle")
    inst.AnimState:PlayAnimation("idle", true)
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:SetStateGraph("SGdungbeetle")
    inst:SetBrain(brain)
    
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.DUNG_BEETLE_WALK_SPEED
    
    inst:AddComponent("knownlocations")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body"
    
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.DUNG_BEETLE_HEALTH)
    
    MakeSmallBurnableCharacter(inst, "body")
    MakeTinyFreezableCharacter(inst, "body")
    
    inst:AddComponent("lootdropper")
    
    inst:AddComponent("inspectable")
    
    return inst
end

return Prefab("dungbeetle", fn, assets, prefabs)
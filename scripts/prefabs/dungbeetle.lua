-- scripts/prefabs/dungbeetle.lua
local assets=
{
    Asset("ANIM", "anim/dungbeetle.zip"),
}

local prefabs =
{
}

local brain = require "brains/dungbeetlebrain"

-- 用于判断是否可食用的函数
local function CanEatTest(inst, item)
    return item.prefab == "poop" -- 只吃粪便
end

-- 当吃下食物时调用的函数
local function OnEat(inst, food)
    if food.prefab == "poop" then
        -- 粪便恢复30%的生命值
        if inst.components.health then
            inst.components.health:DoDelta(inst.components.health.maxhealth * 0.3)
        end
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
    
    -- 添加吃东西的组件
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.GENERIC }, { FOODTYPE.GENERIC })
    inst.components.eater:SetCanEatTest(CanEatTest)
    inst.components.eater:SetOnEatFn(OnEat)
    
    -- 添加食物目标寻找组件
    inst:AddComponent("foodaffinity")
    inst.components.foodaffinity:AddFoodtags("poop")
    
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